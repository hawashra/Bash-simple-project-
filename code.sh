#!/bin/bash

red='\e[31m'
reset='\e[0m'
green='\e[32m'
cyan='\e[36m'

read -p "please enter contacts file name: " filename

if [[ ! -e $filename ]]; then 
	echo $red"File not found"$reset
	exit 1
fi  



printMenu() {


echo -ne $cyan"
					MAIN MENU\n"$reset

echo -ne "
				==============================
				[1].$red Add$reset a new contact
				[2].$red List$reset all contacts
				[3].$red Search$reset for contact
				[4].$red Edit$reset a contact
				[5].$red Delete$reset a contact
				[0].$red Exit$reset
				==============================
				Enter the choice: \n"
				
}

addnew() {

	echo -ne "\nPlease enter contact info:\n"$reset
	while true; do 
	
			
		read -p "first name: " fname
		
		if [[ "$fname" =~ ^[A-Za-z]{2,}$ ]]; then
		
			break 
			
		else
			echo -ne $red"\nInvalid first name\n"$reset

		fi 
		
	done 
	
	
	while true; do 
	
		echo -ne "\n$green[optional]$reset Please enter last name, or leave it blank:  "
		
		read lname
		
		if [[ "$lname" =~ ^[A-Za-z]{2,}$ ]] || [[ -z "$lname" ]]; then 
		
			break
			
		else 
			echo -ne $red"\nInvalid last name\n"$reset
		fi 
			
	done 
	
	
	while true; do 
	
		echo -ne "\nPlease enter phone number(s). If more than one, separate them with a ';'\n"
		
		read -p "Phone number(s): " pnums
		
		# more than one phone number, the variable is set ( ! -z ) if so. 
		more_than_one=$(grep ";" <<< $pnums)
				
		# split the phone numbers and check each one of them
		if [[ ! -z "$more_than_one" ]]; then 
		
			noOfPNums=$(tr ';' '\12' <<< $pnums | wc -l)
			for ((i=1; i <=$noOfPNums; i++)); do 
			
				num=$(cut -d';' -f$i <<< "$pnums")
				if [[ "$num" =~ ^[0-9]{9,10}$ ]]; then 
					
					if [[ $i -eq $noOfPNums ]]; then 
					
						break 2
					fi
					
				else
					break
				fi
				
				
			done
			
			echo -ne "$red""invalid phone numbers\n""$reset"
			continue 	
			
		else
			if [[ "$pnums" =~ ^[0-9]{9,10}$ ]]; then 
				break
			else
				echo -ne "$red""invalid phone number\n""$reset"
				continue 
			fi
		
		fi 
			
	done
	
	
	while true; do 
	
		echo -ne "\n$green[optional]$reset Please enter email: \n"
		read email 
		
		if [[ "$email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$ ]] || [[ -z "$email" ]]; then 
		
			break 
		else
			echo "$red""\ninvalid email\n"$reset
		fi 

	done 	
	

	echo "$fname, $lname, $pnums, $email" >> "$filename"
}

listAll() {

	local sourcefile=$1


	echo -ne "$green""List on firstname or lastname(1/2): ""$reset" 

	read choice 
	
	echo 
	
	if [[ $choice -eq 1 ]]; then 
	
		printf "%-20s%-20s%-20s\n" "FIRST NAME" "PHONE NUMBER" "E-MAIL"
		
	else 
		printf "%-20s%-20s%-20s\n" "LAST-NAME" "PHONE NUMBER" "E-MAIL"
		
	fi 
	
	
	while read -r line; do 
	
	
		local fname=$(cut -d',' -f1 <<<$line)
		local lname=$(cut -d',' -f2 <<<$line | cut -d' ' -f2)
		local pnum=$(cut -d',' -f3 <<<$line | cut -d';' -f1 | cut -d' ' -f2)
		local email=$(cut -d',' -f4 <<<$line | cut -d' ' -f2) 
		if [[ $choice -eq 1 ]]; then
		
			printf "%-20s%-20s%-20s\n" "$fname" "$pnum" "$email"
		
		else 
		
			if [[ ! -z "$lname" ]]; then 
		
				printf "%-20s%-20s%-20s\n" "$lname" "$pnum" "$email"
			else 
				printf "%-20s%-20s%-20s$green%s$reset\n" "$fname" "$pnum" "$email" "No lname, printed fname instead"
			fi
				
			
		fi  
	

	done<"$sourcefile"
}

search() {
	read -p "Enter search keywords: " keywords
	grep "$keywords" "$filename" > search.txt
	
	listAll "search.txt"
}

update() {

	read -p "Enter filed you want to edit: " field

	found=$(grep "$filed" "$filename")

	if [[ -z "$found" ]]; then 
		echo -ne "\nNo matching\n"
		return 
	else
		read -p "Enter the new field: " newfield
	fi
	
	
	if [[ "$field" =~ ^[A-Za-z]{2,}$ ]] && [[ "$newfield" =~ ^[A-Za-z]{2,}$ ]]; then
		sed -i "s/"$field"/"$newfield"/" "$filename"
		 
	elif [[ "$field" =~ ^[A-Za-z]{2,}$ ]] && [[ ! "$newfield" =~ ^[A-Za-z]{2,}$ ]]; then 
		echo -ne "$red""name is invalid"$reset
	 
	 elif [[ "$field" =~ ^[0-9]{9,10}$ ]] && [[ "$newfield" =~ ^[0-9]{9,10}$ ]]; then 
	 
		sed -i "s/"$field"/"$newfield"/" "$filename"
	 	
 	elif [[ "$field" =~ ^[0-9]{9,10}$ ]] && [[ ! "$newfield" =~ ^[0-9]{9,10}$ ]]; then 
		echo -ne "$red""phone number is invalid"$reset
		
	elif [[ "$field" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$ ]] && [[ "$newfield" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$ ]]; then 
	
		sed -i "s/"$field"/"$newfield"/" "$filename"
	 	
 	elif [[ "$field" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$ ]] && [[ ! "$newfield" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$ ]]; then 
 	
 		echo -ne $red"\nEmail is not valid\n"$reset
 		
 		
	else 
		echo -ne $red"\ninvalid new field\n"$reset
 	
	fi
}

delete() {


	read -p "Ente phone number: " pnum
	
	
	found=$(grep "$pnum" "$filename")
	
	if [[ -z "$found" ]]; then 
	
		echo -ne $red"\nNot found\n"$reset
		return
		
	else
		echo "The contact is $found, do you want to delete it?\n"
		read -p "(y/n): " ans
		
		
		if [[ ans == "y" ]]; then 
		
			sed -ie "s/"$found"//" "$filname"
		fi 
	fi 
} 

	

while true; do 

printMenu 

read choice 

case $choice in 

1) addnew   			;;
2) listAll "$filename"	;;
3) search				;;
4) update				;;
5) delete				;;
0) exit 0				;;

esac 

done 














