#!/bin/sh -e

sed -e '1,/^exit$/d' "$0" | tar xzf - && ./init_server.sh "$1"

exit
