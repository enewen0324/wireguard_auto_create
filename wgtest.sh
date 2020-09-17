#!/usr/local/bin/bash

template_path="/home/andy/wireguard_auto_create/"
template_name="wg_template.txt"
template_tunnel_name="wg_tunnel_template.txt"
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
        wg_reg_pub=$(cat publickey | sed -e "s/\\//\\\\\//g")
        wg_reg_pri=$(cat privatekey | sed -e "s/\\//\\\\\//g")
        echo $wg_reg_pub
        echo $wg_reg_pri
        ip_number="$(cat ${wgconf_path}${wg_name}.conf | grep Peer | wc -l)"
        ip_number=$(( ${ip_number} + 2 ))
        echo "192.168.50.$ip_number"
        touch "192.168.50.$ip_number"
        sed -e "s/A.B.C.D/192.168.50.${ip_number}\/32/g" -e "s/KKKEY/${wg_reg_pub}/g" $template_path$template_name >> "${wgconf_path}${wg_name}.conf"
        echo "\n\n" >> "${wgconf_path}${wg_name}.conf"
        echo "Your publickey"
        echo $wg_public
        echo "Your tunnel file"
        sed -e "s/A.B.C.D/192.168.50.${ip_number}\/24/g" -e "s/PPPRIKEY/${wg_reg_pri}/g" $template_path$template_tunnel_name > "${key_path}${wg_hostname}/tunnel"
        cat ${key_path}${wg_hostname}/tunnel
    ;;
    "delete")
    ;;
esac
read -p "Do you want to restart?(y/N)" restart_op
if [ $restart_op == "y" ];then
    wg-quick down $wg_name
    wg-quick up $wg_name
fi
