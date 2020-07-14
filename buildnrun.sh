clear


if [ $(whoami) != 'root' ]; then
echo '\nNEED ROOT\n'
exit
else


./build.sh

echo '\n\n\n\nPress [ENTER] to continue\nCTRL + C to quit'
read x

./run.sh


fi
