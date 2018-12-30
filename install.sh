ln -s /etc/borg-backup/40-backup.rules /etc/udev/rules.d/40-backup.rules
ln -s /etc/borg-backup/borg-backup.service /etc/systemd/system/borg-backup.service
systemctl daemon-reload
udevadm control --reload

