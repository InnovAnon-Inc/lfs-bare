/usr/local/bin/support-wrapper &
P="$!"
trap "kill $P ; wait $P" 0
unset P

