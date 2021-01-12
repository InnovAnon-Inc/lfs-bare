#! /bin/bash
set -euvxo pipefail
(( ! UID ))
(( ! $#  ))
cd          /
touch       /final.tar
tar pcf     /final.tar \
  --exclude=/final.tar \
  --exclude=/dev       \
  --exclude=/media     \
  --exclude=/mnt       \
  --exclude=/proc      \
  --exclude=/run       \
  --exclude=/sys       \
  --exclude=/tmp       \
  --exclude=/var/tmp   \
  --exclude=/var/cache /
mv -v {,/tmp}/final.tar

