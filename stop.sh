#!/bin/bash -ue

umount -f /dev/mapper/$BORG_LVM_VOLUME_GROUP-$BORG_LVM_VOLUME
lvremove -f $BORG_LVM_VOLUME_GROUP/$BORG_LVM_VOLUME
