#! /bin/bash
set -euvxo pipefail
(( ! UID ))
(( ! $#  ))
cd          /
touch       /final.tar
tar pcf     /final.tar                  \
  --exclude=/final.tar                  \
  --exclude=/dev                        \
 '--exclude=/home/*/.gvfs'              \
 '--exclude=/home/*/.cache'             \
 '--exclude=/home/*/.local/share/Trash' \
  --exclude=/media                      \
  --exclude=/mnt                        \
  --exclude=/proc                       \
  --exclude=/run                        \
  --exclude=/usr/src                    \
  --exclude=/sys                        \
  --exclude=/tmp                        \
  '--exclude=/var/cache/*'              \
  '--exclude=/var/log/*'                \
  '--exclude=/var/tmp/*'                \
  /
mv -v {,/tmp}/final.tar

