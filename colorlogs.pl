#!/usr/bin/perl -T
use strict;
use warnings;
use re 'taint';

# Requires module 'scriptname'. To install: 'sudo cpan' then run 'install scriptname' within cpan shell.
use scriptname;

# colorlogs.pl - A PERL script to colorize log viewing, command output etc
#
# Author:
#   This version:
#     adapted by Nick Clarke - memorius@gmail.com - http://planproof-fool.blogspot.com/
#     http://github.com/memorius/colorlogs/
#
#   Original version:
#     forked from v1.1 obtained from here, unknown license:
#     http://www.resentment.org/projects/colorlogs/
#
# This program is free software. It comes without any warranty, to
# the extent permitted by applicable law. You can redistribute it
# and/or modify it under the terms of the Do What The Fuck You Want
# To Public License, Version 2, as published by Sam Hocevar. See
# WTFPL.txt for more details.
#
##########################################################

# How long to wait for a newline before outputting buffered partial lines unformatted
my $unterminated_line_timeout_seconds = 1;

# Create the colorcodes Assoc. Array
my %colorcodes = (
    'black'              => "\033[30m",
    'red'                => "\033[31m",
    'green'              => "\033[32m",
    'yellow'             => "\033[33m",
    'blue'               => "\033[34m",
    'magenta'            => "\033[35m",
    'cyan'               => "\033[36m",
    'white'              => "\033[37m",
    'brightblack'        => "\033[01;30m",
    'brightred'          => "\033[01;31m",
    'brightgreen'        => "\033[01;32m",
    'brightyellow'       => "\033[01;33m",
    'brightblue'         => "\033[01;34m",
    'brightmagenta'      => "\033[01;35m",
    'brightcyan'         => "\033[01;36m",
    'brightwhite'        => "\033[01;37m",
    'underlineblack'     => "\033[04;30m",
    'underlinered'       => "\033[04;31m",
    'underlinegreen'     => "\033[04;32m",
    'underlineyellow'    => "\033[04;33m",
    'underlineblue'      => "\033[04;34m",
    'underlinemagenta'   => "\033[04;35m",
    'underlinecyan'      => "\033[04;36m",
    'underlinewhite'     => "\033[04;37m",
    'blinkingblack'      => "\033[05;30m", 
    'blinkingred'        => "\033[05;31m", 
    'blinkinggreen'      => "\033[05;32m", 
    'blinkingyellow'     => "\033[05;33m", 
    'blinkingblue'       => "\033[05;34m", 
    'blinkingmagenta'    => "\033[05;35m", 
    'blinkingcyan'       => "\033[05;36m", 
    'blinkingwhite'      => "\033[05;37m", 
    'backgroundblack'    => "\033[07;30m",
    'backgroundred'      => "\033[07;31m",
    'backgroundgreen'    => "\033[07;32m",
    'backgroundyellow'   => "\033[07;33m",
    'backgroundblue'     => "\033[07;34m",
    'backgroundmagenta'  => "\033[07;35m",
    'backgroundcyan'     => "\033[07;36m",
    'backgroundwhite'    => "\033[07;37m", 
    'default'            => "\033[0m"
);

# Convert to a regex by replacing regex-meaningful chars
sub escape_regex_special_chars {
    s/\~/\\\~/g;
    s/\!/\\\!/g;
    s/\@/\\\@/g;
    s/\#/\\\#/g;
    s/\$/\\\$/g;
    s/\%/\\\%/g;
    s/\^/\\\^/g;
    s/\&/\\\&/g;
    s/\*/\\\*/g;
    s/\-/\\\-/g;
    s/\_/\\\_/g;
    s/\=/\\\=/g;
    s/\+/\\\+/g;
    s/\[/\\\[/g;
    s/\]/\\\]/g;
    s/\{/\\\{/g;
    s/\}/\\\}/g;
    s/\|/\\\|/g;
    s/\"/\\\"/g;
    s/\;/\\\;/g;
    s/\</\\\</g;
    s/\>/\\\>/g;
    s/\?/\\\?/g;
    s/\(/\\\(/g;
    s/\)/\\\)/g;
    s/\`/\\\`/g;
    s/\'/\\\'/g;
    s/\./\\\./g;
}

sub escape_non_glob_regex_special_chars {
    s/\~/\\\~/g;
    s/\!/\\\!/g;
    s/\@/\\\@/g;
    s/\#/\\\#/g;
    s/\$/\\\$/g;
    s/\%/\\\%/g;
    s/\^/\\\^/g;
    s/\&/\\\&/g;
    s/\-/\\\-/g;
    s/\_/\\\_/g;
    s/\=/\\\=/g;
    s/\+/\\\+/g;
    s/\[/\\\[/g;
    s/\]/\\\]/g;
    s/\{/\\\{/g;
    s/\}/\\\}/g;
    s/\|/\\\|/g;
    s/\"/\\\"/g;
    s/\;/\\\;/g;
    s/\</\\\</g;
    s/\>/\\\>/g;
    s/\(/\\\(/g;
    s/\)/\\\)/g;
    s/\`/\\\`/g;
    s/\'/\\\'/g;
    s/\./\\\./g;
}

# First commandline argument is the name of a config file from the same directory as this script,
# without the 'conf' extension
my $configfile = scriptname::mydir . "/config/$ARGV[0].conf";

print STDERR "ERROR: Could not open config file '$configfile': $!" and exit(1)
    if (! -f $configfile);

# Regexes to match against the log text, in the order they are defined in the config file
my @patterns;

# Mapping from pattern to color codes
my %pattern_colorcodes;

# Read config
open(CFG, $configfile);
    while (<CFG>) {
        chomp;
        # Chomp out the leading whitespace
        s/^\s*//;
        # Leave trailing whitespace alone because we might want to match it in patterns
        # s/\s*$//;

        # Skip comment lines
        next if (/^:/);
        # Skip empty lines
        next if (/^\s*$/);

        # 'i' prefix on the pattern type = case insensitive
        my $case_sensitive = 1;
        if (/^\w+\s*i(?:regex|text|prefix|suffix|glob):/) {
            $case_sensitive = 0;
        }

        # Handle different pattern types
        my ($color_name, $pattern);
        if (/^\w+\s*i?regex:/) {
            ($color_name, $pattern) = split(/\s*i?regex:/, $_, 2);
        } elsif (/^\w+\s*i?text:/) {
            escape_regex_special_chars;
            ($color_name, $pattern) = split(/\s*i?text:/, $_, 2);
        } elsif (/^\w+\s*i?prefix:/) {
            escape_regex_special_chars;
            ($color_name, $pattern) = split(/\s*i?prefix:/, $_, 2);
            $pattern = "^" . $pattern;
        } elsif (/^\w+\s*i?suffix:/) {
            escape_regex_special_chars;
            ($color_name, $pattern) = split(/\s*i?suffix:/, $_, 2);
            $pattern = $pattern . "\$";
        } elsif (/^\w+\s*i?glob:/) {
            escape_non_glob_regex_special_chars;
            ($color_name, $pattern) = split(/\s*i?glob:/, $_, 2);
            $pattern =~ s/\*/\.\*/g;
            $pattern =~ s/\?/\./g;
        } else {
            print STDERR "ERROR: Unknown pattern type for config file entry '$_'" and exit(1);
        }

        # Add case-insensitive regex modifier if required
        unless ($case_sensitive) {
            $pattern = "(?i)" . $pattern
        }

        $color_name = lc($color_name);
        if ($pattern) {
            my $colorcode = $colorcodes{$color_name};
            if ($colorcode) {
                push(@patterns, $pattern);
                $pattern_colorcodes{$pattern} = $colorcode;
            } else {
                print STDERR "ERROR: Unknown color name '$color_name' for config file entry '$_'" and exit(1);
            }
        }
    } # while
close(CFG);

my $line = '';
my $default_color = $colorcodes{default};

sub colorize_and_output_line {
    # Check against each pattern in the same order they appear in the config file.
    # Output line with color for first matching pattern found.
    foreach my $pattern (@patterns) {
        if ($line =~ /$pattern/) {
            syswrite(STDOUT, "$pattern_colorcodes{$pattern}$line$default_color");
            $line = '';
            return;
        }
    }

    # No matching pattern, use default
    syswrite(STDOUT, "$default_color$line");
    $line = '';
}

if ( -t STDOUT ) {
    # Output is to a terminal.
    # Read STDIN and output lines with appropriate formatting
    my $char;
    my $rin = "";
    my $rout;
    vec ($rin, fileno(STDIN), 1) = 1;

    # We read one character at a time - inefficient, but allows us to sensibly handle 'prompt' lines
    # rather than waiting indefinitely for their newline - see below.
    CHAR: while (1) {
        # Check whether any input is available to read, waiting for timeout otherwise
        if (select(($rout = $rin), undef, undef, $unterminated_line_timeout_seconds)) {
            # Read one char
            unless (sysread(STDIN, $char, 1)) {
                # End of file - finished
                colorize_and_output_line;
                last;
            }
            # Got a character
            $line = $line . $char;
            if ($char eq "\n") {
                # Got a whole line.
                colorize_and_output_line;
            }
        } elsif ($line ne '') {
            # Select timed out with no input, but we have some accumulated chars hidden in our buffer:
            # i.e. no newline has appeared after waiting a while.
            # Happens when output contains prompts for the user, with the cursor waiting at the end of the line for user input.
            # Output the accumulated chars, running formatting on what we actually have,
            # rather than waiting indefinitely for the newline while the prompt text is hidden in our buffer.
            # XXX: if this happens in the middle of a line due to slow input, it may misapply colors - too bad.
            colorize_and_output_line;
        }
    }
} else {
    # Output is piped or redirected - disable colors, use line-based buffered IO
    while ($line = <STDIN>) {
        print "$line";
    }
}
