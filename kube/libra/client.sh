# ./client.sh <validator-IP>
VALIDATOR="${1:-http://192.168.64.4}"

BASEDIR=
CLIENT_DIR="$(pwd)/$line"
KEY_FILE="$CLIENT_DIR./client/cli.key"

mkdir $CLIENT_DIR
touch KEY_FILE

cd $HOME/libra
cargo run -p generate-keypair -- -o $KEY_FILE
cargo run -p cli --bin cli -- -u $VALIDATOR:8080 -f $VALIDATOR:9080 -m $KEY_FILE