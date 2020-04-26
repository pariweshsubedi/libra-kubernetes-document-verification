# ./client.sh <validator-IP>
NODE="${1:-http://192.168.64.4}"
VALIDATOR_IP=$NODE":30080/"
FAUCET_IP=$NODE":30009/"

CLIENT_DIR="$(pwd)/$line"
KEY_FILE="$CLIENT_DIR./client/cli.key"

mkdir $CLIENT_DIR
touch KEY_FILE

cd $HOME/libra
cargo run -p generate-keypair -- -o $KEY_FILE
cargo run -p cli --bin cli -- -u $VALIDATOR_IP -f $FAUCET_IP -m $KEY_FILE