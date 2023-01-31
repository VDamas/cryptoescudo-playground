#!/bin/sh
BASE=/workspace/cryptoescudo-playground
DAEMONBASE=$BASE/cryptoescudo
DAEMON=$DAEMONBASE/cryptoescudod
DAEMONDATA=$DAEMONBASE/data
DAEMONCONF=$DAEMONDATA/cryptoescudo.conf
DAEMONSTART=$DAEMONBASE/start_daemon.sh
DAEMONDEBUG=$DAEMONBASE/cesc_debug.sh
DAEMONRESTART=$DAEMONBASE/restart_daemon.sh
DAEMONDEKILL=$DAEMONBASE/kill_daemon.sh
DAEMONQUERY=$DAEMONBASE/cesc_query.sh
DAEMONCHAINUPD=$DAEMONBASE/update_chain.sh
if [ -f "$DAEMON" ]; then
    echo "$DAEMON exists."
else
    mkdir $BASE/tmp
    mkdir cryptoescudo
    mkdir cryptoescudo/data
    cd $BASE/tmp
    wget http://cryptoescudo.pt/download/01030000/linux/cryptoescudo-1.3.0.0-linux.zip
    unzip -o cryptoescudo-1.3.0.0-linux.zip -d ./cryptoescudo
    cp -R cryptoescudo/cryptoescudo-1.3.0.0-linux/64/* ../cryptoescudo
    chmod +x $DAEMON
  
    # Create cryptoescudo daemon script
sudo tee "$DAEMONSTART" > /dev/null <<EOF
cd $BASE/tmp
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
cd $DAEMONBASE
./kill_daemon.sh
./start_daemon.sh
EOF
sudo chmod +x $DAEMONRESTART

# Create cryptoescudo query script
sudo tee "$DAEMONQUERY" > /dev/null <<EOF
$DAEMON -datadir=$DAEMONDATA \$1 \$2 \$3
EOF
sudo chmod +x $DAEMONQUERY

# Download chain up-to-date

sudo tee "$DAEMONCHAINUPD" > /dev/null <<'EOF'
cd /workspace/cryptoescudo-playground/cryptoescudo

PS3="Choose chain download source: "
options=('Cryptoescudo.work (slower / up-to-date)' 'Google Drive (faster / maybe up-to-date)')
select opt in "${options[@]}"
do
    case $opt in
        "Cryptoescudo.work (slower / up-to-date)")
            # download from cryptoescudo.work (slower, but updated at 8am every day)
            wget https://letsencrypt.org/certs/lets-encrypt-r3.pem
            wget https://cryptoescudo.work/getchain --ca-certificate=lets-encrypt-r3.pem  -O cryptoescudo.tar.gz 
	    break
            ;;
        "Google Drive (faster / maybe up-to-date)")
            # download from google drive
            SHAREID=1tlrB2WCa4ijeUan-hRc-kaRyZbER1k8n
            CONFIRM="`wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies 'https://docs.google.com/uc?export=download&id=$SHAREID' -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p'`"
            wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$CONFIRM&id=$SHAREID" -O cryptoescudo.tar.gz 
            rm -rf /tmp/cookies.txt
	    break;
            ;;
        *) echo "invalid option $REPLY";;
    esac
done

./kill_daemon.sh

# remove old data
rm -Rf data/blocks/ data/chainstate/ data/database/

# extract
tar -xf cryptoescudo.tar.gz

# move tmp
mv cryptoescudo.tar.gz ../tmp

./start_daemon.sh

EOF
sudo chmod +x $DAEMONCHAINUPD

    
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
