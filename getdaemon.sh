#!/bin/sh
DAEMON=/workspace/cryptoescudo-playground/cryptoescudo/cryptoescudod
if [ -f "$DAEMON" ]; then
    echo "$DAEMON exists."
else
    mkdir tmp
    mkdir cryptoescudo
    cd tmp
    wget http://cryptoescudo.pt/download/01030000/linux/cryptoescudo-1.3.0.0-linux.zip
    unzip -o cryptoescudo-1.3.0.0-linux.zip -d ./cryptoescudo 
    cp -R cryptoescudo/cryptoescudo-1.3.0.0-linux/64/* ../cryptoescudo
    chmod +x $DAEMON
fi
