#! /bin/bash

###	VIRTUAL BOX CONTROLLER MAIN MENU (VBOXMAIN00) ####
	# This is the main menu for the virtualbox helper portion of the boot disk

function func_vboxmain () {

echo "VBOX CONTROLLER MAIN MENU!"
echo "Please select what you would like to do"
echo "1: Create Windows VM"
echo "2: Create Linux VM"
echo "3: Mount physical windows drive or partition to be modified"
echo "4: Mount physical linux drive or partition to be modified"
echo "5: Insert disk image into virtual drive"
echo "6: Virtual Disk Manager"
echo "7: Return to main menu"
echo "q: Quit application and reboot"

	read n 
		case $n in
		1) echo "Windows vm creator selected!"
			func_wincreate;;

		2) echo "Linux vm creator!"
			func_linuxcreate;;

		3) echo "Proceeding to physical windows drive controller"
			func_winmnt;;

		4) echo "Proceeding to physical linux drive controller"
			func_linuxmnt;;

		5) echo "Proceeding to virtual optic drive controller"
			func_imgmnt;;

		6) echo "Proceeding to virtual disk manager"
			func_vdiskmngmt;;

		7) echo "Start Virtual Machine"
			func_vboxmain;;

		q) echo "Quitting"
			exit;;

		esac

}


###		WINDOWS DISK MOUNTER(WINMNT00)	####

function func_winmnt () {

	echo "Windows Physical drive manager"
	echo "Please select what you would like to do"
	echo "1: Mount entire physical windows disk in virtualbox"
	echo "2: Mount a windows partition in virtualbox"
	echo "3: Return to previous menu"
	echo "q: Quit"

	read n
	case $n in

		1) echo "physical disk passthrough selected!"
			echo "Displaying partition table, please select which disk windows is installed on"
			lsblk
			read var_windisk
			echo "$var_windisk chosen!"
			echo "Is this correct? (Y/N)"
				read var_confirm
					if  [[ $var_confirm == y ]] || [[ $var_confirm == Y ]]; then
						echo "Mounting physical disk"
							VBoxManage internalcommands createrawvmdk \ 
							-filename /vbox/disks/windisk.vmdk -rawdisk /dev/$var_windisk \
							echo "done!"
					elif {{ $var_confirm == n ]] || [[ $var_confirm == N ]]; then
						echo "Returning to menu!"
						 func_winmnt

					fi

			echo "Returning to menu!";;


		2) echo "physical partition passthrough selected!"
				echo 






}
