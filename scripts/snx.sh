#!/bin/bash

#    Copyright 2019 Kedu S.C.C.L.
#
#    This file is part of Docker-snx-checkpoint-vpn.
#
#    Docker-snx-checkpoint-vpn is free software: you can redistribute it
#    and/or modify it under the terms of the GNU General Public License
#    as published by the Free Software Foundation, either version 3 of the
#    License, or (at your option) any later version.
#
#    Docker-snx-checkpoint-vpn is distributed in the hope that it will be
#    useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with Docker-snx-checkpoint-vpn. If not, see
#    <http://www.gnu.org/licenses/>.
#
#    info@kedu.coop

server=$SNX_SERVER
user=$SNX_USER
password=$SNX_PASSWORD
snx_command=""
snx_additional_args=$SNX_ARGS
snx_manual_routes=($SNX_MANUAL_ROUTES)
certificate_path="/certificate.p12"

if [ -f "$certificate_path" ]; then
    if [ -n "$user" ]; then
        snx_command="snx -s $server -u $user -c $certificate_path $snx_additional_args"
    else
        snx_command="snx -s $server -c $certificate_path $snx_additional_args"
    fi
else
    snx_command="snx -s $server -u $user $snx_additional_args"
fi

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

/bin/bash
