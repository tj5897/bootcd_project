#! /bin/bash

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

func_mainmenu
}


function func_vmmenu () {
echo "Virtual Machine menu!"
echo "ISO: $var_iso | Disk: $var_disk | CPUs: $var_cpu | RAM: $var_ram | OS: $var_os | VM Name: $var_name "
echo "1: Select image to mount to virtual disk"
echo "2: Select physical partition"
echo "3: Set number of cpu cores"
echo "4: Set allocated RAM"
echo "5: Select VM type"
echo "6: Set VM name"
echo "7: Start VM"
echo "r: Return to main menu"
echo "q: Drop to command line"

read n
case $n in
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
					var_os = 0
					func_vmmenu
			fi
		echo "Done, returning to menu!"
		func_vmmenu;;


	7) echo "starting VM!" 
		echo "Creating VM!"
			sudo vboxmanage create vm \
				--name test \
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
		echo "Starting vm"
			sudo vboxmanage startvm test
		echo "Done!"
		func_vmmenu;;
		
esac

}




function func_mainmenu () {

echo "MAIN MENU"
echo "1: Virtual Machine Settings"
echo "2: Download isos"
echo "3: On Disk Utilities"
echo "q: quit"

read n
	case $n in
		1) echo "Going to VM menu"
			func_vmmenu;;

		2) echo "Going to download menu"
			func_download;;

		3) echo "Proceeding to on disk utils menu"
			func_utils;;

		q) echo "Dropping to command line"
			exit;;

	esac

}

func_dircheck