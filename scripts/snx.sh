#!/bin/bash

server=$SNX_SERVER
user=$SNX_USER
password=$SNX_PASSWORD
snx_command=""
snx_additional_args=$SNX_ARGS
snx_manual_routes=($SNX_MANUAL_ROUTES)

snx_command="snx -s $server -u $user $snx_additional_args"

/usr/bin/expect <<EOF
spawn $snx_command
expect "*?assword:"
send "$password\r"
expect "*Do you accept*"
send "y\r"
expect "SNX - connected."
interact
EOF

snx_ip=$(ip a s tunsnx | grep "inet\b" | awk '{print $2}' | cut -d/ -f1)
if [ -n "$snx_ip" ]; then
  echo got snx client ip: "$snx_ip"
else
  echo unable to get snx client ip
  exit 1
fi

echo adding NAT rule: SNAT to "$snx_ip"
iptables -t nat -A POSTROUTING -o tunsnx -j SNAT --to-source "$snx_ip"

for manual_route in "${snx_manual_routes[@]}"
do
  echo creating additional route to "$manual_route"
  ip r a "$manual_route" dev tunsnx src "$snx_ip"
done

tail -f /dev/null