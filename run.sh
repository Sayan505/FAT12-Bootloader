clear

if [ $(whoami) != 'root' ]; then
echo "\nNEED ROOT\n"
exit
else


if [ -f $(pwd)/build/os_image.img ]; then

	qemu-system-x86_64 -display gtk -soundhw pcspk -m 1M -drive format=raw,file=build/os_image.img,index=0,if=floppy

else

	echo "os_image.img not found!"

fi


fi
