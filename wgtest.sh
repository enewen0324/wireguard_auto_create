#!/usr/local/bin/bash

template_path="/home/andy/wireguard_auto_create/"
template_name="wg_template.txt"
template_tunnel_name="wg_tunnel_template.txt"
key_path="/home/andy/wgkey/"
server_key_path="/home/andy/wg/"
wgconf_path="/usr/local/etc/wireguard/"
backup_path=""
max_backup_num="5"

work_dir=$(pwd)

read -p "The wireguard configure you want to change: " wg_name
read -p "Action(add or delete or recover): " wg_action

date=$(date +"%F#%T")
cp "$wgconf_path$wg_name.conf" backup/$date
backup_num=$(ls backup | wc -l)
if [ "$backup_num" -lt "$max_backup_num" ];then
    delete_file=$(ls backup | head -1)
    echo -e "delete ${delete_file}"
fi

case $wg_action in
    "add")
        read -p "hostname: " wg_hostname
        cd $key_path
        mkdir $wg_hostname
        cd $wg_hostname
        wg genkey | tee privatekey | wg pubkey > publickey
        wg_public=$(cat publickey)
        wg_private=$(cat privatekey) 
        wg_reg_pub=$(cat publickey | sed -e "s/\\//\\\\\//g")
        wg_reg_pri=$(cat privatekey | sed -e "s/\\//\\\\\//g")

        #need to change
        ip_number="$(cat $work_dir/.${wg_name} | head -1 | sed -e "s/@//g" )"
        touch "192.168.50.$ip_number"
        sed -i -e "/$ip_number/,+d"  $work_dir/.${wg_name}
        #need to change

        echo "#${wg_hostname}" >> "${wgconf_path}${wg_name}.conf"
        sed -e "s/A.B.C.D/192.168.50.${ip_number}\/32/g" -e "s/KKKEY/${wg_reg_pub}/g" $template_path$template_name >> "${wgconf_path}${wg_name}.conf"
        
        #echo -e  "\n\n" >> "${wgconf_path}${wg_name}.conf"
        echo -e "\nYour publickey:\n"
        echo $wg_public
        sed -e "s/A.B.C.D/192.168.50.${ip_number}\/24/g" -e "s/PPPRIKEY/${wg_reg_pri}/g" $template_path$template_tunnel_name > "${key_path}${wg_hostname}/tunnel"
        echo -e "\nYour tunnel file\n"
        echo -e "----------------------------"
        cat ${key_path}${wg_hostname}/tunnel
        echo -e "----------------------------\n"
    ;;
    "delete")
        read -p "host you want to delete: " wg_hostname
        ip_number="$( ls $key_path$wg_hostname | grep -e "[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}" | cut -d . -f 4)"
        echo $ip_number
        sed -i -e "/#$wg_hostname/,+4d" "${wgconf_path}${wg_name}.conf"
        rm -rf $key_path$wg_hostname
        echo "@$ip_number@" >>　"$work_dir/.${wg_name}"
    ;;
    "recover")

    ;;
    "create")
    
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
