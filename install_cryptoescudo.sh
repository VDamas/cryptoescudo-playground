#!/bin/sh
BASE=/workspace/cryptoescudo-playground/cryptoescudo
DAEMON=$BASE/cryptoescudod
DAEMONDATA=$BASE/data
DAEMONCONF=$DAEMONDATA/cryptoescudo.conf
DAEMONSTART=$BASE/start_daemon.sh
DAEMONQUERY=$BASE/cesc_query.sh
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
  
    # Create cryptoescudo daemon script
sudo tee "$DAEMONSTART" > /dev/null <<EOF
$DAEMON -datadir=$DAEMONDATA -daemon
EOF
sudo chmod +x $DAEMONSTART

# Create cryptoescudo debug script
sudo tee "$cescdebugscript" > /dev/null <<EOF
tail -f $DAEMONDATA/debug.log
EOF
sudo chmod +x $cescdebugscript

# Create cryptoescudo query script
sudo tee "$DAEMONQUERY" > /dev/null <<EOF
$DAEMON -datadir=$DAEMONDATA \$1 \$2 \$3
EOF
sudo chmod +x $DAEMONQUERY
    
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
