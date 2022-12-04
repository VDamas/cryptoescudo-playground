#!/bin/sh
DAEMON=/workspace/cryptoescudo-playground/cryptoescudo/cryptoescudod
DAEMONCONF=/workspace/cryptoescudo-playground/cryptoescudo/data/cryptoescudo.conf
if [ -f "$DAEMON" ]; then
    echo "$DAEMON exists."
else
    mkdir tmp
    mkdir cryptoescudo
    mkdir cryptoescudo/data
    cd tmp
    wget http://cryptoescudo.pt/download/01030000/linux/cryptoescudo-1.3.0.0-linux.zip
    unzip -o cryptoescudo-1.3.0.0-linux.zip -d ./cryptoescudo
    cp -R cryptoescudo/cryptoescudo-1.3.0.0-linux/64/* ../cryptoescudo
    chmod +x $DAEMON
    
    # Create cryptoescudo.conf
    rpcpass=$(openssl rand -hex 32) # generate pass
sudo tee "$DAEMONCONF" > /dev/null <<EOF
rpcuser=cryptoescudorpc
rpcpassword=$rpcpass
rpcport=61142
rpcallowip=127.0.0.1
server=1
listen=1
txindex=1
EOF
fi
