clear

#cleanup
rm -rf build/*

#check root for mount/umount
if [ $(whoami) != 'root' ]; then
echo "\nNEED ROOT\n"
exit
else

#build bootloader
if [ -f src/boot/bootloader.asm ]; then
	echo "Assembling Bootloader..."
	nasm -O0 -w+orphan-labels -f bin -o build/bootloader.bin src/boot/bootloader.asm || exit
	stat -c %s build/bootloader.bin	#512 Bytes
	echo "Done!"
else
	echo "\nbootloader.asm not found!\n"
	exit
fi

#build kernel
if [ -f src/stubkernel/kernel.asm ]; then
	echo "\n\nAssembling Kernel..."
	nasm -O0 -w+orphan-labels -f bin -o build/KERNEL.BIN src/stubkernel/kernel.asm || exit
	stat -c %s build/KERNEL.BIN	#26368 Bytes
	echo "Done!"
else
	echo "\nkernel.asm not found!\n"
	exit
fi

#generate 2880 KB FAT12 image
echo "\n\nGenerating 2880 KB Image..."
/sbin/mkdosfs -v -F 12 -C build/os_image.img 2880 || exit
echo "Done!"


#install bootloader to the image
echo "\n\nInstalling Bootloader into the Image..."
dd status=noxfer conv=notrunc if=build/bootloader.bin of=build/os_image.img || exit
echo "Bootloader installed!\n"



#mount os_image.img
echo "\n\nMounting os_image.img"
mkdir build/mount_point
mount -o loop build/os_image.img build/mount_point || exit
echo "\nCopying the Kernel and programs..."




#===================================================================================================
#copy KERNEL.BIN and programs
cp build/KERNEL.BIN build/mount_point || exit
echo "Done"

echo '\n\n\n\nPress [ENTER] to unmount\nCTRL + C to quit'
read x
#===================================================================================================




#unmount os_image.img
sleep 0.2
echo "\nUnmounting os_image.img"
umount build/mount_point
rm -r build/mount_point


#query about os_image.img
if [ -f build/os_image.img ]; then
	echo "\n\nOS Image Generated!..."
	stat -c %s build/os_image.img
else
	echo "\n\nOS Image Not Generated"
	exit
fi


#set attribs
chmod -R a+rw build/


echo "\n\nDONE!\n"
fi
