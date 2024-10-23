#!/bin/bash

# Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

# Variables
file_name="bundle.js"
path_file_temp="/tmp/htbmachines/${file_name}"
main_url="https://htbmachines.github.io/${file_name}"

# Pointers
declare -i parameter_counter=0

# Functions
function ctrl_c() {
  echo -e "\n\n${redColour}[!] Exiting...${endColour}\n"
  tput cnorm
  exit 1
}

function help_panel() {
  echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Usage:${endColour}"
  echo -e "\t${purpleColour}h)${endColour} ${grayColour}Show help panel.${endColour}"
  echo -e "\t${purpleColour}u)${endColour} ${grayColour}Download or update necessary files.${endColour}"
  echo -e "\t${purpleColour}m)${endColour} ${grayColour}Search by machine name.${endColour}"
  echo -e "\t${purpleColour}i)${endColour} ${grayColour}Search by ip address.${endColour}"
  echo -e "\t${purpleColour}y)${endColour} ${grayColour}Get link of the machine resolution by machine name.${endColour}"
  echo -e "\t${purpleColour}l)${endColour} ${grayColour}List machine names:${endColour}"
  echo -e "\t${purpleColour}d)${endColour} ${grayColour}List machine names by difficulty:${endColour}"
  echo -e "\t\t${turquoiseColour}1${endColour} ${grayColour}- Easy${endColour}"
  echo -e "\t\t${turquoiseColour}2${endColour} ${grayColour}- Normal${endColour}"
  echo -e "\t\t${turquoiseColour}3${endColour} ${grayColour}- Difficult${endColour}"
  echo -e "\t\t${turquoiseColour}4${endColour} ${grayColour}- Insane${endColour}"
  echo -e "\t${purpleColour}o)${endColour} ${grayColour}List machine names by os:${endColour}"
  echo -e "\t\t${turquoiseColour}1${endColour} ${grayColour}- Linux${endColour}"
  echo -e "\t\t${turquoiseColour}2${endColour} ${grayColour}- Windows${endColour}"
  echo -e "\n"
}

function update() {
  tput civis

  if [ ! -f ${file_name} ]; then
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Downloading necessary files...${endColour}"
    curl -s ${main_url} > ${file_name}
    js-beautify -f ${file_name} | sponge ${file_name}
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}All files have been downloaded.${endColour}\n"
  else
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Checking for updates...${grayColour}"
    curl -s ${main_url} > ${path_file_temp}
    js-beautify -f ${path_file_temp} | sponge ${path_file_temp}
    md5_temp_value=$(md5sum ${path_file_temp} | awk '{print $1}')
    md5_value=$(md5sum ${file_name} | awk '{print $1}')

    if [ "${md5_value}" == "${md5_temp_value}" ]; then
      rm ${path_file_temp}
      echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Already up to date.${endColour}\n"
    else
      rm ${file_name} && mv ${path_file_temp} ./
      echo -e "\n${yellowColour}[+]${endColour} ${grayColour}All files have been updated.${endColour}\n"
    fi
  fi

  tput cnorm
}

function search_machine() {
  machine_name=$1
  info=$(process_list | grep "${machine_name}")

  if [ "${info}" ]; then
    name=$(echo "${info}" | awk '{print $1}')
    ip=$(echo "${info}" | awk '{print $2}')
    os=$(echo "${info}" | awk '{print $3}')
    difficulty=$(echo "${info}" | awk '{print $4}')
    like=$(echo "${info}" | awk '{for(i=5; i<=NF; i++) printf "%s ", $i; print ""}')

    echo -e "\n${blueColour}Name:${endColour} ${name}"
    echo -e "${blueColour}IP:${endColour} ${ip}"
    echo -e "${blueColour}OS:${endColour} ${os}"
    echo -e "${blueColour}Difficulty:${endColour} ${difficulty}"
    echo -e "${blueColour}Like:${endColour} ${like}\n"

  else
    echo -e "\n${redColour}[-] Machine with name${endColour} ${blueColour}${machine_name}${endColour} ${redColour}not found.${endColour}\n"
  fi
}

function search_ip() {
  ip_address=$1
  machine_name=$(cat ${file_name} | grep "ip: \"${ip_address}\"" -B 3 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',')

  if [ "${machine_name}" ]; then
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Machine with ip address${endColour} ${blueColour}${ip_address}${endColour} ${grayColour}is called${endColour} ${greenColour}${machine_name}${endColour}.\n"
  else
    echo -e "\n${redColour}[-] Machine with ip address${endColour} ${blueColour}${ip_address}${endColour} ${redColour}not found.${endColour}\n"
  fi
}

function get_youtube_link() {
  machine_name=$1
  link=$(cat ${file_name} | awk "/name: \"${machine_name}\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta:" | tr -d '"' | tr -d ',' | sed 's/^ *//' | grep "youtube:" | awk 'NF{print $NF}')

  if [ "${link}" ]; then
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Machine with name${endColour} ${blueColour}${machine_name}${endColour} ${grayColour}is resolved in${endColour} ${greenColour}${link}${endColour}\n"
  else
    echo -e "\n${redColour}[-] Machine with name${endColour} ${blueColour}${machine_name}${endColour} ${redColour}not found.${endColour}\n"
  fi
}

list() {
  echo -e "\n"
  process_list
  echo -e "\n"
}

function list_by_difficulty() {
  difficulty=$1

  case $1 in
  1)
    level="Fácil"
    levelLabel="Easy"
    ;;
  2)
    level="Media"
    levelLabel="Normal"
    ;;
  3)
    level="Difícil"
    levelLabel="Difficult"
    ;;
  4)
    level="Insane"
    levelLabel="Insane"
    ;;
  esac

  if [ "${level}" ]; then
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Machines with difficult${endColour} ${blueColour}${levelLabel}${endColour}:\n"
    cat ${file_name} | grep "dificultad: \"${level}\"" -B 5 | grep name | awk 'NF{print $NF}' | tr -d '"' | tr -d "," | column
    echo -e "\n"
  else
    echo -e "\n${redColour}[-] The difficulty entered is not valid.${endColour}\n"
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Please select one of these:${endColour}"
    echo -e "\t${turquoiseColour}1${endColour} ${grayColour}- Easy${endColour}"
    echo -e "\t${turquoiseColour}2${endColour} ${grayColour}- Normal${endColour}"
    echo -e "\t${turquoiseColour}3${endColour} ${grayColour}- Difficult${endColour}"
    echo -e "\t${turquoiseColour}4${endColour} ${grayColour}- Insane${endColour}"
    echo -e "\n"
  fi
}

function list_by_os() {
  os=$1

  case $1 in
  1)
    os_label="Linux"
    ;;
  2)
    os_label="Windows"
    ;;
  esac

  if [ "${os_label}" ]; then
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Machines with os${endColour} ${blueColour}${os_label}${endColour}:\n"
    cat ${file_name} | grep "so: \"${os_label}\"" -B 5 | grep name | awk 'NF{print $NF}' | tr -d '"' | tr -d "," | column
    echo -e "\n"
  else
    echo -e "\n${redColour}[-] The os entered is not valid.${endColour}\n"
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Please select one of these:${endColour}"
    echo -e "\t${turquoiseColour}1${endColour} ${grayColour}- Linux${endColour}"
    echo -e "\t${turquoiseColour}2${endColour} ${grayColour}- Windows${endColour}"
    echo -e "\n"
  fi
}

function process_list() {
  machines=$(sed '/\/\*\! For license information please see bundle.js.LICENSE.txt \*\//,/        }(), lf = \[{/d' ${file_name} | grep -vE / | grep -vE \} | awk "/name:/,/resuelta:/" | grep -vE "id:|sku:|skills:" | tr -d ',' | tr -d '"' | sed 's/^ *//')
  echo "${machines}" | sed 's/^resuelta: !0 *//' | awk -v RS="" -F'\n' '
    BEGIN { print "Name|IP|SO|Dificultad|Like"; print "----|--|--|---------|----" }
    {
        for (i=1; i<=NF; i++) {
            split($i, a, ": ");
            if (i == 1) name = a[2];
            else if (i == 2) ip = a[2];
            else if (i == 3) so = a[2];
            else if (i == 4) dificultad = a[2];
            else if (i == 5) like = a[2];
        }
        print name "|" ip "|" so "|" dificultad "|" like;
    }
' | column -t -s '|'
}

# Execution
trap ctrl_c INT

while getopts "hulm:i:y:d:o:" arg; do
  case $arg in
  h)
    ;;
  u)
    parameter_counter+=1
    ;;
  m)
    machine_name=$OPTARG;
    parameter_counter+=2
    ;;
  i)
    ip_address=$OPTARG
    parameter_counter+=3
    ;;
  y)
    machine_name=$OPTARG
    parameter_counter+=4
    ;;
  l)
    parameter_counter+=5
    ;;
  d)
    difficulty=$OPTARG
    parameter_counter+=6
    ;;
  o)
    os=$OPTARG
    parameter_counter+=7
    ;;
  *)
    ;;
  esac
done

if [ $parameter_counter -eq 1 ]; then
  update
elif [ $parameter_counter -eq 2 ]; then
  search_machine "$machine_name"
elif [ $parameter_counter -eq 3 ]; then
  search_ip "$ip_address"
elif [ $parameter_counter -eq 4 ]; then
  get_youtube_link "$machine_name"
elif [ $parameter_counter -eq 5 ]; then
  list
elif [ $parameter_counter -eq 6 ]; then
  list_by_difficulty "$difficulty"
elif [ $parameter_counter -eq 7 ]; then
  list_by_os "$os"
else
  help_panel
fi