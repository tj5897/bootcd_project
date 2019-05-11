#! /bin/bash

function func_dircheck () {

if [ -d /vbox ]; then
	echo "Vbox directory exists, proceeding!"
else 
	echo "Vbox directory does not exist, creating it now!"
	sudo mkdir /vbox
fi

if [ -d /vbox/iso ]; then
	echo "/vbox/iso directory exists, proceeding!"
else
	echo "/vbox/iso does not exist! Creating now!"
		sudo mkdir /vbox/iso
fi

func_mainmenu

}

function func_autowin () {
echo "Automated windows helper"
echo "Checking for gandalf boot cd"
	if [ -f "/vbox/iso/gandalf.iso" ]; then
		echo "gandalf's boot cd found!"
		echo "Proceeding!"
		
	else
		echo "Not yet implemented!"	
#	wget $josh_serverip/gandalf.iso

	fi

lsblk
echo "Please select which disk your windows partition is located on"
read var_windisk
echo "$var_windisk chosen!"
echo "Is this correct (Y/N)"
read var_confirm
	if  [[ $var_confirm == y ]] || [[ $var_confirm == Y ]]; then
						echo "Mounting physical disk"
							VBoxManage internalcommands createrawvmdk -filename /vbox/windisk.vmdk -rawdisk /dev/$var_windisk
							echo "done!"
	elif [[ $var_confirm == n ]] || [[ $var_confirm == N ]]; then
						echo "Restarting"
						func_autowin
	fi

echo "Creating virtual machine!"
	sudo vboxmanage createvm \
		--name win10	\
		--ostype Windows10_64 \
		--register
echo "Done!"

echo "Modifying VM!"
	sudo vboxmanage modifyvm win10 --memory 4096 --cpus 2
#		--memory 4096 	\
#		--cpus	2		\
#		--nic1	nat		
echo "Done!"

echo "configuring controllers"
	sudo vboxmanage storagectl win10 \
			--name sata_controller \
			--add sata 				\
			--controller Intelahci	\
			--portcount 2			\
			--bootable on

echo "Attaching disk!"
	sudo vboxmanage storageattach win10	\
		--storagectl sata_controller \
		--device 0	\
		--port 0	\
		--type hdd	\
		--medium /vbox/windisk.vmdk	

echo "Attaching iso"
	sudo vboxmanage storageattach win10	\
		--storagectl sata_controller	\
		--port 1	\
		--device 0	\
		--type dvddrive	\
		--medium "/vbox/iso/gandalf.iso"

echo "Done!"

echo "Starting vm!"
	sudo vboxmanage startvm win10
echo "Done!"

}


function func_mainmenu () {

echo "Bootcd MAIN MENU"
echo "1: Automated Windows helper"
echo "2: Automated Linux helper"
echo "3: On disk utilities"
echo "4: Manual virtualbox helper"
echo "q: quit"

read n
	case $n in
		1) echo "Starting automated windows helper"
				func_autowin;;
				
		2) echo "Starting automated linux helper"
				func_autolinux;;
		
		3) echo "Proceeding to utilities menu"
				func_ondiskutils;;
				
		4) echo "Proceeding to manual vbox helper"
				func_manualmenu;;
				
		q) echo "Dropping to shell!"
				exit;;
				
	esac


}

func_dircheck

