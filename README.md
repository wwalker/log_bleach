LogBleach

  Makes the cruft in your logs disappear.

  log_bleach /var/log/my_custom_log

  will output to stdout the _relevant_ log file lines

  Create your initial .log_bleach directory structure:

    log_bleach --init

  Currently, some things are not automatic, so...

    cat >> ~/.log_bleach/source/openvpn
    May 26 03:13:18 speedy openvpn[1194]: Peer Connection Initiated with 72.24.19.66:5044
    May 26 03:13:19 speedy openvpn[1194]: Initialization Sequence Completed
    May 26 03:20:49 speedy openvpn[1194]: Inactivity timeout (--ping-restart), restarting
    May 26 03:20:49 speedy openvpn[1194]: TCP/UDP: Closing socket
    May 26 03:20:49 speedy openvpn[1194]: Closing TUN/TAP interface
    May 26 03:20:49 speedy openvpn[1194]: /sbin/ip addr del dev tun0 local 10.9.8.46 peer 10.9.8.45
    May 26 03:20:49 speedy avahi-daemon[833]: Withdrawing workstation service for tun0.
    May 26 03:20:49 speedy openvpn[1194]: SIGUSR1[soft,ping-restart] received, process restarting

    cat >> ~/.log_bleach/source/messages
    Apr 29 11:44:31 speedy systemd[1]: Starting Show Plymouth Power Off Screen...
    Apr 29 11:44:31 speedy systemd[1]: Unmounting /tmp/vmware-wwalker/564d6281-b20d-10b4-cb40-9c6976e3413a...
    Apr 29 11:44:31 speedy systemd[1]: Deactivating swap /dev/sdb2...
    Apr 29 11:44:31 speedy systemd[1]: Deactivating swap /dev/sdb2...
    Apr 29 11:44:31 speedy systemd[1]: Deactivating swap /dev/sda2...
    Apr 29 11:44:31 speedy systemd[1]: Deactivating swap /dev/sda2...
    Apr 29 11:44:31 speedy systemd[1]: Stopping Sound Card.
    Apr 29 11:44:31 speedy systemd[1]: Stopped target Sound Card.
    Apr 29 11:44:31 speedy systemd[1]: Stopping Stop Read-Ahead Data Collection 10s After Completed Startup.
    Apr 29 11:44:31 speedy systemd[1]: Stopped Stop Read-Ahead Data Collection 10s After Completed Startup.
    ^D

    update_log_filter messages

    log_bleach /var/log/messages

