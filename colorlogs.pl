#!/usr/bin/perl
use strict;
use warnings;

# Requires module 'scriptname'. To install: 'sudo cpan' then run 'install scriptname' within cpan shell.
use scriptname;

# Colorlogs.pl - A PERL script to colorize log viewing
#
# Adapted by Nick Clarke from the version here:
#   http://www.resentment.org/projects/colorlogs/
#
##########################################################

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
my $configfile = scriptname::mydir . "/$ARGV[0].conf";

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

        my ($color_name, $pattern);

        if (/^\w+\s*regex:/) {
            ($color_name, $pattern) = split(/\s*regex:/);
        } elsif (/^\w+\s*text:/) {
            escape_regex_special_chars;
            ($color_name, $pattern) = split(/\s*text:/);
        } elsif (/^\w+\s*prefix:/) {
            escape_regex_special_chars;
            ($color_name, $pattern) = split(/\s*prefix:/);
            $pattern = "^" . $pattern;
        } elsif (/^\w+\s*suffix:/) {
            escape_regex_special_chars;
            ($color_name, $pattern) = split(/\s*suffix:/);
            $pattern = $pattern . "\$";
        } elsif (/^\w+\s*glob:/) {
            escape_non_glob_regex_special_chars;
            ($color_name, $pattern) = split(/\s*glob:/);
            $pattern =~ s/\*/\.\*/g;
            $pattern =~ s/\?/\./g;
        } else {
            print STDERR "ERROR: Unknown pattern type for config file entry '$_'" and exit(1);
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

# Parse STDIN
my $line;
my $default_color = $colorcodes{default};
LINE: while ($line=<STDIN>) {
    # Check against each pattern in the same order they appear in the config file.
    # Output line with color for first matching pattern found.
    foreach my $pattern (@patterns) {
        if ($line =~ /$pattern/) {
            print "$pattern_colorcodes{$pattern}$line$default_color";
            next LINE;
        }
    }

    # No matching pattern, use default
    print "$default_color$line";
}
