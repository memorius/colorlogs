Colorlogs v1.1

This script was written for easier watching of my logs
so that at a simple glance you can generally see what 
is generally going on by the color codes.

This script was originally written to he used to view 
logs "on the fly" via a tail -f but since this script
just color codes whatever is passed to it via STDIN,
you can view older logs in color as well.

CHANGELOG:
 - code rewrite 
 - added color Modifiers 
   (bright, underline, blinking, background)
 - changed default config file location to /etc/
 - made config file more whitespace tolerant
 - added special character checking for config
   file so now users can type exactally what they
   want to look for instead of having to denote 
   special characters with a \


INSTALLATION:
Installation of this script is VERY simple. Simply edit
the config file (colorlogs.conf) (comments on how to edit
the conf file are documented in comments in the conf file.
Then simply place the config file at /etc/colorlogs.conf
and colorlogs.pl in /usr/local/sbin/colorlogs.pl
and edit your /etc/rc.d/rc.local to include the following line
  tail -f /var/log/messages|/usr/local/sbin/colorlogs.pl>>/dev/tty12&

If you have any questions/comments/suggestions, please email
J-Dog <J-Dog@Resentment.org>

For more documentation on how this script works, please
visit the homepage at www.resentment.org/projects/colorlogs/
