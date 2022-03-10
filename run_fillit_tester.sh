#!/bin/bash

RUN=".././fillit "
RUN_VALGRIND="valgrind --log-file="leaks.log" --verbose --leak-check=full .././fillit "

#### TEST FOLDER VARIABLES:
FILES_INV="failure/*fail*"
FILES_MAX="large_maps/*max*"
FILES_MEM="leaks/*"
FILES_VAL="success/*"
FILES_EVAL="evalform/*"
FILES_SPEED="speed/*"
FILES_RIGHT="output/*"

#### COLORS USED:
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
			$RUN $f >> errors.log
			printf "\n----------------\n\n" >> errors.log
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
	NR='0'
	printf "\n\t${COL_W}----TESTING VALID FILES----${COL_D}\n\n"
	for f in $FILES_VAL
	do
		printf "Solving ${COL_Y}$f${COL_D}"
		printf "\033[60G"
		$RUN $f > res.txt
		DIFF=$(diff res.txt output/valid_$NR.output)

		if [ "$DIFF" = "" ]; then
			printf "|${COL_G}OK${COL_D}|"
			#printf "\n$NR\n"
			#cat res.txt
			#cat output/valid_$NR.output
		else
			printf "|$COL_R!mistake!$COL_D|"
			printf "\n$f diff output/valid_$NR.output\t\n$DIFF\n" >> errors.log
			printf "\n----------------\n\n" >> errors.log
		fi
		NR=$((NR+1))
		sleep 0.2
		echo ""
	done
	rm res.txt
	if [ -e "errors.log" ]; then
		mv errors.log results/
	fi
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
		printf "\nSolving ${COL_Y}$f${COL_D}\n\n"
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
	printf "\n${COL_W}Testing one valid and one invalid map:${COL_D}\n"
	
	gcc -g ../*.c ../libft/libft.a -o ../fillit
	
	for f in $FILES_MEM
	do
		if [ -e "leaks.log" ]; then
			cp leaks.log results/leaks.txt
		fi
		printf "\nTrying to find memory leaks in: ${COL_Y}$f${COL_D}\n\n"
		$RUN_VALGRIND $f
		awk '/definitely/ {print "	""\033[31m"substr($0, index($0,$2))"\033[0m"}' leaks.log
		awk '/indirectly/ {print "	""\033[33m"substr($0, index($0,$2))"\033[0m"}' leaks.log
		#awk '/possibly/ {print "	""\033[32m"substr($0, index($0,$2))"\033[0m"}' leaks.log
	done
	printf "\nIf there's '${COL_W}0${COL_D}' in both definitely and indirectly lost then you're fine.\n"
	printf "\nYou can find the results in results/leaks.txt\n\n"
	printf "\n\n\n-----------------------------\n\n\n" >> results/leaks.txt
	cat leaks.log >> results/leaks.txt
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
	fi
	
	mkdir results
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
		printf "\n${COL_C}Press '${COL_D}${COL_Y}0${COL_C}' to exit${COL_D}\n"
	
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
	printf "\n\t\t${COL_W}T E S T E R  B Y  P S K Y T T A${COL_D}\n"
	printf "\n\t\t${COL_C} May Moulinette treat you well.${COL_D}\n\n"
