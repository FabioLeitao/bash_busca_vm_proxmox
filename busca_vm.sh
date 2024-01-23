#!/bin/bash
COMMAND=$0
ARGUMENTO=$1
FLAG=$2

QM=`which qm`
ID=`which id`

function check_service_(){
	VMIsRunning=false
	BUSCA=`${QM} list | grep ${ARGUMENTO} | grep running`
	ULTIMA=$?
	if [ ${ULTIMA} -eq 0 ] ; then
		VMIsRunning=true
		VM_NAME=`${QM} list | grep ${ARGUMENTO} | awk -F' ' {'print $2'}`
		echo "0:200:OK - VM ${ARGUMENTO} - ${VM_NAME} is running."    # returncode 0 = put sensor in OK status
	else
		echo "1:404:WARNING - VM ${ARGUMENTO} is not present or not running."    # returncode 1 = put sensor in WARNING status
	fi
}

die_(){
	exit 999
}

is_root_(){
	local id=$(${ID} -u)
	if [ $id -ne 0 ] ; then
		echo "4:500:ERROR - You have to be root to run $0."    # returncode 4 = put sensor in DOWN status
		die_ ;
	fi
}

function preparation_(){
	if [ ! -x ${QM} ] ; then 
		echo "2:500:ERROR - command qm not found."
		die_ ; 
	fi
	if [ ! -x ${ID} ] ; then
		echo "2:500:ERROR - command id not found."    # returncode = 2 = put sensor in DOWN status
		die_ ; 
	fi
	is_root_;
}

function ajuda_(){
        echo "2:500:ERROR - Usage: ${COMMAND} [ProxMox VM Identification Number] [-h|--help]" >&2 ;
	die_ ;
}

function atua_no_flag_(){
        if [ $# -gt 1 ]; then
                ajuda_;
        else
          case "${FLAG}" in
                -h|--help)
                        ajuda_ ;
                        ;;
                *)
                        ;;
          esac
        fi
}

function main_(){
        atua_no_flag_ ;
	preparation_;
	check_service_;
}

if [ $# -lt 1 ]; then
        	ajuda_;
else
  case "${ARGUMENTO}" in
       	-h|--help)
               	ajuda_ ;
                exit 1
       	        ;;
        *)
		main_;
               	;;
  esac
fi
exit 0
