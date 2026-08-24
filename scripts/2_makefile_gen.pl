#!/usr/bin/perl
#===============================================================================
# Script  : 2_makefile_gen.pl
# Author  : Kashaan
# Purpose : Auto-generates a Makefile for Vivado xvlog/xelab/xsim by scanning
#           all .sv files and ordering them by dependency:
#           1. Interfaces  (files with 'interface' keyword)
#           2. Submodules  (leaf modules — not instantiated by any other file)
#           3. Top Modules (modules that instantiate others)
#           4. Testbench   (files containing 'initial' or '$finish')
#
# Usage   : perl scripts/2_makefile_gen.pl [directory] [top_module]
#           Defaults: directory = current dir, top_module = auto-detected
#
# Output  : Writes 'Makefile.generated' to the target directory
#===============================================================================

use strict;
use warnings;

#-------------------------------------------------------------------------------
# CONFIGURATION
#-------------------------------------------------------------------------------
my $search_dir  = $ARGV[0] // '.';
my $top_module  = $ARGV[1] // '';   # Optional: override auto-detection
my $snapshot    = 'ahb_sim_snapshot';
my $out_file    = "$search_dir/Makefile.generated";

$search_dir =~ s|[/\\]$||;

#-------------------------------------------------------------------------------
# STEP 1: Collect all .sv files
#-------------------------------------------------------------------------------
opendir(my $dh, $search_dir) or die "ERROR: Cannot open '$search_dir': $!\n";
my @sv_files = sort grep { /\.sv$/i && -f "$search_dir/$_" } readdir($dh);
closedir($dh);

die "ERROR: No .sv files found in '$search_dir'\n" unless @sv_files;

print "\n";
print "=" x 65 . "\n";
print "  MAKEFILE GENERATOR - AMBA AHB Project\n";
print "=" x 65 . "\n";
print "  Directory  : $search_dir\n";
print "  SV Files   : " . scalar(@sv_files) . " files found\n";
print "=" x 65 . "\n\n";

#-------------------------------------------------------------------------------
# STEP 2: Parse each file — detect module name, interfaces, instantiations
#-------------------------------------------------------------------------------
my %file_info;   # file => { module => name, is_interface => 0/1, is_tb => 0/1,
                 #           instantiates => [list of module names] }

foreach my $file (@sv_files) {
    my $filepath = "$search_dir/$file";
    open(my $fh, '<', $filepath) or do { warn "Cannot read $file\n"; next; };

    my %info = (
        module       => '',
        is_interface => 0,
        is_tb        => 0,
        instantiates => [],
    );

    my $in_block_comment = 0;

    while (my $line = <$fh>) {
        chomp $line;
        $line =~ s|//.*||;

        if ($in_block_comment) {
            $line =~ m|\*/| ? do { $line =~ s|.*\*/||; $in_block_comment = 0 } : next;
        }
        if ($line =~ m|/\*|) {
            $line =~ s|/\*.*\*/||g;
            if ($line =~ m|/\*|) { $line =~ s|/\*.*||; $in_block_comment = 1; }
        }

        # Detect interface definition
        if ($line =~ /^\s*interface\s+(\w+)/) {
            $info{is_interface} = 1;
            $info{module} = $1 unless $info{module};
        }

        # Detect module definition
        if ($line =~ /^\s*module\s+(\w+)\s*[#(;]?/ && $1 ne 'endmodule') {
            $info{module} = $1 unless $info{module};
        }

        # Detect testbench markers
        if ($line =~ /\$finish|\$stop|initial\s+begin|`timescale/) {
            $info{is_tb} = 1 if $line =~ /\$finish|\$stop/;
        }

        # Detect instantiations
        my $kw = join('|', qw(
            module endmodule interface endinterface package
            always initial generate if else for while begin end
            assign input output inout logic wire reg integer
            parameter localparam typedef enum struct function task
        ));
        if ($line =~ /^\s*(\w+)\s+\w+\s*\(/ && $1 !~ /^($kw)$/) {
            push @{ $info{instantiates} }, $1;
        }
        if ($line =~ /^\s*(\w+)\s*#\s*\(/ && $1 !~ /^($kw)$/) {
            push @{ $info{instantiates} }, $1;
        }
    }

    close($fh);
    $file_info{$file} = \%info;
}

#-------------------------------------------------------------------------------
# STEP 3: Classify files into layers
#-------------------------------------------------------------------------------
my (@interfaces, @submodules, @top_modules, @testbenches, @others);

# Build a set: which module names are instantiated by someone?
my %is_instantiated;
foreach my $file (keys %file_info) {
    for my $inst (@{ $file_info{$file}{instantiates} }) {
        $is_instantiated{$inst} = 1;
    }
}

foreach my $file (sort keys %file_info) {
    my $info     = $file_info{$file};
    my $mod_name = $info->{module};
    my $has_inst = scalar(@{ $info->{instantiates} }) > 0;

    if ($info->{is_interface}) {
        push @interfaces, $file;
    } elsif ($info->{is_tb}) {
        push @testbenches, $file;
    } elsif ($has_inst) {
        push @top_modules, $file;
    } elsif ($mod_name && !$is_instantiated{$mod_name}) {
        push @submodules, $file;
    } elsif ($mod_name) {
        push @submodules, $file;
    } else {
        push @others, $file;
    }
}

# Print classification result
sub print_layer {
    my ($label, @files) = @_;
    printf "  %-16s : %s\n", $label, (@files ? join(", ", @files) : "(none)");
}

print "[ FILE CLASSIFICATION ]\n";
print "-" x 65 . "\n";
print_layer("Interfaces",   @interfaces);
print_layer("Submodules",   @submodules);
print_layer("Top Modules",  @top_modules);
print_layer("Testbenches",  @testbenches);
print_layer("Others",       @others);
print "\n";

# Ordered compile list
my @ordered = (@interfaces, @submodules, @top_modules, @testbenches, @others);

# Auto-detect top module if not provided
unless ($top_module) {
    if (@testbenches) {
        $top_module = $file_info{ $testbenches[0] }{module} || 'top';
    } elsif (@top_modules) {
        $top_module = $file_info{ $top_modules[0] }{module} || 'top';
    } else {
        $top_module = 'top';
    }
}

print "  Auto-detected Top Module: $top_module\n\n";

#-------------------------------------------------------------------------------
# STEP 4: Generate the Makefile
#-------------------------------------------------------------------------------
my $sv_list = join(" \\\n\t\t", @ordered);
my $timestamp = localtime();

open(my $out, '>', $out_file) or die "ERROR: Cannot write '$out_file': $!\n";

print $out <<MAKEFILE;
#===============================================================================
# AUTO-GENERATED MAKEFILE
# Generated by : 2_makefile_gen.pl
# Generated on : $timestamp
# Directory    : $search_dir
# Files        : ${\scalar(@ordered)} .sv files
# Top Module   : $top_module
# NOTE: Review and rename to 'Makefile' after verification.
#===============================================================================

# Compiler and simulator (Vivado xsim toolchain)
XVLOG   = xvlog
XELAB   = xelab
XSIM    = xsim

# Simulation snapshot name
SNAPSHOT = $snapshot

# Top-level module for elaboration
TOP_MODULE = $top_module

# Source files — ordered by dependency (interfaces -> submodules -> top -> tb)
SRC_FILES = $sv_list

#-------------------------------------------------------------------------------
# Targets
#-------------------------------------------------------------------------------

.PHONY: all compile elaborate simulate gui clean help

all: simulate

## compile: Compile all SystemVerilog source files
compile:
\t\@echo "==========================================="
\t\@echo " Compiling \$(words \$(SRC_FILES)) SV files... "
\t\@echo "==========================================="
\t\$(XVLOG) -sv \$(SRC_FILES)

## elaborate: Link compiled modules with top-level
elaborate: compile
\t\@echo "==========================================="
\t\@echo " Elaborating: \$(TOP_MODULE)              "
\t\@echo "==========================================="
\t\$(XELAB) -debug typical \$(TOP_MODULE) -s \$(SNAPSHOT)

## simulate: Run the simulation (batch mode)
simulate: elaborate
\t\@echo "==========================================="
\t\@echo " Running Simulation...                    "
\t\@echo "==========================================="
\t\$(XSIM) \$(SNAPSHOT) -runall

## gui: Run the simulation in Vivado waveform GUI
gui: elaborate
\t\@echo "==========================================="
\t\@echo " Opening GUI Simulation...                "
\t\@echo "==========================================="
\t\$(XSIM) \$(SNAPSHOT) -gui

## clean: Remove all generated simulation artifacts
clean:
\t\@echo "==========================================="
\t\@echo " Cleaning simulation artifacts...         "
\t\@echo "==========================================="
\t\@if exist xsim.dir   rmdir /s /q xsim.dir
\t\@if exist webtalk*.log del /f /q webtalk*.log
\t\@if exist webtalk*.jou del /f /q webtalk*.jou
\t\@if exist xsim*.jou  del /f /q xsim*.jou
\t\@if exist xsim*.log  del /f /q xsim*.log
\t\@if exist xvlog*.log del /f /q xvlog*.log
\t\@if exist xvlog*.pb  del /f /q xvlog*.pb
\t\@if exist xelab*.log del /f /q xelab*.log
\t\@if exist xelab*.pb  del /f /q xelab*.pb

## help: Display available targets
help:
\t\@echo "Available targets:"
\t\@echo "  make compile    - Compile all SV files"
\t\@echo "  make elaborate  - Elaborate top module"
\t\@echo "  make simulate   - Run simulation (batch)"
\t\@echo "  make gui        - Run simulation (waveform GUI)"
\t\@echo "  make clean      - Remove simulation artifacts"
\t\@echo "  make help       - Show this help message"
MAKEFILE

close($out);

print "[ OUTPUT ]\n";
print "-" x 65 . "\n";
print "  Makefile written to: $out_file\n";
print "\n  Compile order used:\n";
for my $i (0 .. $#ordered) {
    printf "    %2d. %s\n", $i+1, $ordered[$i];
}
print "\n  To use: rename 'Makefile.generated' -> 'Makefile'\n";
print "         then run: make simulate\n\n";
