#!/usr/local/bin/bash

template_path="/home/andy/wireguard_auto_create/"
template_name="wg_tmeplate.txt"
template_tunnel_name="wg_tunnel_tmeplate.txt"
key_path="/home/andy/wgkey/"
server_key_path="/home/andy/wg/"
wgconf_path="/usr/local/etc/wireguard/"

read -p "The wireguard configure you want to change:" wg_name
read -p "Action:(add or delete)" wg_action
case $wg_action in
    "add")
        read -p "hostname:" wg_hostname
        cd $key_path
        mkdir $wg_hostname
        cd $wg_hostname
        wg genkey | tee privatekey | wg pubkey > publickey
        wg_public=$(cat publickey)
        wg_private=$(cat privatekey) 
        ip_number="$(cat ${wgconf_path}${wg_name} | grep Peer | wc -l)"
        echo $ip_number
        echo "192.168.50.$(( ${ip_number} + 2 ))"
        touch "192.168.50.$(( ${ip_number} + 2 ))"
        sed -e "s/A.B.C.D/192.168.50.${ip_number}\/32/g" -e "s/KKKEY/${wg_public}/g" $template_path$template_name >> ${wgconf_path}${wg_name}
        echo "Your publickey"
        echo $wg_public
        echo "Your tunnel file"
        sed -e "s/A.B.C.D/192.168.50.${ip_number}\/24/g" -e "s/PPPRIKEY/${wg_private}/g" $template_path$template_tunnel_name > ${key_path}${$wg_hostname}/tunnel
        cat ${key_path}${$wg_hostname}/tunnel
    ;;
    "delete")
    ;;
esac
read -p "Do you want to restart?(y/N)" restart_op
if [ $restart_op == "y" ];then
    wg-quick down $wg_name
    wg-quick up $wg_name
fi
