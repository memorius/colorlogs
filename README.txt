ColorLogs - A PERL script to colorize log viewing, command output etc
---------------------------------------------------------------------

Author:
-------
This version:
  adapted by Nick Clarke - memorius@gmail.com - http://planproof-fool.blogspot.com/
  http://github.com/memorius/colorlogs/

Original version:
  forked from v1.1 obtained from here, unknown license:
  http://www.resentment.org/projects/colorlogs/


Requirements
-------------
Requires (obviously) a terminal that understands color escape codes.

Requires perl 5.

Requires perl module 'scriptname'.
To install: 'sudo cpan' then run 'install scriptname' within cpan shell.


Usage:
------
To use: link colorlogs into your path, e.g.

ln -s ~/src/Colorlogs/colorlogs.pl ~/bin/colorlogs

You may also want to do the same with the 'color-ant' script (see below)

Now to run:

  <some-command-that-writes-stdout> | colorlogs <highlighting-config-file-name>

e.g. this will run ant, sending all console output (including stderr)
to colorlogs, and highlight with the rules in 'config/ant.conf'.

  ant dist 2>&1 | colorlogs ant

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


Customizing the highlighting
----------------------------
Create a file called <somename>.conf, in the 'config/' directory.

The rules are line-based and fairly self-explanatory,
see example files in 'config/' directory.

They are applied in order - the first rule to match a given line is used.

For available colors, see head of colorlogs.pl.


Using in scripts
----------------
The script will try to detect when it is not running in a terminal and will
just pipe its output verbatim if not - so it can still be used in pipelines,
when redirecting output to a file, etc.

Using the 'ant' and 'mvn' functions described above may not work in other scripts
- I haven't figured out how to make them be inherited.
So if you want color output when calling things indirectly,
you can use the 'script-utils/color-ant' and 'script-utils/color-mvn' scripts,
which do the same thing.
