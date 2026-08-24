#!/usr/bin/perl
#===============================================================================
# Script  : 1_module_checker.pl
# Author  : Kashaan
# Purpose : Scans all .sv files in a directory and reports every module that
#           is instantiated but never defined — helps catch missing source files.
#
# Usage   : perl scripts/1_module_checker.pl [directory]
#           If no directory is given, it defaults to the current directory.
#
# Output  : Prints a report to STDOUT listing:
#           - All defined modules
#           - All instantiated modules
#           - Modules that are instantiated but missing a definition (ERRORS)
#===============================================================================

use strict;
use warnings;

#-------------------------------------------------------------------------------
# CONFIGURATION
#-------------------------------------------------------------------------------
my $search_dir = $ARGV[0] // '.';
$search_dir =~ s|[/\\]$||;

#-------------------------------------------------------------------------------
# STEP 1: Collect all .sv files
#-------------------------------------------------------------------------------
opendir(my $dh, $search_dir) or die "ERROR: Cannot open directory '$search_dir': $!\n";
my @sv_files = grep { /\.sv$/i && -f "$search_dir/$_" } readdir($dh);
closedir($dh);

if (!@sv_files) {
    die "ERROR: No .sv files found in '$search_dir'\n";
}

print "\n";
print "=" x 65 . "\n";
print "  MODULE INSTANTIATION CHECKER - AMBA AHB Project\n";
print "=" x 65 . "\n";
print "  Directory : $search_dir\n";
print "  SV Files  : " . scalar(@sv_files) . " files found\n";
print "=" x 65 . "\n\n";

#-------------------------------------------------------------------------------
# STEP 2: Parse each file for module DEFINITIONS and INSTANTIATIONS
#-------------------------------------------------------------------------------
my %defined_modules;
my %instantiated_modules;

foreach my $file (sort @sv_files) {
    my $filepath = "$search_dir/$file";

    open(my $fh, '<', $filepath) or do {
        warn "WARNING: Could not read '$file': $!\n";
        next;
    };

    my $in_block_comment = 0;

    while (my $line = <$fh>) {
        chomp $line;

        # Remove single-line comments
        $line =~ s|//.*||;

        # Handle block comments
        if ($in_block_comment) {
            if ($line =~ m|\*/|) {
                $line =~ s|.*\*/||;
                $in_block_comment = 0;
            } else {
                next;
            }
        }
        if ($line =~ m|/\*|) {
            $line =~ s|/\*.*\*/||g;
            if ($line =~ m|/\*|) {
                $line =~ s|/\*.*||;
                $in_block_comment = 1;
            }
        }

        # Detect MODULE DEFINITIONS: module module_name
        if ($line =~ /^\s*module\s+(\w+)\s*[#(;]?/) {
            my $mod_name = $1;
            if ($mod_name ne 'endmodule') {
                $defined_modules{$mod_name} = $file;
            }
        }

        # Detect MODULE INSTANTIATIONS: ModuleName instance_name (
        my $kw_pattern = join('|', qw(
            module endmodule interface endinterface package endpackage
            program class function task always initial generate
            if else for while begin end case endcase
            assign input output inout logic wire reg integer
            parameter localparam typedef enum struct
        ));

        if ($line =~ /^\s*(\w+)\s+(\w+)\s*\(/) {
            my ($type_name) = ($1);
            unless ($type_name =~ /^($kw_pattern)$/) {
                push @{ $instantiated_modules{$type_name} }, $file
                    unless grep { $_ eq $file } @{ $instantiated_modules{$type_name} };
            }
        }

        # Catch parameterized instantiation: ModuleName #( ...
        if ($line =~ /^\s*(\w+)\s*#\s*\(/) {
            my $type_name = $1;
            unless ($type_name =~ /^($kw_pattern)$/) {
                push @{ $instantiated_modules{$type_name} }, $file
                    unless grep { $_ eq $file } @{ $instantiated_modules{$type_name} };
            }
        }
    }

    close($fh);
}

#-------------------------------------------------------------------------------
# STEP 3: Find modules used but never defined
#-------------------------------------------------------------------------------
my @missing_modules;
foreach my $mod (sort keys %instantiated_modules) {
    unless (exists $defined_modules{$mod}) {
        push @missing_modules, $mod;
    }
}

#-------------------------------------------------------------------------------
# STEP 4: Print the Report
#-------------------------------------------------------------------------------

print "[ DEFINED MODULES ]\n";
print "-" x 65 . "\n";
printf "  %-40s | %s\n", "Module Name", "Defined In File";
print "-" x 65 . "\n";
foreach my $mod (sort keys %defined_modules) {
    printf "  %-40s | %s\n", $mod, $defined_modules{$mod};
}
print "\n  Total: " . scalar(keys %defined_modules) . " module(s) defined.\n\n";

print "[ INSTANTIATED MODULES ]\n";
print "-" x 65 . "\n";
printf "  %-40s | %s\n", "Module Name", "Used In File(s)";
print "-" x 65 . "\n";
foreach my $mod (sort keys %instantiated_modules) {
    my $files_str = join(", ", @{ $instantiated_modules{$mod} });
    printf "  %-40s | %s\n", $mod, $files_str;
}
print "\n  Total: " . scalar(keys %instantiated_modules) . " unique module(s) instantiated.\n\n";

print "=" x 65 . "\n";
if (@missing_modules) {
    print "  [!] MISSING MODULE DEFINITIONS FOUND\n";
    print "=" x 65 . "\n";
    print "  Modules instantiated but with NO .sv definition in this directory:\n\n";
    foreach my $mod (@missing_modules) {
        my $files_str = join(", ", @{ $instantiated_modules{$mod} });
        printf "  %-40s <- used in: %s\n", "MISSING: $mod", $files_str;
    }
    print "\n  Total Missing: " . scalar(@missing_modules) . " module(s)\n";
    print "=" x 65 . "\n";
    print "\n  ACTION: Check if these .sv files exist or if names are misspelled.\n\n";
} else {
    print "  [OK] ALL INSTANTIATED MODULES ARE DEFINED IN REPO\n";
    print "=" x 65 . "\n";
    print "  No missing module definitions detected. All clear!\n\n";
}
