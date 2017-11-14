#!/usr/bin/env bash
set -e

cd "$(dirname "$0")"

bundle check || bundle install

echo -n "Starting services... "
./frontend.rb&
FRONTEND_PID=$!
./logic.rb&
LOGIC_PID=$!
./config.rb&
CONFIG_PID=$!
echo "done"

function cleanup {
    echo -n "Shuttting down services... "
    kill $FRONTEND_PID $LOGIC_PID $CONFIG_PID
    echo "done"
}

trap cleanup EXIT

cd ..
bundle check || bundle install
./generate_html.rb -f -n -r ./test_service/test_participants.yml

open out/current.html || echo "could not open output"