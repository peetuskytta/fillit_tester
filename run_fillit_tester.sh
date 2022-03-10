#!/bin/bash

RUN="./fillit "
RUN_VALGRIND="valgrind --log-file="leaks.log" ./fillit "
FILES_INV="tests/failure/*fail*"
FILES_MAX="tests/large_maps/*max*"
FILES_MEM="tests/leaks/*"
FILES_VAL="tests/success/*"
FILES_EVAL="tests/evalform/*"
FILES_SPEED="tests/speed/*"
FILES_RIGHT="tests/output/*"

COL_R="\e[1;31m"
COL_G="\e[1;32m"
COL_Y="\e[1;33m"
COL_B="\e[1;34m"
COL_C="\e[1;36m"
COL_W="\e[1;37m"
COL_D="\e[0m"

check_invalid()
{
	printf "\n\t${COL_W}----TESTING INVALID FILES----${COL_D}\n\n"
	printf "${COL_W}If you see${COL_D} |${COL_G}OK${COL_D}| ${COL_W}it means your fillit outputs an 'error' message${COL_D}\n\n"
	for f in $FILES_INV
	do
		printf "Checking ${COL_Y}$basename $f${COL_D}"
		printf "\033[60G"
		if [[ $($RUN $f | grep 'error') = 'error' ]];
		then
			printf "|${COL_G}OK${COL_D}|\n"
			sleep 0.1
		else
			printf "|$COL_R!mistake!$COL_D|\n"
			cat -e $f >> errors.log
			printf "\n----------------\n" >> errors.log
			sleep 0.1 
		fi
	done
	check_arg
	if [ -e "errors.log" ]; then
		mv errors.log results/
	fi
}

check_valid()
{		
	printf "\n\t${COL_W}----TESTING VALID FILES----${COL_D}\n"
	for f in $FILES_VAL
	do
		printf "\nSolving ${COL_Y}$f${COL_D}\n"
		$RUN $f
		#for f in $FILES_RIGHT
		#do
			#DIFF=$(diff $f res.txt)
			#printf "$DIFF\n"
			#if [ "$DIFF" = "" ]; then
			#	printf "\t\t|${COL_G}OK${COL_D}|"
			#else
			#	printf "\t\t|${COL_R}M I S T A K E${COL_D}|\n"
			#fi
		#break
		#done
		sleep 0.3
	done
	#rm res.txt
	echo ""
}

check_arg()
{
	printf "\n${COL_W}Results for the next two tests should show usage:${COL_D}\n"
	
	printf "Trying to run with ${COL_Y}no arguments:${COL_D}"
	printf "\033[60G"
	$RUN

	printf "Trying to run with ${COL_Y}two arguments:${COL_D}"
	printf "\033[60G"
	$RUN failure/empty.txt failure/test_inv1.txt
	echo ""

	printf "Trying to run with an ${COL_Y}empty file:\t${COL_D}"
	printf "\033[60G"
	if [[ $($RUN failure/empty.txt | grep 'error') = 'error' ]]; then
    	printf "|${COL_G}OK${COL_D}|\n"
        sleep 0.1
	else
		printf "|$COL_R!mistake!$COL_D|\n"
		sleep 0.1
	fi

	printf "Trying to run with ${COL_Y}non-existing file:\t${COL_D}"
	printf "\033[60G"
	if [[ $($RUN gwerty | grep 'error') = 'error' ]]; then
		printf "|${COL_G}OK${COL_D}|\n"
		sleep 0.1
	else	
		printf "|$COL_R!mistake!$COL_D|\n"
		sleep 0.1
	fi
}

check_eval()
{
	printf "\n\t${COL_W}----TESTING EVALFORM w/SPEED----${COL_D}\n"
	for f in $FILES_EVAL
	do
		printf "\nSolving ${COL_Y}$f${COL_D}\n"
		time $RUN $f 
		sleep 0.7
	done
	printf "\n${COL_W}Your fillit should solve both of these in less than a second for full bonus${COL_D}\n"
}

check_valid_speed()
{		
	printf "\n\t${COL_W}----TESTING VALID MAP SPEED----${COL_D}\n"
	for f in $FILES_SPEED
	do
		printf "\nSolving ${COL_Y}$f${COL_D}\n"
		time $RUN $f & spinner
	done
}
check_max()
{		
	printf "\n\t${COL_W}----TESTING MAX MAP----${COL_D}\n"
	for f in $FILES_MAX
	do
		printf "\nSolving ${COL_Y}$f${COL_D}\n"
		time $RUN $f & spinner
	done
}

check_memory_leaks()
{		
	printf "\n\t${COL_W}----TESTING FOR MEMORY LEAKS----${COL_D}\n"
	printf "\t\t${COL_C}USING VALGRIND${COL_D}\n"
	for f in $FILES_MEM
	do
		if [ -e "leaks.log" ]; then
			cp leaks.log leaks.txt
		fi
		printf "\nTrying to find memory leaks in: ${COL_Y}$f${COL_D}\n\n"
		$RUN_VALGRIND $f
		awk '/definitely/ {print "	""\033[31m"substr($0, index($0,$2))"\033[0m"}' leaks.log
		awk '/indirectly/ {print "	""\033[33m"substr($0, index($0,$2))"\033[0m"}' leaks.log
		awk '/possibly/ {print "	""\033[32m"substr($0, index($0,$2))"\033[0m"}' leaks.log
	done
	printf "\n If there's '${COL_W}0${COL_D}' in both definitely and indirectly lost then you're fine.\n"
	printf "\n\n\n-----------------------------\n\n\n" >> leaks.txt
	cat leaks.log >> leaks.txt
	rm leaks.log
}

spinner()
{
    local pid=$!
    local delay=0.75
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        printf "\b\b\b\b\b\b"
        sleep $delay
    done
 	printf " "
}

#check_norm()
#{

#}


printf "\n\n----${COL_Y}W E L C O M E  T O  F I L L I T  T E S T E R${COL_D}----\n\n"

if [ -d "results" ]; then
	rm -r results
	mkdir results
fi
check='9'
ref='^[0-8]+$'
while [ $check -ne 0 ]
do
	echo "_____________________________________________________"
	printf "\nPress '${COL_G}1${COL_D}' (invalid maps/files)\n"
	printf "Press '${COL_G}2${COL_D}' (valid maps)\n"
	printf "Press '${COL_G}3${COL_D}' (evaluation form)\n"
	printf "Press '${COL_G}4${COL_D}' (speed tests: 10-30s)\n"
	printf "Press '${COL_G}5${COL_D}' (max map test: 1-10min)\n"
	printf "Press '${COL_G}6${COL_D}' (memory leaks)\n"
	printf "\nPress '${COL_Y}0${COL_D}' to exit\n"
	read -sn1 check
		if ! [[ $check =~ $ref ]]; then
			clear
			printf "\n${COL_R}Please, choose one of the options below:${COL_D}\n"
			check='9'
		elif [ $check -eq 1 ]; then
			clear
			check_invalid
		elif [ $check -eq 2 ]; then
			clear
			check_valid
		elif [ $check -eq 3 ]; then
			clear
			check_eval
		elif [ $check -eq 4 ]; then
			clear
			check_valid_speed
		elif [ $check -eq 5 ]; then
			clear
			check_max
		elif [ $check -eq 6 ]; then
			clear
			check_memory_leaks
		fi
done
clear
mv leaks.txt results/
printf "\n\t\t${COL_W}T E S T E R  B Y  P S K Y T T A${COL_D}\n"
printf "\n\t\t${COL_C} May Moulinette treat you well.${COL_D}\n\n"
