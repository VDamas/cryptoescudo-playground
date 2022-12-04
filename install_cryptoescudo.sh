#!/bin/sh
BASE=/workspace/cryptoescudo-playground/cryptoescudo
DAEMON=$BASE/cryptoescudod
DAEMONDATA=$BASE/data
DAEMONCONF=$DAEMONDATA/cryptoescudo.conf
DAEMONSTART=$BASE/start_daemon.sh
DAEMONDEBUG=$BASE/cesc_debug.sh
DAEMONRESTART=$BASE/restart_daemon.sh
DAEMONDEKILL=$BASE/kill_daemon.sh
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
cd $BASE
$DAEMON -datadir=$DAEMONDATA -daemon
EOF
sudo chmod +x $DAEMONSTART

# Create cryptoescudo debug script
sudo tee "$DAEMONDEBUG" > /dev/null <<EOF
tail -f $DAEMONDATA/debug.log
EOF
sudo chmod +x $DAEMONDEBUG

# Kill cryptoescudo daemon
sudo tee "$DAEMONDEKILL" > /dev/null <<EOF
pkill -9 -f 'cryptoescudo'
EOF
sudo chmod +x $DAEMONDEKILL

# Restart cryptoescudo daemon
sudo tee "$DAEMONRESTART" > /dev/null <<EOF
cd $BASE
./kill_daemon.sh
./start_daemon.sh
EOF
sudo chmod +x $DAEMONRESTART

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

clear
cd cryptoescudo
fi
