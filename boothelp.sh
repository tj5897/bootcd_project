#! /bin/bash

###	This is just the check that makes sure the /vbox directory exists, and that the /vbox/iso directory exists, if they don't, it makes it. This fires before the main menu

function func_dircheck () {

if [ -d /vbox ]; then
        echo "/vbox exists, continuing!"
else
        echo "/vbox does not exist, creating now!"
                sudo mkdir /vbox
fi

if [ -d /vbox/iso ]; then
        echo "/vbox/iso exists, continuing to menu!"
else 
        echo "/vbox/iso does not exist, creating it now!"
                sudo mkdir /vbox/iso
fi

if [ -d /vbox/vms ]; then
	echo "/vbox/vms exists, continuing"
else
	echo "/vbox/vms does not exist, creating now!"
fi

func_mainmenu
}



#	This is the meat of the code, it's the menu that lets you configure virtualbox, passthrough your physical disk, choosen which iso to stick in the virtual drive, etc

function func_vmmenu () {
echo "Virtual Machine menu!"
echo "ISO: $var_iso | Disk: $var_disk | CPUs: $var_cpu | RAM: $var_ram | OS: $var_os | VM Name: $var_name "
echo "1: Select image to mount to virtual disk"
echo "2: Select physical partition"
echo "3: Set number of cpu cores"
echo "4: Set allocated RAM"
echo "5: Select VM type"
echo "6: Set VM name"
echo "7: Save VM"
echo "8: Start VM"
echo "a: auto config"
echo "r: Return to main menu"
echo "q: Drop to command line"

#	Basic case menu

read n
case $n in
#	This part lets the user select what iso they would like to mount ie hiren's boot cd, gandalf's boot disk, a windows installation disk, a linux distro, hell DBAN too possibly

	1) echo "Please select disk image from iso folder"
		ls /vbox/iso
		read var_iso
		echo "$var_iso chosen!"
			echo "is this correct?"
				read var_confirm
					if [[ $var_confirm == y ]] || [[ $var_confirm == Y ]]; then
						echo "Proceeding!"
						func_vmmenu
					elif [[ $var_confirm == n ]] || [[ $var_confirm == N ]]; then
						echo "unsetting var_iso and Returning to menu!"
						var_iso = 0
						func_vmmenu
					fi
				echo "Done!";;

	#######	This lists the physical partitions ###########
	######  It lists the partitions with lsblk, asks the user which block device they would like to use, then creates the raw disk vmdk file in the /vbox/iso folder. 

	2) lsblk 
	 echo "Please select physcial drive the partition you wish to work on is located"
	 read var_disk
	 echo "$var_disk chosen!"
		 echo "Is this correct? (Y/N)"
			read var_confirm
				if [[ $var_confirm == y ]] || [[ $var_confirm == Y ]]; then
					echo "Proceeding!"
					sudo vboxmanage internalcommands createrawvmdk -filename /vbox/disk.vmdk -rawdisk /dev/$var_disk
				elif [[ $var_confirm == n ]] || [[ $var_confirm == N ]]; then
					echo "Unsetting var_disk and returning to menu!"
					var_disk = 0
				fi
			echo "Done!"
			func_vmmenu;;


	### Lets the user assign CPU cores to the vm"

	3) echo "Please select number of cpu cores to allocate"
		read var_cpu
		echo "you have chosen $var_cpu cores to allocate to vm, is this correct?"
			read var_confirm
				if [[ $var_confirm == y ]] || [[ $var_confirm == Y ]]; then
					echo "Proceeding!"
				elif [[ $var_confirm == N ]] || [[ $var_confirm == n ]]; then
					echo "Unsetting var_cpu and returning to menu"
					var_cpu = 0
				fi
			echo "Done!"
			func_vmmenu;;
	### Same as above, but with RAM. 
	4) echo "Please input the amount of RAM (in MB) you wish to allocate to the VM"
		read var_ram
	   echo "$var_ram chosen!"
	   echo "Is this correct? (Y/N)"
		read var_confirm
			if [[ $var_confirm == Y ]] || [[ $var_confirm == y ]]; then
				echo "Proceeding"
			elif [[ $var_confirm == n ]] || [[ $var_confirm == N ]]; then
				echo "Unsetting var_ram and returning to menu!"
				var_ram = 0
			fi
		echo "Done!"
		func_vmmenu;;

	#This will probably be automated later but it sets the vm type ie what OS you're wanting to virtualize
	5) echo "Show VM types? (Y/N)"
		read var_confirm
			if [[ $var_confirm == Y ]] || [[ $var_confirm == y ]]; then
				sudo VBoxManage list ostypes
			elif [[ $var_confirm == n ]] || [[ $var_confirm == N ]]; then
				echo "No chosen, continuning!"
			fi
		echo "Please select OS type"
			read var_os
		echo "$var_os chosen!"
		echo "Is this correct?"
			if [[ $var_confirm == Y ]] || [[ $var_confirm == y ]]; then
				echo "Continuing!"
			elif [[ $var_confirm == n ]] || [[ $var_confirm == N ]]; then
				echo "unsetting var_os and returning to menu"
					var_os=none
					func_vmmenu
			fi
		echo "Done, returning to menu!"
		func_vmmenu;;

	# You get to name it!
	6) echo "Please input vm name"
		read var_name
		echo "$var_name chosen, is this correct? (Y/N)"
			read var_confirm
			if [[ $var_confirm == Y ]] || [[ $var_confirm == y ]]; then
				echo "Continuing!"
			elif [[ $var_confirm == N ]] || [[ $var_confirm == n ]]; then
				echo "returning to menu"
				func_vmmenu
			fi
		echo "Done, returning to menu!"
		func_vmmenu;;
##	Probably going to change this later, but this section pops in the variables set by the above options, creates the vm (multiple times for now), configures it with vboxmanage and some bash arrays,
##	Then launches it. A better way to go about this would be to have this option create the vm, then have a seperate option that lists VMs and lets you choose one to launch, this opens up a modifyvm
##	option as well

	7)
		echo "Creating VM!"
			sudo vboxmanage createvm \
				--name $var_name \
				--ostype $var_os \
				--register
		echo "Done, modifying VM!"
		sudo vboxmanage modifyvm test --memory $var_ram --cpus $var_cpu
		echo "Configuring controller"
			sudo vboxmanage storagectl test \
				--name sata_controller \
				--add sata	      \
				--controller Intelahci \
				--portcount 2		\
				--bootable on
		echo "Attaching disk!"
			sudo vboxmanage storageattach test \
				--storagectl sata_controller \
				--device 0		\
				--port 0		\
				--type hdd		\
				--medium /vbox/disk.vmdk 
		echo "Attaching iso!"
			sudo vboxmanage storageattach test \
				--storagectl sata_controller \
				--device 0	\
				--port 1	\
				--type dvddrive \
				--medium "/vbox/iso/$var_iso"
		echo "Done!"
#		echo "Starting vm"
#			sudo vboxmanage startvm $var_name
		echo "Creating VM!"
		echo "vboxmanage starvm $var_name" >> /vbox/vms/$var_name
		echo "Done!"
		func_vmmenu;;


#	8) echo "

	8) echo "Please select vm to load"
		ls /vbox/vms/
	   echo "Please select vm to load"
		read var_vmsav
	  echo "$var_vmsav chosen, launching!"
		sudo bash /vbox/vms/$var_vmsav ;;
		
	a) echo "Auto configuration"
		echo "Please select which physical disk you would like to use"
			read var_autodisk
		echo "$var_autodisk chosen!"
		echo "Is this correct? (Y/N)"
			read var_confirm
				if [[ $var_confirm == Y ]] || [[ $var_confirm == y ]]; then
					echo "Proceeding!"
				elif [[ $var_confirm == N ]] || [[ $var_confirm == n ]]; then
					echo "Returning to menu!" 
					func_vmmenu
				fi
			sudo vbox
		echo "Displaying isos"
			ls /vbox/iso
		echo "Please input which iso you would like to use"
			read var_autoiso
		echo "$var_autoiso chosen!"
		echo " Is this correct (Y/N)"
			read var_confirm 
				if [[ $var_confirm == Y ]] ||  [[ $var_confirm = y ]]; then
					echo "Proceeding!"
				elif [[ $var_confirm == N ]] || [[ $var_confirm == n ]]; then
					echo "Returning to menu!"
					func_vmmenu
				fi
		
		echo "Show VM types? (Y/N)"
			read var_confirm
				if [[ $var_confirm == Y ]] || [[ $var_confirm == y ]]; then
					sudo VBoxManage list ostypes
				elif [[ $var_confirm == n ]] || [[ $var_confirm == N ]]; then
					echo "No chosen, continuning!"
				fi
		echo "Please input OS type"
			read var_autoos
		echo "$var_autoos chosen!"
		echo "Is this correct?"
				if [[ $var_confirm == Y ]] ||  [[ $var_confirm = y ]]; then
					echo "Proceeding!"
				elif [[ $var_confirm == N ]] || [[ $var_confirm == n ]]; then
					echo "Returning to menu!"
					func_vmmenu
				fi	
		echo "Creating VM with minimum requirements!"
			sudo vboxmanage createvm auto_vm \
				--name auto_vm \
				--ostype $var_autoos \
				--register
			echo "Done registering VM"
			echo "Adding min requirements"
				sudo vboxmanage modifyvm auto_vm --memory 2046 --cpus 1
					echo "Configuring controller"
						sudo vboxmanage storagectl auto \
						--name sata_controller \
						--add sata	      \
						--controller Intelahci \
						--portcount 2		\
						--bootable on
					echo "Attaching disk!"
						sudo vboxmanage storageattach auto \
							--storagectl sata_controller \
							--device 0		\
							--port 0		\
							--type hdd		\
							--medium /vbox/$var_autodisk.vmdk 
					echo "Attaching iso!"
						sudo vboxmanage storageattach auto \
							--storagectl sata_controller \
							--device 0	\
							--port 1	\
							--type dvddrive \
							--medium "/vbox/iso/$var_autoiso"
					echo "Done!"
			echo "Starting VM!"
				sudo vboxmanage startvm auto_vm
			echo "Done!"
			func_mainmenu;;

			
			
esac

}


#This is the main menu function, right now it's just the first option that does anything. As I expand and polish the vboxmanager front end, I'll expand these functions

function func_mainmenu () {

echo "MAIN MENU"
echo "1: Virtual Machine Settings"
echo "2: Download images and utilites"
echo "3: On Disk Utilities"
echo "q: quit"

read n
	case $n in
		1) echo "Going to VM menu"
			func_vmmenu;;

		2) echo "Going to download menu"
			func_downloadutil;;

		3) echo "Proceeding to on disk utils menu"
			func_utils;;

		q) echo "Dropping to command line"
			exit;;

	esac

}

##		This section is the utility/image downloader It current just downloads the latest linux LTS releases, arch, and Hiren't boot cd"
##			I'll probably add more menus allowing you to download different versions of each distro
##			Will have to figure something out for the gandalf's PE one. Might be able to host it on github, idk"
##			As for the other windows installers, this will also prove difficult to wget so I'll probably implement a function where you can rip a disk, and use that iso, or just physically
##		    	use a windows installation disk/flash drive, again features for later
function func_downloadutil () {
echo "Image and Utilities download function!"
	echo "1: Gandalf's boot cd"
	echo "2: Hiren's Boot cd"
	echo "3: Arch Linux Installer"
	echo "4: Debian Net install disk"
	echo "5: Ubuntu live disk"
	echo "6: Windows 7 Installer"
	echo "7: Windows 8.1 Installer"
	echo "8: Windows 10 Installer"
	echo "r: Return to main menu"
	
		read n
			case $n in
				
				1) echo "Downloading gandalf's boot cd"
					echo "NOT YET IMPLEMENTED!"
						func_downloadutil ;;
						
				2) echo "Downloading HBCD!"
					sudo wget -P /vbox/iso/ https://www.hirensbootcd.org/files/Hirens.BootCD.15.2.zip
					echo "Done!"
					echo "Unzipping HBCD"
						sudo unzip "/vbox/iso/Hiren's.BootCD.15.2.zip" -d /vbox/iso/
					echo "Done!"
					echo "Cleaning up!"
						sudo rm /vbox/iso/BurnCDCC.exe
						sudo rm /vbox/iso/BurnToCD.cmd
						sudo rm /vbox/iso/changes.txt
						sudo rm /vbox/iso/DefaultKeyboardPatch.zip
						sudo rm /vbox/iso/HBCD.txt
						sudo rm /vbox/iso/HBCDCustomizer.exe
						sudo rm /vbox/iso/Hirens.BootCD.15.2.zip
					echo "Done"
					echo "Returning to menu!"
						func_downloadutil;;
						
				3) echo "Downloading Arch installer!"
					sudo wget -P /vbox/iso/ http://mirrors.acm.wpi.edu/archlinux/iso/2019.05.02/archlinux-2019.05.02-x86_64.iso
					echo "Done!"
					echo "Returning to menu"
						func_downloadutil;; 
					
				4) echo "Downloading Debian net install"
					sudo wget -P /vbox/iso/ https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-9.9.0-amd64-netinst.iso
					echo "Done!"
					func_downloadutil;;
					
				5) echo "Downloading Ubuntu 18.04 live disk" 
					sudo wget -P /vbox/iso/ http://releases.ubuntu.com/18.04/ubuntu-18.04.2-desktop-amd64.iso
					echo "Done!"
					func_downloadutil;;
				
				r) echo "Returning to main menu!"
						func_mainmenu;;
					
				*) echo "Either an invalid option or a function that is not yet supported"
					func_downloadutil;;
					
			esac

}

func_dircheck
