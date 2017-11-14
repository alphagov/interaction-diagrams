#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/.."

if [ -d out/ ]; then
    echo "output directory exists!"
    exit 1
fi

# https://unix.stackexchange.com/a/273416
if [ ! -p in ]; then
    mkfifo in
fi

# :( - it is difficult to manage two Gemfiles on travis
grep ^gem ./test_service/Gemfile >> Gemfile
# this ensures a Gemfile.lock exists
bundle install --no-deployment

echo -n "Starting services... "
./test_service/frontend.rb&
FRONTEND_PID=$!
./test_service/logic.rb&
LOGIC_PID=$!
./test_service/config.rb&
CONFIG_PID=$!
echo "done"
sudo bash -c "tail -f in | PATH=$PATH GEM_PATH=$GEM_PATH ./generate_html.rb -f -n -r ./test_service/test_participants.yml" &
APP_PID=$!

function cleanup {
    echo -n "Shuttting down services... "
    kill $FRONTEND_PID $LOGIC_PID $CONFIG_PID > /dev/null 2>&1
    sudo kill $APP_PID
    echo "done"
}

trap cleanup EXIT

echo "waiting for app to start" && sleep 5s

# we pretend to be a browser (see PcapToolsHttpMessageRowMapper::BROWSER_USER_AGENT_PATTERN)
curl -H 'User-Agent: Mozilla' http://127.0.0.1:8000/index

echo "waiting for logs to write" && sleep 5s

# echo does not send a newline (thanks shellcheck)
printf "exit\n" > in

echo "waiting for app to write data and exit" && sleep 5s

LATEST="$(ls -1t out/ | grep -v html | head -n1)"
# wait for capture script to exit
COUNT=0
while [ $COUNT -lt 10 ]; do
    if [ -f "out/$LATEST/diagram.html" ]; then
        break
    fi
    COUNT=$[$COUNT+1]
    sleep 1
done
echo "waited $COUNT seconds for file to exist"

colordiff -urN .travis/expected_output <(cat "out/$LATEST/diagram.html" | perl -0pe 's/.*<div class="diagram">\s+(.*)<\/div>.*/$1/gms')

echo "SUCCESS!"