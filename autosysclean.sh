#!/bin/bash

### By: Argon3x
### Supported: Debian Based Systems
### Version: 1.0

# Colors
red="\e[01;31m"; green="\e[01;32m"; blue="\e[01;34m"
purple="\e[01;35m"; yellow="\e[01;33m"; end="\e[00m"

# Context box
box="${purple}[${green}+${purple}]${end}"

# Signal of interrupt / error
interrupt_handler(){
  echo -e "\n${blue}>>>> ${red}Process Canceled ${blue}<<<<\n"
  tput cnorm
  exit 1
}

error_handler(){
  type_error=$1

  echo -e "\n${blue}Script Error${end}:{\n${red}\t${type_error}${end}\n}\n"
  tput cnorm
  exit 1
}

# Call the signals
trap interrupt_handler SIGINT
trap error_handler SIGTERM

# Global Variables
home_user="$HOME"

# Delete temporary files and cache / Remove old packages from the cache that are no longer needed
clean_apt_manager(){
  echo -e "${box} ${yellow}Cleaning up the apt packages manager${end}............\c"

  command sudo apt clean > /dev/null 2>&1 && sudo apt autoclean > /dev/null 2>&1 && sudo apt autoremove -y > /dev/null 2>&1
  if [[ $? -eq 0 ]]; then
    echo -e "${green} done ${end}"
  else
    error_handler "An Error Ocurred While Cleaning The APT Package Manager."
  fi
}

# Delete All System Logs
delete_system_logs(){
  echo -e "${box} ${yellow}Cleaning system logs${end}...........\c"

  command sudo rm -rf /var/log/*
  if [[ $? -eq 0 ]]; then
    echo -e "${green} done ${end}"
  else
    error_handler "An Error Ocurred While Cleaning The System Logs."
  fi
}

# Remove All Empty Files 
remove_empty_files(){
  echo -e "${box} ${yellow}Removing all empty files${end}...........\c"; sleep 0.4

  find "$home_user" -type f -empty -exec rm {} \;
  if [[ $? -eq 0 ]]; then
    echo -e "${green} done ${end}"
  else
    error_handler "An Error Ocurred While Deleting Empty Files."
  fi
}

# Remove All Empty Directories
remove_empty_directories(){
  local status=1

  echo -e "${box} ${yellow}Removing all empty directories${end}...........\c"; sleep 0.4
  
  while [[ $status -ne 0 ]]; do
    find "$home_user" -type d -empty -exec rmdir {} \; 2>/dev/null
    if [[ $? -eq 0 ]]; then
      status=$?
      echo -e "${green} done ${end}"
    else
      status=1
    fi
  done
  unset status
}


if [[ $(id -u) -eq 0 ]]; then
  tput civis && clear
  echo -e "${box} ${yellow}Starting self clean script${end}............."; sleep 1
  # Clean apt manager
  clean_apt_manager
  # Delete system logs
  delete_system_logs
  # Remove all empty user files
  remove_empty_files
  # Remove all empty user directories
  remove_empty_directories

  tput cnorm
else
  clear
  error_handler "use: ${green}sudo ./${0##*/}${end}"
fi

# Clearing the functions and Variables
sleep 1
unset red green blue purple yellow end box type_error home_user
unset -f clean_apt_manager delete_system_logs remove_empty_files remove_empty_directories
