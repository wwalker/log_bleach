log_bleach - make the cruft disappear from your log files

log_bleach log_file_name

* look up log_file_name and figure out it's "type"

* apply the filters to log_file_name outputting to stdout only the relevant lines (more specifically removing known irrelevant lines)

log_bleach log_file_source_directory  log_file_target_directory

* for each file under the source directory, filter as above into a matching named extract file in the target directory

* In an ideal world, every file in the target directory would be empty!

* Everything in the filtered extracts is either a bug, or something else to add to the irrelevant filter for that log file type

options would exist to specify the file "type", specify filter "level" (so you can choose to leave certain data in the output), force-tiemstamp (add timestamps to the output when the input file didn't have timestamps.

Creation of a irrelevant filter is as easy as:

Given this in /var/log/messages:

    May 26 03:13:06 speedy openvpn[1194]: Inactivity timeout (--ping-restart), restarting
    May 26 03:13:06 speedy openvpn[1194]: TCP/UDP: Closing socket
    May 26 03:13:06 speedy openvpn[1194]: Closing TUN/TAP interface
    May 26 03:13:06 speedy openvpn[1194]: /sbin/ip addr del dev tun0 local 10.9.8.46 peer 10.9.8.45
    May 26 03:13:06 speedy avahi-daemon[833]: Withdrawing workstation service for tun0.
    May 26 03:13:06 speedy openvpn[1194]: SIGUSR1[soft,ping-restart] received, process restarting
    May 26 03:13:08 speedy openvpn[1194]: NOTE: OpenVPN 2.1 requires '--script-security 2' or higher to call user-defined scripts or executables
    May 26 03:13:08 speedy openvpn[1194]: Static Encrypt: Cipher 'BF-CBC' initialized with 128 bit key
    May 26 03:13:08 speedy openvpn[1194]: Static Encrypt: Using 160 bit message hash 'SHA1' for HMAC authentication

add the lines you want to ignore to a file:

    cat >> openvpn-irrelevant.source
    May 26 03:13:06 speedy openvpn[1194]: TCP/UDP: Closing socket
    May 26 03:13:06 speedy openvpn[1194]: Closing TUN/TAP interface
    May 26 03:13:06 speedy openvpn[1194]: /sbin/ip addr del dev tun0 local 10.9.8.46 peer 10.9.8.45
    ^D

Now lines looking like those lines would be ignored by any file "type" that has openvpn-irrelevant.source as one of its config'd filters.

No other effort on the part of the user or the config maintainer.

