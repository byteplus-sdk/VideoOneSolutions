go mod init
go mod tidy

echo 'Start Compiling the VideoOne Server'
sh build.sh
echo 'Successfully compiled the VideoOne Server'

echo 'Start the VideoOne Server'
cd output || exit
sh bootstrap.sh