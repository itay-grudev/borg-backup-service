#!/bin/bash -ue

# The udev rule is not terribly accurate and may trigger our service before
# the kernel has finished probing partitions. Sleep for a bit to ensure
# the kernel is done.
#
# This can be avoided by using a more precise udev rule, e.g. matching
# a specific hardware path and partition.
#sleep 5

#
# Script configuration
#

# This is the location of the Borg repository
TARGET=$BORG_MOUNTPOINT/$BORG_ARCHIVE_NAME/

# Archive name schema
DATE=$(date +%G-%m-%d-%H:%m)-$(hostname)

# This is the file that will later contain UUIDs of registered backup drives
DISKS=/etc/borg-backup/backup.disks

# Find whether the connected block device is a backup drive
for uuid in $(lsblk --noheadings --list --output uuid)
do
        if grep --quiet --fixed-strings $uuid $DISKS; then
                break
        fi
        uuid=
done

if [ ! $uuid ]; then
        echo "No backup disk found, exiting"
        exit 0
fi

echo "Disk $uuid is a backup disk"
partition_path=/dev/disk/by-uuid/$uuid
# Mount file system if not already done. This assumes that if something is already
# mounted at $BORG_MOUNTPOINT, it is the backup drive. It won't find the drive if
# it was mounted somewhere else.
(mount | grep $BORG_MOUNTPOINT) || mount $partition_path $BORG_MOUNTPOINT
drive=$(lsblk --inverse --noheadings --list --paths --output name $partition_path | head --lines 1)
echo "Drive path: $drive"

#
# Create an LVM Snapshot
#
ROOTVOLUME=/

if [ "$BORG_LVM" = true ] ; then
	lvcreate --size 20G --snapshot --name $BORG_LVM_VOLUME $BORG_LVM_ROOT
	TMPDIR=$(mktemp --directory)
	mkdir -p $TMPDIR/root
	mount /dev/mapper/$BORG_LVM_VOLUME_GROUP-$BORG_LVM_VOLUME $TMPDIR/root
	ROOTVOLUME=$TMPDIR/root
fi

#
# Create backups
#

# Options for borg create
BORG_OPTS="--stats --one-file-system --compression lz4 --checkpoint-interval 86400"

# Set BORG_PASSPHRASE or BORG_PASSCOMMAND somewhere around here, using export,
# if encryption is used.


# No one can answer if Borg asks these questions, it is better to just fail quickly
# instead of hanging.
export BORG_RELOCATED_REPO_ACCESS_IS_OK=no
export BORG_UNKNOWN_UNENCRYPTED_REPO_ACCESS_IS_OK=no

# Log Borg version
borg --version

echo "Starting backup for $DATE"

# This is just an example, change it however you see fit
borg create $BORG_OPTS \
  --exclude /root/.cache \
  --exclude /var/backups/ \
  --exclude /var/cache \
  --exclude /var/lock \
  --exclude /var/run \
  --exclude /var/spool \
  --exclude /var/local \
  --exclude /var/log \
  --exclude /var/opt \
  --exclude /var/lib/docker/devicemapper \
  --exclude /mnt \
  --exclude /media \
  $TARGET::$DATE-$$ \
  $ROOTVOLUME /boot

echo "Completed backup for $DATE"

# Just to be completely paranoid
sync
