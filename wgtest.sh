#!/usr/local/bin/bash

template_path="/home/andy/wireguard_auto_create/"
template_name="wg_template.txt"
template_tunnel_name="wg_tunnel_template.txt"
key_path="/home/andy/wgkey/"
server_key_path="/home/andy/wg/"
wgconf_path="/usr/local/etc/wireguard/"

read -p "The wireguard configure you want to change: " wg_name
echo -e "\n"
read -p "Action(add or delete): " wg_action
echo -e "\n"
case $wg_action in
    "add")
        read -p "\nhostname: " wg_hostname
        cd $key_path
        mkdir $wg_hostname
        cd $wg_hostname
        wg genkey | tee privatekey | wg pubkey > publickey
        wg_public=$(cat publickey)
        wg_private=$(cat privatekey) 
        wg_reg_pub=$(cat publickey | sed -e "s/\\//\\\\\//g")
        wg_reg_pri=$(cat privatekey | sed -e "s/\\//\\\\\//g")
        ip_number="$(cat ${wgconf_path}${wg_name}.conf | grep Peer | wc -l)"
        ip_number=$(( ${ip_number} + 2 ))
        touch "192.168.50.$ip_number"
        sed -e "s/A.B.C.D/192.168.50.${ip_number}\/32/g" -e "s/KKKEY/${wg_reg_pub}/g" $template_path$template_name >> "${wgconf_path}${wg_name}.conf"
        echo -e  "\n\n" >> "${wgconf_path}${wg_name}.conf"
        printf "\nYour publickey:\n"
        echo $wg_public
        sed -e "s/A.B.C.D/192.168.50.${ip_number}\/24/g" -e "s/PPPRIKEY/${wg_reg_pri}/g" $template_path$template_tunnel_name > "${key_path}${wg_hostname}/tunnel"
        printf "\nYour tunnel file\n"
        printf "----------------------------"
        cat ${key_path}${wg_hostname}/tunnel
        printf "----------------------------\n"
    ;;
    "delete")
    ;;
    "test")
        printf "\nYour tunnel file\n"
        printf "----------------------------"
        printf "----------------------------\n"

        echo -e  "\nYour tunnel file\n"
        echo -e "----------------------------"
        echo -e "----------------------------\n"

    ;;
esac
read -p "Do you want to restart?(y/N) " restart_op
if [ $restart_op == "y" ];then
    wg-quick down $wg_name
    wg-quick up $wg_name
fi
