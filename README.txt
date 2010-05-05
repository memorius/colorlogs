To use: link colorlogs into your path, e.g.

ln -s ~/src/Colorlogs/colorlogs.pl ~/bin/colorlogs

You may also want to do the same with the 'color-ant' script (see below)


Requires perl module 'scriptname'.
To install: 'sudo cpan' then run 'install scriptname' within cpan shell.


Now to run:

  <some-command-that-writes-stdout> | colorlogs <highlighting-config-file-name>

e.g. this will run ant, sending all console output (including stderr)
to colorlogs, and highlight with the rules in 'config/ant.conf'.

  ant dist 2>&1 | colorlogs ant


The rules are line-based and fairly self-explanatory,
see example files in 'config/' directory.

For available colors, see head of colorlogs.pl.


To make ant and maven provide colorlogs-processed output by default,
using the colour patterns in ant.conf and maven.conf, I have this in my .bashrc:

# Alias ant to provide colored output.
function ant() {
    command ant "$@" 2>&1 | colorlogs ant
}

# Alias maven to provide colored output.
function mvn() {
    command mvn "$@" 2>&1 | colorlogs maven
}


Using these aliases in other scripts may not work properly
- I haven't figured out how to make these 'ant' and 'mvn' functions
be inherited when running other scripts. So if you want color output when
calling things indirectly, you can use the the 'color-ant' and 'color-mvn'
scripts in this directory, which do the same thing.
