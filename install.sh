#!/bin/bash

# Run as root
[[ "$(whoami)" != "root" ]] && {
    echo -e "\033[1;33m[\033[1;31mErro\033[1;33m] \033[1;37m- \033[1;33myou need to run as root\033[0m"
    rm /home/ubuntu/install.sh &>/dev/null
    exit 0
}

#=== setup ===
cd 
rm -rf /root/udp
mkdir -p /root/udp
rm -rf /etc/UDPCustom
mkdir -p /etc/UDPCustom
sudo touch /etc/UDPCustom/udp-custom
udp_dir='/etc/UDPCustom'
udp_file='/etc/UDPCustom/udp-custom'
sudo touch /etc/UDPCustom/user_connections.txt
chmod 666 /etc/UDPCustom/user_connections.txt

sudo apt update -y
sudo apt upgrade -y
sudo apt install -y wget
sudo apt install -y curl
sudo apt install -y dos2unix
sudo apt install -y neofetch

source <(curl -sSL 'https://raw.githubusercontent.com/mozone20/udp_manager/main/module/module')

time_reboot() {
  print_center -ama "${a92:-System/Server Reboot In} $1 ${a93:-Seconds}"
  REBOOT_TIMEOUT="$1"

  while [ $REBOOT_TIMEOUT -gt 0 ]; do
    print_center -ne "-$REBOOT_TIMEOUT-\r"
    sleep 1
    : $((REBOOT_TIMEOUT--))
  done
  rm /home/ubuntu/install.sh &>/dev/null
  rm /root/install.sh &>/dev/null
  echo -e "\033[01;31m\033[1;33m More Updates, Chat Me \033[1;31m(\033[1;36mTelegram\033[1;31m): \033[1;37m@in0vador\033[0m"
  reboot
}

# Check Ubuntu version
if [ "$(lsb_release -rs)" = "8*|9*|10*|11*|16.04*|18.04*" ]; then
  clear
  print_center -ama -e "\e[1m\e[31m=====================================================\e[0m"
  print_center -ama -e "\e[1m\e[33m${a94:-this script is not compatible with your operating system}\e[0m"
  print_center -ama -e "\e[1m\e[33m ${a95:-Use Ubuntu 20 or higher}\e[0m"
  print_center -ama -e "\e[1m\e[31m=====================================================\e[0m"
  rm /home/ubuntu/install.sh
  exit 1
else
  clear
  echo ""
  print_center -ama " ⇢ STARTING INSTALLATION...! <"
  sleep 3

    # [change timezone to UTC +0]
  echo ""
  echo " ⇢ VORTEXUS CLOUD"
  echo " ⇢ UDP MANAGER"
  sleep 3

  # [+clean up+]
  rm -rf $udp_file &>/dev/null
  rm -rf /etc/UDPCustom/udp-custom &>/dev/null
  rm -rf /etc/limiter.sh &>/dev/null
  rm -rf /etc/UDPCustom/limiter.sh &>/dev/null
  rm -rf /etc/UDPCustom/module &>/dev/null
  rm -rf /usr/bin/udp &>/dev/null
  rm -rf /etc/UDPCustom/udpgw.service &>/dev/null
  rm -rf /etc/udpgw.service &>/dev/null
  systemctl stop udpgw &>/dev/null
  systemctl stop udp-custom &>/dev/null

  # Download required files
  wget -O "$udp_dir/limiter_support.sh" "https://raw.githubusercontent.com/mozone20/udp_manager/main/module/support_limiter.sh"
  wget -O "$udp_dir/limiter_run.py" "https://raw.githubusercontent.com/mozone20/udp_manager/main/module/limiter_run.py"
  
  # Set permissions
  chmod +x "$udp_dir/limiter_support.sh"
  chmod +x "$udp_dir/limiter_run.py"

 # [+get files ⇣⇣⇣+]
  source <(curl -sSL 'https://raw.githubusercontent.com/mozone20/udp_manager/main/module/module') &>/dev/null
  wget -O /etc/UDPCustom/module 'https://raw.githubusercontent.com/mozone20/udp_manager/main/module/module' &>/dev/null
  chmod +x /etc/UDPCustom/module

  wget "https://raw.github.com/mozone20/udp_manager/main/bin/udp-custom-linux-amd64" -O /root/udp/udp-custom &>/dev/null
  chmod +x /root/udp/udp-custom

  wget -O /etc/limiter.sh 'https://raw.githubusercontent.com/mozone20/udp_manager/main/module/limiter.sh'
  cp /etc/limiter.sh /etc/UDPCustom
  chmod +x /etc/limiter.sh
  chmod +x /etc/UDPCustom
  
  # [+udpgw+]
  wget -O /etc/udpgw 'https://raw.github.com/mozone20/udp_manager/main/module/udpgw'
  mv /etc/udpgw /bin
  chmod +x /bin/udpgw

  # [+service+]
  wget -O /etc/udpgw.service 'https://raw.githubusercontent.com/mozone20/udp_manager/main/config/udpgw.service'
  wget -O /etc/udp-custom.service 'https://raw.githubusercontent.com/mozone20/udp_manager/main/config/udp-custom.service'
  
  mv /etc/udpgw.service /etc/systemd/system
  mv /etc/udp-custom.service /etc/systemd/system

  chmod 640 /etc/systemd/system/udpgw.service
  chmod 640 /etc/systemd/system/udp-custom.service
  
  systemctl daemon-reload &>/dev/null
  systemctl enable udpgw &>/dev/null
  systemctl start udpgw &>/dev/null
  systemctl enable udp-custom &>/dev/null
  systemctl start udp-custom &>/dev/null

  # [+config+]
  wget "https://raw.githubusercontent.com/mozone20/udp_manager/main/config/config.json" -O /root/udp/config.json &>/dev/null
  chmod +x /root/udp/config.json

  cat << EOF > /etc/systemd/system/udp_limiter.service
[Unit]
Description=UDP Manager Limiter Service
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/python3 $udp_dir/limiter_run.py
Restart=always

[Install]
WantedBy=multi-user.target
EOF

  # Reload systemd manager configuration
  systemctl daemon-reload

  # Enable and start the service
  systemctl enable udp_limiter
  systemctl start udp_limiter

  # [+menu+]
  wget -O /usr/bin/udp 'https://raw.githubusercontent.com/mozone20/udp_manager/main/module/udp' 
  chmod +x /usr/bin/udp
  ufw disable &>/dev/null
  sudo apt-get remove --purge ufw firewalld -y
  apt remove netfilter-persistent -y
  clear
  echo ""
  echo ""
  print_center -ama "${a103:-INSTALLING, PLEASE WAIT...}"
  sleep 6
  title "${a102:-¡INSTALLATION COMPLETED!}"
  print_center -ama "${a103:-  TO SEE MENU USE COMAND: \nudp\n}"
  echo -ne "\n\033[1;31mCLICK ENTER \033[1;33mTO SUBMIT \033[1;32mMENU!\033[0m"; read
   udp
  
fi
