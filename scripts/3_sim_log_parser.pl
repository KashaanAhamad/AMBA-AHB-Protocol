#!/usr/bin/perl
#===============================================================================
# Script  : 3_sim_log_parser.pl
# Author  : Kashaan
# Purpose : Parses simulation log files from Vivado xsim, Cadence Xcelium,
#           Synopsys VCS, or Mentor QuestaSim and produces a clean summary:
#           - ERROR / WARNING / FATAL / NOTE messages with timestamps
#           - Simulation time of each event
#           - Final Pass / Fail verdict
#
# Usage   : perl scripts/3_sim_log_parser.pl <logfile> [logfile2 ...]
#           Example: perl scripts/3_sim_log_parser.pl xsim.log
#
# Output  : Prints a structured report to STDOUT and writes a summary
#           to 'sim_report.txt' in the same directory as the script.
#===============================================================================

use strict;
use warnings;

#-------------------------------------------------------------------------------
# CONFIGURATION
#-------------------------------------------------------------------------------
my $report_file = "sim_report.txt";

# Colour codes for terminal output (disable if your terminal doesn't support it)
my %C = (
    reset   => "\e[0m",
    bold    => "\e[1m",
    red     => "\e[1;31m",
    yellow  => "\e[1;33m",
    green   => "\e[1;32m",
    cyan    => "\e[1;36m",
    magenta => "\e[1;35m",
    white   => "\e[1;37m",
);

# Disable colours on Windows cmd (enable on Git Bash / WSL / Linux)
my $use_colour = ($^O eq 'linux' || $ENV{TERM} // '' =~ /xterm|color|ansi/i) ? 1 : 0;
sub c { $use_colour ? $C{$_[0]} : '' }

#-------------------------------------------------------------------------------
# Validate arguments
#-------------------------------------------------------------------------------
if (!@ARGV) {
    die "USAGE: perl 3_sim_log_parser.pl <logfile> [logfile2 ...]\n"
      . "       Example: perl 3_sim_log_parser.pl xsim.log\n";
}

foreach my $logfile (@ARGV) {
    die "ERROR: File not found: '$logfile'\n" unless -f $logfile;
}

#-------------------------------------------------------------------------------
# Data structures to accumulate results across all log files
#-------------------------------------------------------------------------------
my @all_events;      # Each event: { time, severity, message, file, line_no }
my @pass_markers;    # Lines indicating PASS
my @fail_markers;    # Lines indicating FAIL
my $total_lines  = 0;
my $sim_end_time = 'N/A';

#-------------------------------------------------------------------------------
# Regex patterns — cover xsim, VCS, Xcelium, QuestaSim formats
#-------------------------------------------------------------------------------

# Simulation time extraction patterns
my @time_patterns = (
    # xsim:       Time: 100 ns
    qr/Time:\s*([\d\.]+\s*\w+)/i,
    # Generic:    #100
    qr/^#([\d]+)/,
    # VCS/Xcelium: at time 500ns
    qr/at\s+time\s+([\d\.]+\s*\w+)/i,
    # QuestaSim:  # 100 ns
    qr/^#\s+([\d\.]+\s*ns)/i,
);

# Severity detection: capture [TIME] SEVERITY: message
# Handles formats like:
#   ERROR: [XSIM 43-3382] ...
#   Warning: ...
#   FATAL: ...
#   ** Error: (vlog-13069) ...
#   xcelium: *E, ...
my @severity_patterns = (
    # Standard FATAL/ERROR/WARNING/NOTE
    { re => qr/\b(FATAL)\b\s*[:,-]?\s*(.*)/i,     sev => 'FATAL'   },
    { re => qr/\b(ERROR)\b\s*[:,-]?\s*(.*)/i,      sev => 'ERROR'   },
    { re => qr/\*{1,2}\s*(Error)\s*[:,-]?\s*(.*)/i,sev => 'ERROR'   },
    { re => qr/\b(WARNING)\b\s*[:,-]?\s*(.*)/i,    sev => 'WARNING' },
    { re => qr/\*{1,2}\s*(Warning)\b\s*[:,-]?(.*)/i,sev => 'WARNING'},
    { re => qr/\b(NOTE|INFO)\b\s*[:,-]?\s*(.*)/i,  sev => 'NOTE'    },
    # Xcelium style: *E, *W, *I
    { re => qr/\*E,\s*(.*)/,                        sev => 'ERROR'   },
    { re => qr/\*W,\s*(.*)/,                        sev => 'WARNING' },
    { re => qr/\*I,\s*(.*)/,                        sev => 'NOTE'    },
    # xsim assertion failures
    { re => qr/(Assertion\s+\w+\s+FAILED.*)/i,      sev => 'ERROR'   },
);

# Pass/Fail markers — covers common testbench idioms
my @pass_patterns = (
    qr/TEST\s+PASSED/i,
    qr/SIMULATION\s+PASSED/i,
    qr/ALL\s+TESTS?\s+PASS/i,
    qr/\$display.*PASS/i,
    qr/\bPASS\b/,
);

my @fail_patterns = (
    qr/TEST\s+FAILED/i,
    qr/SIMULATION\s+FAILED/i,
    qr/\$display.*FAIL/i,
    qr/\bFAIL\b/,
    qr/\$fatal/i,
);

#-------------------------------------------------------------------------------
# STEP 1: Parse each log file
#-------------------------------------------------------------------------------
foreach my $logfile (@ARGV) {
    print c('cyan') . "\nParsing: $logfile" . c('reset') . "\n";

    open(my $fh, '<', $logfile) or do {
        warn "WARNING: Cannot open '$logfile': $!\n";
        next;
    };

    my $current_time = '0 ns';
    my $line_no = 0;

    while (my $line = <$fh>) {
        chomp $line;
        $line_no++;
        $total_lines++;

        # Extract simulation time from this line if present
        foreach my $tp (@time_patterns) {
            if ($line =~ $tp) {
                $current_time = $1;
                $sim_end_time = $current_time;
                last;
            }
        }

        # Check for pass markers
        foreach my $pp (@pass_patterns) {
            if ($line =~ $pp) {
                push @pass_markers, { time => $current_time, line => $line, file => $logfile, line_no => $line_no };
                last;
            }
        }

        # Check for fail markers
        foreach my $fp (@fail_patterns) {
            if ($line =~ $fp) {
                push @fail_markers, { time => $current_time, line => $line, file => $logfile, line_no => $line_no };
                last;
            }
        }

        # Check for severity events
        foreach my $pat (@severity_patterns) {
            if ($line =~ $pat->{re}) {
                my $msg = $2 // $1 // $line;
                $msg =~ s/^\s+|\s+$//g;    # trim whitespace
                $msg = substr($msg, 0, 120) if length($msg) > 120;  # truncate long lines

                push @all_events, {
                    time    => $current_time,
                    sev     => $pat->{sev},
                    message => $msg,
                    file    => $logfile,
                    line_no => $line_no,
                };
                last;  # Only match one severity per line
            }
        }
    }

    close($fh);
    print "  Lines read: $line_no\n";
}

#-------------------------------------------------------------------------------
# STEP 2: Categorize events by severity
#-------------------------------------------------------------------------------
my %by_sev = (FATAL => [], ERROR => [], WARNING => [], NOTE => []);
foreach my $ev (@all_events) {
    push @{ $by_sev{ $ev->{sev} } }, $ev if exists $by_sev{ $ev->{sev} };
}

#-------------------------------------------------------------------------------
# STEP 3: Determine Pass/Fail verdict
#-------------------------------------------------------------------------------
my $verdict;
my $fatal_count   = scalar @{ $by_sev{FATAL} };
my $error_count   = scalar @{ $by_sev{ERROR} };
my $warning_count = scalar @{ $by_sev{WARNING} };
my $note_count    = scalar @{ $by_sev{NOTE} };

if ($fatal_count > 0 || scalar(@fail_markers) > 0) {
    $verdict = 'FAIL';
} elsif (scalar(@pass_markers) > 0 && $error_count == 0) {
    $verdict = 'PASS';
} elsif ($error_count == 0) {
    $verdict = 'PASS (no explicit marker, no errors)';
} else {
    $verdict = 'FAIL (errors detected)';
}

#-------------------------------------------------------------------------------
# STEP 4: Build the report (both to STDOUT and file)
#-------------------------------------------------------------------------------
my $sep  = "=" x 68;
my $dash = "-" x 68;

# Helper to print to both STDOUT and file
my @report_lines;
sub rprint {
    my $line = shift;
    push @report_lines, $line;
    print "$line\n";
}

rprint("");
rprint($sep);
rprint("  SIMULATION LOG PARSER REPORT - AMBA AHB Project");
rprint($sep);
rprint(sprintf "  Log Files     : %s", join(", ", @ARGV));
rprint(sprintf "  Total Lines   : %d", $total_lines);
rprint(sprintf "  Sim End Time  : %s", $sim_end_time);
rprint($sep);

# Summary counts
rprint("");
rprint("[ SUMMARY ]");
rprint($dash);
rprint(sprintf "  %-12s : %d", "FATAL",   $fatal_count);
rprint(sprintf "  %-12s : %d", "ERRORS",  $error_count);
rprint(sprintf "  %-12s : %d", "WARNINGS",$warning_count);
rprint(sprintf "  %-12s : %d", "NOTES",   $note_count);
rprint($dash);

# Verdict
my $verdict_str = "  VERDICT: $verdict";
rprint("");
rprint("[ FINAL VERDICT ]");
rprint($dash);
rprint($verdict_str);
rprint($dash);

# Print colour in terminal
if ($verdict =~ /^PASS/) {
    print c('green') . "\n  >>> SIMULATION: PASS <<<\n" . c('reset');
} else {
    print c('red')   . "\n  >>> SIMULATION: FAIL <<<\n" . c('reset');
}

# Print FATAL events
if ($fatal_count > 0) {
    rprint("");
    rprint("[ FATAL EVENTS ] ($fatal_count)");
    rprint($dash);
    foreach my $ev (@{ $by_sev{FATAL} }) {
        rprint(sprintf "  [%s] %s (line %d in %s)",
            $ev->{time}, $ev->{message}, $ev->{line_no}, $ev->{file});
    }
}

# Print ERROR events
if ($error_count > 0) {
    rprint("");
    rprint("[ ERROR EVENTS ] ($error_count)");
    rprint($dash);
    foreach my $ev (@{ $by_sev{ERROR} }) {
        rprint(sprintf "  [%s] %s (line %d in %s)",
            $ev->{time}, $ev->{message}, $ev->{line_no}, $ev->{file});
    }
}

# Print WARNING events
if ($warning_count > 0) {
    rprint("");
    rprint("[ WARNING EVENTS ] ($warning_count)");
    rprint($dash);
    foreach my $ev (@{ $by_sev{WARNING} }) {
        rprint(sprintf "  [%s] %s (line %d in %s)",
            $ev->{time}, $ev->{message}, $ev->{line_no}, $ev->{file});
    }
}

# Print NOTE/INFO events (limit to first 20 to avoid flooding)
if ($note_count > 0) {
    my $show_max = 20;
    rprint("");
    rprint("[ NOTE/INFO EVENTS ] ($note_count" .
           ($note_count > $show_max ? ", showing first $show_max" : "") . ")");
    rprint($dash);
    my $count = 0;
    foreach my $ev (@{ $by_sev{NOTE} }) {
        last if $count++ >= $show_max;
        rprint(sprintf "  [%s] %s", $ev->{time}, $ev->{message});
    }
    rprint("  ... and " . ($note_count - $show_max) . " more.") if $note_count > $show_max;
}

# Print explicit Pass/Fail markers from testbench $display
rprint("");
rprint("[ TESTBENCH PASS/FAIL MARKERS ]");
rprint($dash);
if (@pass_markers) {
    rprint("  PASS markers found:");
    foreach my $m (@pass_markers) {
        rprint(sprintf "    [%s] %s (line %d)", $m->{time}, $m->{line}, $m->{line_no});
    }
}
if (@fail_markers) {
    rprint("  FAIL markers found:");
    foreach my $m (@fail_markers) {
        rprint(sprintf "    [%s] %s (line %d)", $m->{time}, $m->{line}, $m->{line_no});
    }
}
if (!@pass_markers && !@fail_markers) {
    rprint("  No explicit PASS/FAIL markers found in log.");
    rprint("  Add \$display(\"TEST PASSED\") or \$display(\"TEST FAILED\") to testbench.");
}

rprint("");
rprint($sep);

#-------------------------------------------------------------------------------
# STEP 5: Write report to file
#-------------------------------------------------------------------------------
open(my $rout, '>', $report_file) or warn "Cannot write '$report_file': $!\n";
print $rout join("\n", @report_lines) . "\n";
close($rout);

print "\n  Report written to: $report_file\n";
print "=" x 68 . "\n\n";
