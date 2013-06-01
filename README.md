LogBleach

  Makes the cruft in your logs disappear.

  log_bleach /var/log/my_custom_log
    will output to stdout the _relevant_ log file lines

  Currently, most things are not automatic, so...

  mkdir -p ~/.log_bleach/{source,parsed,perlre}
  cat > ~/.log_bleach/file_config.yaml
---
messages:
  patterns:
    - messages.*.gz
    - messages
    - messages-*.gz
  type: messages
  config_filters:
    - messages
    - openvpn
delivery_handler:
  patterns:
    - delivery_handler.log
    - delivery_handler.log.gz
    - delivery_handler.log-*.gz
    - delivery_handler.log.*.gz
  type: delivery_handler
  config_filters:
    - delivery_handler

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

