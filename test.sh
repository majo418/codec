#!/bin/bash

# check if the first start argument is set
if [ -z "$1" ]; then
    echo "The first argument must be the username!"
    exit 1
fi
USERNAME=$1

# overwrite the $START_PORT environment variable with the second start argument if its a number between 1 and 65535
if [ "$2" -ge 1 ] && [ "$2" -le 65535 ]; then
    START_PORT=$2
fi

# overwrite the $PORT_COUNT environment variable with the third start argument if its a number between 1 and 1000
if [ "$3" -ge 1 ] && [ "$3" -le 1000 ]; then
    PORT_COUNT=$3
fi

# print error and exit with 1 if the environment variable START_PORT is not a number between 1 and 65535
if ! [[ $START_PORT =~ ^[0-9]+$ ]] || [ $START_PORT -lt 1 ] || [ $START_PORT -gt 65535 ]; then
    echo "The \$START_PORT environment variable must be a number between 1 and 65535"
    exit 1
fi
# set the env variable PORT_COUNT to 10 if the environment variable PORT_COUNT is not a number between 1 and 1000
if ! [[ $PORT_COUNT =~ ^[0-9]+$ ]] || [ $PORT_COUNT -lt 1 ] || [ $PORT_COUNT -gt 1000 ]; then
    PORT_COUNT=10
fi
# set END_PORT to START_PORT + PORT_COUNT - 1
END_PORT=$(($START_PORT + $PORT_COUNT - 1))

# print error and exit with 1 if the environment variable END_PORT is not a number between START_PORT and 65535
if ! [[ $END_PORT =~ ^[0-9]+$ ]] || [ $END_PORT -lt $START_PORT ] || [ $END_PORT -gt 65535 ]; then
    echo "The \$END_PORT environment variable must be a number between \$START_PORT and 65535"
    exit 1
fi

./quit.sh $USERNAME

echo "Run container \"codec_$USERNAME\" with ports \"$START_PORT-$END_PORT\"..."
# run codec docker container and publish all ports from START_PORT to END_PORT
docker run -d --privileged \
    --cpus 6 \
    --memory 8G \
    --memory-reservation 6G \
    --memory-swap 6G \
    --memory-swappiness 50 \
    --restart unless-stopped \
    --name "codec_$USERNAME" \
    -p "0.0.0.0:$START_PORT-$END_PORT:$START_PORT-$END_PORT" \
    -v "$(pwd)/.store/$USERNAME/:/home/codec/ws" \
    -e "PORT_RANGE=$START_PORT-$END_PORT" \
    --network ff_cunet \
    codec

# if out of memeory dont kill the container: --oom-kill-disable
