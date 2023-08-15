#!/bin/bash

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"


function ctrl_c(){
  echo -e "\n\n${redColour}[!] Saliendo...${endColour}\n"
  tput cnorm && exit 1
}

#Ctrl+c
trap ctrl_c INT

#Variables globales
main_url="https://htbmachines.github.io/bundle.js"

function helpPanel(){
  echo -e "\n${yellowColour}[+]${endColour}${grayColour} Uso:${endColour}"
  echo -e "\t${purpleColour}u)${endColour}${grayColour} Descargar o actualizar archivos necesarios${endColour}" 
  echo -e "\t${purpleColour}m)${endColour}${grayColour} Buscar por un nombre de maquina${endColour}"
  echo -e "\t${purpleColour}s)${endColour}${grayColour} Buscar por Skill${endColour}"
  echo -e "\t${purpleColour}i)${endColour}${grayColour} Buscar por dirección IP${endColour}"
  echo -e "\t${purpleColour}o)${endColour}${grayColour} Buscar por sistema operativo${endColour}"
  echo -e "\t${purpleColour}d)${endColour}${grayColour} Buscar por la dificultad de una máquina${endColour}"
  echo -e "\t${purpleColour}h)${endColour}${grayColour} Mostrar el panel de ayuda${endColour}\n"
   
}

function updateFiles(){  
  if [ ! -f bundle.js ]; then
    tput civis
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Descargando archivos necesarios...${endColour}"
    curl -s $main_url > bundle.js
    js-beautify bundle.js | sponge bundle.js 
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Todos los archivos han sido descargados${endColour}"
    tput cnorm
  else
    tput civis
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Comprobando si hay actualizaciones pendientes...${endColour}"
    curl -s $main_url > bundle_temp.js
    js-beautify bundle_temp.js | sponge bundle_temp.js
    md5_temp_value=$(md5sum bundle_temp.js | awk '{print $1}')
    md5_original_value=$(md5sum bundle.js | awk '{print $1}')
    
    if [ "$md5_temp_value" == "$md5_original_value" ]; then
      echo -e "\n${yellowColour}[+]${endColour}${grayColour} No se han detectado actualizaciones, lo tienes todo al dia${endColour}"
      rm bundle_temp.js
    else 
      echo -e "\n${yellowColour}[+]${endColour}${grayColour} Se han encontrado actualizaciones disponibles${endColour}"
      sleep 1

      rm bundle.js && mv bundle_temp.js bundle.js 
      sleep 1

      echo -e "\n${yellowColour}[+]${endColour}${grayColour} Los archivos han sido actualizados${endColour}"
    fi

    tput cnorm
  fi
}

function searchMachine(){
  machineName="$1"

  machineName_checker="$(cat bundle.js | awk "BEGIN {IGNORECASE = 1} /name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '"' | tr -d ',' | sed 's/^ *//')"
  
  if [ "$machineName_checker" ]; then
    # Declarar variables
    name="$(cat bundle.js | awk "BEGIN {IGNORECASE = 1} /name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta:" | tr -d '"' | tr -d ',' | sed 's/^ *//' | grep "name:" | awk 'NF {print $NF}')"
    ip="$(cat bundle.js | awk "BEGIN {IGNORECASE = 1} /name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta:" | tr -d '"' | tr -d ',' | sed 's/^ *//' | grep "ip:" | awk 'NF {print $NF}')"
    so="$(cat bundle.js | awk "BEGIN {IGNORECASE = 1} /name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta:" | tr -d '"' | tr -d ',' | sed 's/^ *//' | grep "so:" | awk 'NF {print $NF}')"
    dificultad="$(cat bundle.js | awk "BEGIN {IGNORECASE = 1} /name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta:" | tr -d '"' | tr -d ',' | sed 's/^ *//' | grep "dificultad: " | awk 'NF {print $NF}')"
    skills="$(cat bundle.js | awk "BEGIN {IGNORECASE = 1} /name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta:" | tr -d '"' | tr -d ',' | sed 's/^ *//' | grep "skills:" | awk -F 'skills:' '{print $2}')"
    like="$(cat bundle.js | awk "BEGIN {IGNORECASE = 1} /name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta:" | tr -d '"' | tr -d ',' | sed 's/^ *//' | grep "like:" | awk -F 'like:' '{print $2}')"
    youtube="$(cat bundle.js | awk "BEGIN {IGNORECASE = 1} /name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta:" | tr -d '"' | tr -d ',' | sed 's/^ *//' | grep "youtube:" | awk 'NF {print $NF}')"
    activeDirectory="$(cat bundle.js | awk "/name: \"$name\"/,/resuelta:/" | grep -vE "id:|resuelta:" | tr -d '"' | tr -d ',' | sed 's/^ *//' | grep "activeDirectory:" | awk -F 'activeDirectory:' '{print $2}')"
  
    # Imprimir variables
    echo -e "\n${yellowColour}[+]${grayColour} Listando las propiedades de la maquina${blueColour} $name${grayColour}:${endColour}\n"
    echo -e "${yellowColour} - ${grayColour} Nombre:${blueColour} $name${endColour}"
    echo -e "${yellowColour} - ${grayColour} IP:${blueColour}$ip${endColour}"
    echo -e "${yellowColour} - ${grayColour} Sistema operativo:${blueColour} $so${endColour}"
    echo -e "${yellowColour} - ${grayColour} Dificultad:${blueColour} $dificultad${endColour}"
    echo -e "${yellowColour} - ${grayColour} Skills:${blueColour}$skills${endColour}"
    echo -e "${yellowColour} - ${grayColour} Like:${blueColour}$like${endColour}"
    if [ "$activeDirectory" ]; then  
      echo -e "${yellowColour} - ${grayColour} Active Directory:${blueColour}$activeDirectory${endColour}"
    fi
    echo -e "${yellowColour} - ${grayColour} Link de youtube:${blueColour} $youtube${endColour}"

  else
    echo -e "\n${redColour}[!] La máquina proporcionada no existe${endColour}\n"
  fi

}

function searchIP(){
  ipAddress="$1"

  machineName="$(cat bundle.js | grep "ip: \"$ipAddress\"" -B 3 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',')"

  if [ "$machineName" ]; then

    echo -e "\n${yellowColour}[+]${endColour}${grayColour} La maquina correspondiente para la IP${endColour}${blueColour} $ipAddress${endColour}${grayColour} es${endColour}${purpleColour} $machineName${endColour}"

    searchMachine $machineName
  else
    echo -e "\n${redColour}[!] La dirección IP proporcionada no existe${endColour}\n"
  fi
}

function transformDifficulty(){
  difficulty="$1"
  difficulty=$(echo $difficulty | tr '[:upper:]' '[:lower:]')
  difficulty=$(echo $difficulty | sed 's/á/a/g; s/é/e/g; s/í/i/g; s/ó/o/g; s/ú/u/g')

  if [ "$difficulty" == "facil" ]; then
    difficulty="Fácil"
  elif [ "$difficulty" == "media" ]; then    
    difficulty="Media"
  elif [ "$difficulty" == "dificil" ]; then
    difficulty="Difícil"
  elif [ "$difficulty" == "insane" ]; then
    difficulty="Insane"
  fi

  echo "$difficulty"
}

function getMachinesDifficulty(){
  difficulty="$1"
  results_check="$(cat bundle.js | grep "dificultad: \"$difficulty\"" -B 5 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"

  if [ "$results_check" ]; then
    echo -e "\n${yellowColour}[+]${grayColour} Representando las máquinas que poseen un nivel de dificultad${purpleColour} $difficulty${grayColour}:${endColour}\n"
    cat bundle.js | grep "dificultad: \"$difficulty\"" -B 5 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column
  else   
    echo -e "\n${redColour}[!] La dificultad indicada no existe${endColour}\n"
  fi
}

function getOSMachines(){
  os="$1"

  os_results="$(cat bundle.js | grep "so: \"$os\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"
  
  if [ "$os_results" ]; then
    
    echo -e "\n${yellowColour}[+] ${grayColour}Mostrando las maquinas cuyo sistema operativo es ${blueColour}$os${grayColour}:${endColour}\n"
    cat bundle.js | grep "so: \"$os\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column
  else 
    echo -e "\n${redColour}[!] El sistema operativo indicado no existe${endColour}\n"
  fi
}

function getOSDifficultyMachines(){
  difficulty="$1"
  os="$2"

  check_results="$(cat bundle.js | grep "so: \"$os\"" -C 4 | grep "dificultad: \"$difficulty\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"

  if [ "$check_results" ]; then
    
    echo -e "\n${yellowColour}[+] ${grayColour}Mostrando las maquinas cuyo sistema operativo es ${blueColour}$os ${grayColour}y son de dificultad ${purpleColour}$difficulty${grayColour}:${endColour}\n"
  
    cat bundle.js | grep "so: \"$os\"" -C 4 | grep "dificultad: \"$difficulty\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column

  else
    echo -e "\n${redColour}[!] El sistema operativo o la dificultad indicadas no existen o son incorrectos${endColour}\n"
  fi

}

function getSkill(){
  skill="$1"

  check_skill="$(cat bundle.js | grep "skills: " -B 6 | grep "$skill" -i -B 6 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"

  if [ "$check_skill" ]; then 
    echo -e "\n${yellowColour}[+] ${grayColour}A continuacion se representan las maquinas donde es necesaria la skill ${blueColour}$skill ${grayColour}:${endColour}\n"
    cat bundle.js | grep "skills: " -B 6 | grep "$skill" -i -B 6 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column
  else
    echo -e "\n${redColour}[!] El skill indicado no existen o es incorrecto${endColour}\n"
  fi
}

#Indicadores
declare -i parameter_counter=0
declare -i ack_difficulty=0
declare -i ack_os=0

while getopts "m:ui:d:o:s:h" arg; do
  case $arg in
    m) machineName="$OPTARG"; let parameter_counter+=1;;
    u) let parameter_counter+=2;;
    i) ipAddress="$OPTARG"; let parameter_counter+=3;;
    d) difficulty="$OPTARG"; ack_difficulty=1 ;let parameter_counter+=4;;
    o) os="$OPTARG"; ack_os=1 ;let parameter_counter+=5;;
    s) skill="$OPTARG";let parameter_counter+=6;;
    h) ;;
  esac

done

if [ $parameter_counter -eq 1 ]; then
  searchMachine $machineName
elif [ $parameter_counter -eq 2 ]; then
  updateFiles  
elif [ $parameter_counter -eq 3 ]; then
  searchIP $ipAddress
elif [ $parameter_counter -eq 4 ]; then
  difficulty=$(transformDifficulty $difficulty)
  getMachinesDifficulty $difficulty
elif [ $parameter_counter -eq 5 ]; then
  os=$(echo ${os^})
  getOSMachines $os
elif [ $parameter_counter -eq 6 ]; then
  getSkill "$skill"
elif [ $ack_difficulty -eq 1 ] && [ $ack_os -eq 1 ]; then
  difficulty=$(transformDifficulty $difficulty)
  os=$(echo ${os^})
  getOSDifficultyMachines $difficulty $os
else
  helpPanel
fi
