trap "exit" SIGINT SIGTERM

if [ "$1" = 'auth' ]; then
    exec ./AuthServer.elf
elif [ "$1" = 'main' ]; then
    exec ./MainServer.elf
elif [ "$1" = 'cast' ]; then
    exec ./CastServer.elf
else
    echo "You need to specify which server to start: auth, main, or cast"
    exit 1
fi
