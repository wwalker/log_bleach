# LogBleach

Makes the cruft in your logs disappear.

    log_bleach /var/log/my_custom_log

This will output to stdout the _relevant_ log file lines

# How it works

log_bleach begins knowning *nothing* about your log file.  You simply tell
log_bleach which lines, straight from the log file, that you consider
irrelevant.

### Create a new log file type in log_bleach

    # Add the new type
    log_bleach --add-type=secure
    # Add a regex to match filenames for this file type
    log_bleach --add-pattern='secure' --type=secure
    log_bleach --add-pattern='secure-.*' --type=secure    # logrotated files
    # Add a filter name under which to store the match template lines (optional
    # as <type-name>-basic will be created if no filter name exists when
    # first needed)
    log_bleach --add-filter=secure-basic --type=secure

### Teach log_bleach about your new file type:
    log_bleach /var/log/secure | head
    Jun 10 07:39:05 speedy gdm-password][11697]: pam_unix(gdm-password:session): session opened for user wwalker by (unknown)(uid=0)
    Jun 10 07:39:05 speedy gdm-launch-environment][1402]: pam_unix(gdm-launch-environment:session): session closed for user gdm
    Jun 10 07:39:05 speedy polkitd[974]: Unregistered Authentication Agent for unix-session:1 (system bus name :1.55, object path /org/freedesktop/PolicyKit1/AuthenticationAgent, locale en_US.UTF-8) (disconnected from bus)
    Jun 10 07:39:08 speedy polkitd[974]: Registered Authentication Agent for unix-session:961 (system bus name :1.1987 [/usr/libexec/polkit-gnome-authentication-agent-1], object path /org/gnome/PolicyKit1/AuthenticationAgent, locale en_US.UTF-8)
    Jun 10 11:16:55 speedy sudo:  wwalker : TTY=pts/15 ; PWD=/home/wwalker ; USER=root ; COMMAND=/bin/mount -t cifs -o user=wwalker,domain=commstor //hqdata/groups /mnt/hqdata
    Jun 10 11:16:59 speedy sudo:  wwalker : TTY=pts/15 ; PWD=/home/wwalker ; USER=root ; COMMAND=/bin/mount -o soft,intr devshare:/array1 /mnt/devshare

Those all look irrelevant...

    log_bleach --add-content /var/log/secure
    Jun 10 13:42:30 speedy xscreensaver: pam_unix(xscreensaver:auth): conversation failed
    Jun 10 13:42:30 speedy xscreensaver: pam_unix(xscreensaver:auth): auth could not identify password for [wwalker]
    Jun 11 01:10:01 speedy polkitd[20910]: Loading rules from directory /etc/polkit-1/rules.d
    Jun 11 01:10:01 speedy polkitd[20910]: Loading rules from directory /usr/share/polkit-1/rules.d

The lines we taught it, and others like them are now quietly discarded by
log_bleach.

Keep running "log_bleach" and then "log_bleach --add-content" until "log_bleach"
is quietly discarding all the irrelevant lines from your log; leaving you with
only the relevant lines to analyze.

# INSTALL

1. Have Ruby available (even 1.8.7) with YAML (should be built in with any Ruby version).
1. Have perl 5.x available, install perl's YAML library (yum install perl-YAML).
1. Install it:

    ```
    git clone https://github.com/wwalker/log_bleach.git
    cd log_bleach
    ln -s `pwd`/log_bleach ~/bin/
    ln -s `pwd`/update_log_filter ~/bin/
    ```

That's it, it's installed.  (Assumes that ~/bin is in your PATH)

# CAVEATS

So, the example above wouldn't really work as advertised.  Some problems require more complex patterns than just cut and paste.  For these we have a few special patterns (still no regex knowledge required):

* PATTERN_WORD
* PATTERN_END_MATCHING
* PATTERN_MATCH_ALL
* PATTERN_FILE_PATH
* PATTERN_EMAIL
* PATTERN_LITERAL (not yet implemented)

## PATTERN_WORD

PATTERN_WORD will be replaced with a regex that will match any simple word.

Why do we need it?  Consider these:

    Jun 15 19:54:10 ut su: pam_unix(su:session): session opened for user wwalker by (uid=0)
    Jun 15 19:55:02 ut su: pam_unix(su:session): session opened for user postgres by (uid=0)
    Jun 15 19:59:10 ut su: pam_unix(su:session): session opened for user root by (uid=0)

Rather than cut and paste multiple times, you can just cut and paste one line:

    Jun 15 19:54:10 ut su: pam_unix(su:session): session opened for user PATTERN_WORD by (uid=0)


You could also catch open and close messages with one line; however, in most cases I would have separate lines:

    Jun 15 19:54:10 ut su: pam_unix(su:session): session PATTERN_WORD for user PATTERN_WORD by (uid=0)

## PATTERN_END_MATCHING

PATTERN_END_MATCHING means that nothing from this point in the line to the end should be checked for matching.

Why?  Considering the following actual log lines.  Without some special logic, log_bleach can't figure out that the ===s series should be allowed to be an arbitrary number of characters.

    ==  MigrateLogArchiveToDataPartition: migrated (1.1704s) ======================
    ==  MigrateLogArchiveToDataPartition: migrating ===============================
    ==  RemoveFiberConfig: migrated (0.0000s) =====================================
    ==  RemoveFiberConfig: migrating ==============================================
    ==  RemoveKernelRPM: migrated (0.0805s) =======================================
    ==  RemoveKernelRPM: migrated (3.6702s) =======================================
    ==  RemoveKernelRPM: migrating ================================================

You could use the following:

    ==  PATTERN_WORD: migrating =PATTERN_END_MATCHING
    ==  PATTERN_WORD: migrated (0.1034s) =PATTERN_END_MATCHING

## PATTERN_LITERAL

PATTERN_LITERAL is formatted like an HTML/XML tag.  It will prevent the text it surrounds from being replaced with a pattern match, instead requiring that the exact text occur in a line in order to match and be ignored.

Why?  Consider the following actual log lines; we can ignore every time we are monitoring 0 jobs, but we can't ignore when there are jobs to monitor:

    May 02 13:47:50 EDT archive_verify[2146]:(INFO) Monitoring 0 verify jobs
    May 02 13:48:00 EDT archive_verify[2146]:(INFO) Monitoring 0 verify jobs
    May 02 13:48:10 EDT archive_verify[2146]:(INFO) Monitoring 0 verify jobs
    May 02 13:48:20 EDT archive_verify[2146]:(INFO) Monitoring 0 verify jobs
    May 02 13:48:30 EDT archive_verify[2146]:(INFO) Monitoring 0 verify jobs
    May 02 13:48:41 EDT archive_verify[2146]:(INFO) Monitoring 7 verify jobs

You could use the following:

    May 02 13:47:50 EDT archive_verify[2146]:(INFO) <PATTERN_LITERAL>Monitoring 0<PATTERN_LITERAL/> verify jobs

# USAGE

  Get the usage info:

    log_bleach --help

  Create your initial .log_bleach directory structure:

    log_bleach --init
    log_bleach --show-types

  Create a new log file type:

    log_bleach --add-type=secure
    log_bleach --show-types

  Add RegEx(!) patterns for filename to type mapping (NOT file globs!)

    log_bleach --add-pattern='secure' --type=secure
    log_bleach --add-pattern='secure-.*' --type=secure
    log_bleach --add-pattern='secure\..*' --type=secure
    log_bleach --show-patterns --type=secure
    log_bleach --add-filter=secure_log_irrelevant --type=secure
    log_bleach --show-filters --type=secure

  Now let's see what is important in the secure log:

  Review 20 lines and decide what is irrelevant

    log_bleach /var/log/secure | head
    Jun  2 03:44:10 ut su: pam_unix(su:session): session opened for user postgres by (uid=0)
    Jun  2 03:44:10 ut su: pam_unix(su:session): session closed for user postgres
    Jun  2 03:44:10 ut sshd[30975]: Connection closed by 71.19.156.39
    Jun  2 03:44:12 ut saslauthd[8507]: pam_unix(smtp:auth): check pass; user unknown
    Jun  2 03:44:12 ut saslauthd[8507]: pam_unix(smtp:auth): authentication failure; logname= uid=0 euid=0 tty= ruser= rhost=•
    Jun  2 03:44:12 ut saslauthd[8507]: pam_succeed_if(smtp:auth): error retrieving information about user academia


  Make them disappear:

    log_bleach --add-content --filter=secure_log_irrelevant --type=secure
    Jun  2 03:44:10 ut su: pam_unix(su:session): session opened for user PATTERN_WORD by (uid=0)
    Jun  2 03:44:10 ut su: pam_unix(su:session): session closed for user PATTERN_WORD
    Jun  2 03:44:10 ut sshd[30975]: Connection closed by 71.19.156.39
    Jun  2 03:44:12 ut saslauthd[8507]: pam_unix(smtp:auth): check pass; user unknown
    Jun  2 03:44:12 ut saslauthd[8507]: pam_unix(smtp:auth): authentication failure; logname= uid=0 euid=0 tty= ruser= rhost=•
    Jun  2 03:44:12 ut saslauthd[8507]: pam_succeed_if(smtp:auth): error retrieving information about user PATTERN_WORD

    # Or open the filter in $VISUAL || $EDITOR || vim
    log_bleach --add-content --filter=secure_log_irrelevant --type=secure --edit
    

  You see that some of the words (usernames here) had to be manually replaced with PATTERN_WORD.  That is as hard as it gets.

  Now we see if it worked:

    log_bleach /var/log/secure | head
    Jun  2 03:44:10 ut su: pam_unix(su:session): session opened for user postgres by (uid=0)
    Jun  2 03:45:02 ut su: pam_unix(su:session): session opened for user postgres by (uid=0)
    Jun  2 03:45:11 ut sshd[31356]: PAM 1 more authentication failure; logname= uid=0 euid=0 tty=ssh ruser= rhost=222.134.65.120  user=root
    Jun  2 03:49:10 ut su: pam_unix(su:session): session opened for user postgres by (uid=0)
    Jun  2 03:50:02 ut su: pam_unix(su:session): session opened for user postgres by (uid=0)
    Jun  2 03:54:10 ut su: pam_unix(su:session): session opened for user postgres by (uid=0)
    Jun  2 03:55:01 ut su: pam_unix(su:session): session opened for user postgres by (uid=0)
    Jun  2 03:56:16 ut sshd[32466]: PAM 1 more authentication failure; logname= uid=0 euid=0 tty=ssh ruser= rhost=222.134.65.120  user=root
    Jun  2 03:59:10 ut su: pam_unix(su:session): session opened for user postgres by (uid=0)
    Jun  2 04:00:02 ut su: pam_unix(su:session): session opened for user postgres by (uid=0)


  It worked we are filtering out lots of lines that looked similar to the ones that we entered as ignorable.  So we exclude some more:

    log_bleach --add-content --filter=secure_log_irrelevant --type=secure
    Jun  2 03:44:10 ut su: pam_unix(su:session): session opened for user PATTERN_WORD by (uid=0)
    Jun  2 03:45:11 ut sshd[31356]: PAM 1 more authentication failure; logname= uid=0 euid=0 tty=ssh ruser= rhost=PATTERN_WORD  user=PATTERN_WORD


  We check again with "log_bleach /var/log/secure | head" and repeat.  Once we have entered 38 lines.  Only 38!  Just cut and paste with about one word per line replaced with PATTERN_WORD.  10 minutes?
  And this is what we get:

    [wwalker@ut ~] [] $ log_bleach /var/log/secure
    Jun  2 19:23:01 ut sshd[11983]: error: RSA_public_decrypt failed: error:0407006A:lib(4):func(112):reason(106)
    Jun  2 23:19:56 ut sudo:  wwalker : TTY=pts/6 ; PWD=/home/wwalker/git ; USER=root ; COMMAND=/bin/su -
    Jun  2 23:40:01 ut sudo:  wwalker : TTY=pts/6 ; PWD=/home/wwalker ; USER=root ; COMMAND=/bin/chmod +r /var/log/secure
    Jun  3 00:08:41 ut sudo:  wwalker : TTY=pts/6 ; PWD=/home/wwalker ; USER=root ; COMMAND=/bin/chmod +r /var/log/secure-20130602
    Jun  3 00:17:07 ut sudo:  wwalker : TTY=pts/6 ; PWD=/home/wwalker ; USER=root ; COMMAND=/bin/chmod +r log_bleach /var/log/secure-20130526
    [wwalker@ut ~] [] $ log_bleach /var/log/secure-20130602
    May 27 02:10:54 ut sshd[2604]: Received disconnect from 113.165.106.243: 3: com.jcraft.jsch.JSchException: Auth cancel
    May 29 09:50:40 ut sshd[32763]: error: RSA_public_decrypt failed: error:0407006A:lib(4):func(112):reason(106)
    May 31 03:18:24 ut sshd[19773]: Received disconnect from 118.68.166.17: 3: java.net.SocketTimeoutException: Read timed out
    May 31 03:18:37 ut sshd[19782]: Received disconnect from 118.68.166.17: 3: java.net.SocketTimeoutException: Read timed out
    May 31 03:18:50 ut sshd[19788]: Received disconnect from 118.68.166.17: 3: java.net.SocketTimeoutException: Read timed out
    May 31 03:18:58 ut sshd[19794]: Received disconnect from 118.68.166.17: 3: java.net.SocketTimeoutException: Read timed out
    May 31 09:55:45 ut sshd[19159]: error: RSA_public_decrypt failed: error:0407006A:lib(4):func(112):reason(106)
    May 31 16:45:29 ut sshd[8670]: error: RSA_public_decrypt failed: error:0407006A:lib(4):func(112):reason(106)
    Jun  1 13:12:53 ut webmin[3246]: Timeout of session for root
    Jun  1 21:04:00 ut sshd[10192]: error: RSA_public_decrypt failed: error:0407006A:lib(4):func(112):reason(106)
    Jun  1 21:06:25 ut sshd[10732]: error: RSA_public_decrypt failed: error:0407006A:lib(4):func(112):reason(106)
    Jun  1 21:07:10 ut sshd[10819]: error: RSA_public_decrypt failed: error:0407006A:lib(4):func(112):reason(106)
    [wwalker@ut ~] [] $ wc -l /var/log/secure /var/log/secure-20130602
       5462 /var/log/secure
      35693 /var/log/secure-20130602
      41155 total
    [wwalker@ut ~] [] $

  Now we've stripped down 41,000+ lines to 17 relevant lines.  In 10 minutes.

  Next time we need to look at /var/log/secure on _any_ host, we can use our source file (~/.log_bleach/source/secure_log_irrelevant) and get the same results instantly.

  log_bleach will work with any log file, not just syslog files, not just system files.

  You teach log_bleach about each log file type you have.  log_bleach brings almost nothing pre-learned to the game.

  log_bleach does know a few things to generalize, that's all:

    IP_ADDRESS                 = '\b(?:[012]?\d?\d\.){3}[012]?\d?\d\b'
    TS_SYSLOG                  = '(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [ 0123][0-9] \d\d:\d\d:\d\d'
    TS_SYSLOG_WITH_WEEKDAY     = '(?:Sun|Mon|Tue|Wed|Thu|Fri|Sat)\s+' + TS_SYSLOG
    SYSLOG_PREFIX              = TS_SYSLOG + ' \S+ \S+(?:\[\d+\])?: '
    ISODATE                    = '\d\d\d\d-\d\d-\d\d[ T]\d\d:\d\d:\d\d'
    ISODATE_WITH_USEC          = '\d\d\d\d-\d\d-\d\d[ T]\d\d:\d\d:\d\d.\d\d\d\d\d\d'
    RN_LOG_PREFIX              = ISODATE_WITH_USEC + '\s+\d+\s+(LINE|DEBUG|WARNING|NOTICE|INFO|CRITICAL|ERROR)\s+--\s+\d+\s+\| '
    HEXNUM                     = '[A-Fa-f0-9][A-Fa-f0-9]+'
    FLOAT                      = '[\-+]?\d+\.\d+(?:[eE][\-+]?\d+)?'
    INTEGER                    = '[\-+]?\d+'
    REGEX_SPECIAL_CHAR         = '[\|\+\{\}\(\)\[\]\$\^\?\\\\\*\`]'
    FULL_FILE_PATH             = '(?:\/[\-A-Za-z0-9_.,]+){2,}\/?'
    RUBY_STACK_TRACE_FILE_LINE = FULL_FILE_PATH + ':\d+:in\s+\S+'
    PATTERN_WORD               = '\S+'


  Everything else it knows, you teach it, quickly and simply.

  partially inspired by "petit"
