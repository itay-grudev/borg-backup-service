# Borg Backup Service

A systemd service for creating a backup of your root linux drive to an external
disk using BorgBackup with support for creating an LVM snapshot.

BorgBackup is an extremly powerful backup tool that supports deduplication,
encryption and compression.

## Usage

My preffered way of installing is installing borg and placing the contents of
this repository in `/etc/borg-backup`.

```bash
# Install BorgBackup
sudo apt install borgbackup # Debian based distros
sudo pacman -S borg # Arch
sudo yum install borgbackup # Fedora

# Set up a Borg repository
borg init --encryption=repokey /path/to/repo

# Installing borg-backup-service
sudo mkdir /etc/borg-backup
sudo git clone --depth 1 https://github.com/itay-grudev/borg-backup-service.git /etc/borg-backup

sudo ln -s /etc/borg-backup/borg-backup.service /etc/systemd/system/borg-backup.service
sudo systemctl daemon-reload

# To enable the automatic backup when the external disk is plugged in
sudo ln -s /etc/borg-backup/40-backup.rules /etc/udev/rules.d/40-backup.rules
sudo udevadm control --reload
```

For full documentation on setting up a borg repository refer to
[Borg Quick Start Guide](https://borgbackup.readthedocs.io/en/stable/quickstart.html).

## Configuration

Add the external disk UUID to the `backup.disks` file, one entry per line.
Additional configuration is done in the `backup.conf` file.

## Customisations

If you need to customise the backup script like for example excluding certain
directories from the backup modify the `start.sh` script.

For example to exclude `/opt` from the backup add:

```bash
borg create $BORG_OPTS \
  --exclude /opt \
  ...
```

## License

This code is based on the article [Automated backups to a local hard drive](https://borgbackup.readthedocs.io/en/stable/deployment/automated-local.html)
and is distributed under the terms of the GNU GPL v3.

Copyright Itay Grudev 2018-.
