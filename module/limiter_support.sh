#!/bin/bash

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# Path to users_connections.txt
USER_CONNECTIONS_FILE="/etc/UDPCustom/users_connections.txt"

# Function to lock expired user accounts
lock_expired_users() {
    all_users=$(cut -d: -f1 /etc/passwd)
    for user in $all_users; do
        user_date=$(chage -l "$user" | grep "Account expires" | awk -F': ' '{print $2}')
        if [[ "$user_date" != "never" && $(date +%s) -gt $(date -d "$user_date" +%s) ]]; then
            usermod -L "$user"
            echo "User $user is expired and has been locked." >> /etc/limit.log
        fi
    done
}

# Function to monitor SSH and Dropbear connections
monitor_connections() {
    local users_to_monitor=($(cut -d: -f1 /etc/passwd))

    for user in "${users_to_monitor[@]}"; do
        max_ssh_connections=$(grep "^$user:" "$USER_CONNECTIONS_FILE" | cut -d: -f2)

        dropbear_sessions=$(ps -u "$user" | grep dropbear | wc -l)

        total_connections=$((max_ssh_connections + dropbear_sessions))

        if [ "$total_connections" -gt "$max_ssh_connections" ]; then
            pkill -u "$user"
            droplim=$(ps aux | grep dropbear | grep "$user" | awk '{print $2}')
            kill -9 "$droplim" &>/dev/null
            usermod -L "$user"
            echo "User $user exceeded maximum allowed connections. Sessions terminated and account locked." >> /etc/limit.log
        fi
    done
}

# Main function
main() {
    case "$1" in
        lock_expired_users)
            lock_expired_users
            ;;
        monitor_connections)
            monitor_connections
            ;;
        *)
            echo "Usage: $0 {lock_expired_users|monitor_connections}"
            exit 1
            ;;
    esac
}

main "$1"