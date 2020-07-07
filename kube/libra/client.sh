# ./client.sh <validator-forwarded-IP> <faucet-forwarded-IP>
VALIDATOR_PORT="${1:-5000}"
FAUCET_PORT="${1:-5002}"
VALIDATOR_IP="http://localhost:"$VALIDATOR_PORT"/"
FAUCET_IP="http://localhost:"$FAUCET_PORT"/"

CLIENT_DIR="$(pwd)/$line"
KEY_FILE="$CLIENT_DIR./client/cli.key"

mkdir $CLIENT_DIR

cd $HOME/libra
cargo run -p generate-keypair -- -o $KEY_FILE
cargo run -p cli --bin cli -- -u $VALIDATOR_IP -f $FAUCET_IP -m $KEY_FILE