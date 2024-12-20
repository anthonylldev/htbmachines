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
  echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Script Usage:${endColour}\n"
  echo -e "\t${blueColour}h)${endColour} ${grayColour}Show help panel.${endColour}"
  echo -e "\t${blueColour}u)${endColour} ${grayColour}Download or update necessary files.${endColour}"
  echo -e "\t${blueColour}l)${endColour} ${grayColour}List all available machines.${endColour}"

  echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Search Options:${endColour}\n"

  echo -e "\t${blueColour}y)${endColour} ${grayColour}Get solution video link by machine name.${endColour}"
  echo -e "\t\t${blueColour}Usage:${endColour} ${grayColour}-y <machine_name>${endColour}\n"

  echo -e "\t${blueColour}m)${endColour} ${grayColour}Search by machine name.${endColour}"
  echo -e "\t\t${blueColour}Usage:${endColour} ${grayColour}-m <machine_name>${endColour}\n"

  echo -e "\t${blueColour}i)${endColour} ${grayColour}Search by IP address.${endColour}"
  echo -e "\t\t${blueColour}Usage:${endColour} ${grayColour}-i <ip_address>${endColour}\n"

  echo -e "\t${blueColour}s)${endColour} ${grayColour}Search by skill.${endColour}"
  echo -e "\t\t${blueColour}Usage:${endColour} ${grayColour}-s <skill>${endColour}\n"

  echo -e "\t${blueColour}d)${endColour} ${grayColour}Search by difficulty level:${endColour}"
  echo -e "\t\t${turquoiseColour}1${endColour} ${grayColour}- Easy${endColour}"
  echo -e "\t\t${turquoiseColour}2${endColour} ${grayColour}- Normal${endColour}"
  echo -e "\t\t${turquoiseColour}3${endColour} ${grayColour}- Difficult${endColour}"
  echo -e "\t\t${turquoiseColour}4${endColour} ${grayColour}- Insane${endColour}"
  echo -e "\t\t${blueColour}Usage:${endColour} ${grayColour}-d <level>${endColour}\n"

  echo -e "\t${blueColour}o)${endColour} ${grayColour}Search by operating system:${endColour}"
  echo -e "\t\t${turquoiseColour}1${endColour} ${grayColour}- Linux${endColour}"
  echo -e "\t\t${turquoiseColour}2${endColour} ${grayColour}- Windows${endColour}"
  echo -e "\t\t${blueColour}Usage:${endColour} ${grayColour}-o <os_type>${endColour}"

  echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Example Usage:${endColour}\n"
  echo -e "\t${blueColour}bash htbmachines.sh -m <machine_name> -i <ip_address> -d <difficulty_level> -o <os_type> -s <skill>${endColour}\n"
}

function show_difficulty_message() {
  echo -e "${redColour}[!] The difficulty entered is not valid.${endColour}"
  echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Please select one of these:${endColour}"
  echo -e "\t${turquoiseColour}1${endColour} ${grayColour}- Easy${endColour}"
  echo -e "\t${turquoiseColour}2${endColour} ${grayColour}- Normal${endColour}"
  echo -e "\t${turquoiseColour}3${endColour} ${grayColour}- Difficult${endColour}"
  echo -e "\t${turquoiseColour}4${endColour} ${grayColour}- Insane${endColour}\n"
}

function show_os_message() {
  echo -e "${redColour}[!] The os entered is not valid.${endColour}"
  echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Please select one of these:${endColour}"
  echo -e "\t${turquoiseColour}1${endColour} ${grayColour}- Linux${endColour}"
  echo -e "\t${turquoiseColour}2${endColour} ${grayColour}- Windows${endColour}\n"
}

function update() {
  tput civis

  echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Checking for necessary files...${endColour}"

  if [ ! -f ${file_name} ]; then
    echo -e "${yellowColour}[+]${endColour} ${grayColour}Downloading necessary files...${endColour}"
  else
    echo -e "${yellowColour}[+]${endColour} ${grayColour}Checking for updates...${endColour}"
  fi

  # Download the file
  if ! curl -s -o ${path_file_temp} ${main_url}; then
    echo -e "${redColour}[!] Error downloading file.${endColour}"
    tput cnorm
    exit 1
  fi

  js-beautify -f ${path_file_temp} | sponge ${path_file_temp}

  if [ ! -f ${file_name} ]; then
    mv ${path_file_temp} ${file_name}
    echo -e "${yellowColour}[+]${endColour} ${grayColour}File downloaded successfully.${endColour}\n"
  else
    if [ "$(md5sum ${file_name} | awk '{print $1}')" != "$(md5sum ${path_file_temp} | awk '{print $1}')" ]; then
      mv ${path_file_temp} ${file_name}
      echo -e "${yellowColour}[+]${endColour} ${grayColour}File updated successfully.${endColour}\n"
    else
      rm ${path_file_temp}
      echo -e "${yellowColour}[+]${endColour} ${grayColour}Already up to date.${endColour}\n"
    fi
  fi

  tput cnorm
}

function process_list() {
  machines=$(sed '/\/\*\! For license information please see bundle.js.LICENSE.txt \*\//,/        }(), lf = \[{/d' ${file_name} | grep -vE / | grep -vE \} | awk "/name:/,/resuelta:/" | grep -vE "id:|sku:|skills:" | tr -d ',' | tr -d '"' | sed 's/^ *//')
  echo "${machines}" | sed 's/Fácil/Easy/' | sed 's/Media/Normal/' | sed 's/Difícil/Difficult/' | sed 's/^resuelta: !0 *//' | awk -v RS="" -F'\n' '
    BEGIN { print "Name|IP|OS|Difficult|Skills"; print "----|--|--|---------|----" }
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

function get_youtube_link() {
  machine_name=$1
  link=$(cat ${file_name} | awk "/name: \"${machine_name}\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta:" | tr -d '"' | tr -d ',' | sed 's/^ *//' | grep "youtube:" | awk 'NF{print $NF}')

  if [ "${link}" ]; then
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Machine with name${endColour} ${blueColour}${machine_name}${endColour} ${grayColour}is resolved in${endColour} ${greenColour}${link}${endColour}\n"
  else
    echo -e "\n${redColour}[!] Machine with name${endColour} ${blueColour}${machine_name}${endColour} ${redColour}not found.${endColour}\n"
  fi
}

function list() {
  echo -e "\n${purpleColour}$(process_list | head -n 1)${endColour}"
  echo -e "${grayColour}$(process_list | sed '1d')${endColour}\n"
}

function search_by_name() {
  machine_name=$1
  echo -e "$(cat ${file_name} | awk "/name: \"${machine_name}\"/"  | tr -d '"' | tr -d ',' | sed 's/^ *//' | awk '{print $2}')"
}

function search_by_ip() {
  ip_address=$1
  echo -e "$(cat ${file_name} | awk "/ip: \"${ip_address}\"/"  | tr -d '"' | tr -d ',' | sed 's/^ *//' | awk '{print $2}')"
}

function search_by_skills() {
  skill=$1
  echo -e "$(cat ${file_name} | awk "/like: \"${skill}\"/"  | tr -d '"' | tr -d ',' | sed 's/^ *//' | awk '{print $2}')"
}

function search() {
  machine_name=$1
  ip_address=$2
  difficulty=$3
  os=$4
  skill=$5
  result=$(process_list | sed '1,2d')

  if [ "${machine_name}" ]; then
    to_evaluate=$(search_by_name "${machine_name}")

    if [ "${to_evaluate}" ]; then
      result=$(echo "${result}" | grep "${to_evaluate}")
    else
      result=""
    fi
  fi

  if [ "${ip_address}" ]; then
    to_evaluate=$(search_by_ip "${ip_address}")

    if [ "${to_evaluate}" ]; then
      result=$(echo "${result}" | grep "${to_evaluate}")
    else
      result=""
    fi
  fi

  if [ "${difficulty}" ]; then
    case $3 in
    1)
      level="Easy"
      ;;
    2)
      level="Normal"
      ;;
    3)
      level="Difficult"
      ;;
    4)
      level="Insane"
      ;;
    *)
      show_difficulty_message
      exit 1
    esac

    result=$(echo "${result}" | grep "${level}")
  fi

  if [ "${os}" ]; then
    case $4 in
    1)
      os_label="Linux"
      ;;
    2)
      os_label="Windows"
      ;;
    *)
      show_os_message
      exit 1
    esac

    result=$(echo "${result}" | grep "${os_label}")
  fi

  if [ "${skill}" ]; then
    to_evaluate=$(search_by_skills "${skill}")

    if [ "${to_evaluate}" ]; then
      result=$(echo "${result}" | grep "${skill}")
    else
      result=""
    fi
  fi

  if [ "${result}" ]; then
    echo -e "\n${purpleColour}$(process_list | head -n 1)${endColour}"
    echo -e "${grayColour}$(process_list | head -n 2 | tail -n 1)${endColour}"
    echo -e "${grayColour}${result}${endColour}\n"
  else
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}No elements found.${endColour}\n"
  fi
}

# Execution
trap ctrl_c INT

while getopts "huly:m:i:d:o:s:" arg 2>/dev/null; do
  case $arg in
  h)
    ;;
  u)
    parameter_counter=1
    ;;
  l)
    parameter_counter=2
    ;;
  m)
    parameter_counter=3
    machine_name=$OPTARG
    ;;
  i)
    parameter_counter=3
    ip_address=$OPTARG
    ;;
  d)
    parameter_counter=3
    difficulty=$OPTARG
    ;;
  o)
    parameter_counter=3
    os=$OPTARG
    ;;
  s)
    parameter_counter=3
    skill=$OPTARG
    ;;
  y)
    parameter_counter=4
    machine_name=$OPTARG
    ;;
  *)
    echo -e "\n${redColour}[!] Invalid option${endColour}"
    help_panel
    exit 1
    ;;
  esac
done

if [ $parameter_counter -eq 1 ]; then
  update
elif [ $parameter_counter -eq 2 ]; then
  list
elif [ $parameter_counter -eq 3 ]; then
  search "${machine_name}" "${ip_address}" "${difficulty}" "${os}" "${skill}"
elif [ $parameter_counter -eq 4 ]; then
  get_youtube_link "${machine_name}"
else
  help_panel
fi