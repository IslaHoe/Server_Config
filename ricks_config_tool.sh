#!/usr/bin/env bash

# Instructions to use this script:
#
# chmod +x SCRIPTNAME.sh
#
# sudo ./SCRIPTNAME.sh

# Notes about this script:
# This tool will check for updates and existing files before proceeding to setup
# and configure LAMP stack to run a simple PHP web app.

# Check for package manager updates
sudo apt-get update -q

# --------------------------
# Remove Debian Packages
# --------------------------
# declare -a remove_packages=(
#   "php5"
#   "libapache2-mod-php5"
#   "php5-mcrypt"
# )
# for rm_pkg in "${remove_packages[@]}"
# do
#   if dpkg -l | grep "${rm_pkg}"; then
#     sudo apt-get purge -y "${rm_pkg}"
#     sudo rm -rf /etc/"${rm_pkg}" /var/lib/"${rm_pkg}"
#     sudo apt-get autoremove -y
#     sudo apt-get autoclean -y
#   fi
# done

# --------------------------
# Install Debian Packages
# --------------------------
declare -a install_packages=(
  "apache2"
  "mysql-server"
  "php5-mysql"
  "php5"
  "libapache2-mod-php5"
  "php5-mcrypt"
)
for in_pkg in "${install_packages[@]}"
do
  if ! dpkg -l | grep "${in_pkg}"; then
    sudo apt-get install -y "${in_pkg}"
    if [ "${in_pkg}" == "mysql-server" ]; then
      # Create the MySQL database
      sudo mysql_install_db

      # Secure our installation by removing insecure defaults
      sudo mysql_secure_installation
    fi
  fi
done

# Replace default index.html with index.php
if [ -f "/var/www/html/index.html" ]; then
  sudo rm /var/www/html/index.html
  touch /var/www/html/index.php
fi

# --------------------------
# Setting Metadata and Content
# --------------------------

# To change metadata for files or folders, use the following example as a guide.

# Set metadata for a given file or directory
declare -A metadata=(
  ["permissions"]="644"
  ["owner"]="root"
  ["group"]="staff"
  ["file"]="/var/www/html/index.php"
  ["content"]='<?php header("Content-Type: text/plain"); echo "Hello, world!\n";'
)
sudo chmod "${metadata[permissions]}" "${metadata[file]}"
sudo chown "${metadata[owner]}" "${metadata[file]}"
sudo chgrp "${metadata[group]}" "${metadata[file]}"
sudo echo "${metadata[content]}" > "${metadata[file]}"

# Changes permissions for all files and folders within a given directory
# declare -A dir_metadata=(
#   ["directory_permissions"]="755"
#   ["file_permissions"]="644"
#   ["directory"]="path/to/directory/" )
# sudo find "${dir_metadata[directory]}" -type f -print0 | xargs -0 sudo chmod "${dir_metadata[file_permissions]}"
# sudo find "${dir_metadata[directory]}" -type d -print0 | xargs -0 sudo chmod "${dir_metadata[directory_permissions]}"

# --------------------------
# Restart a Given Service
# --------------------------
sudo service apache2 restart
