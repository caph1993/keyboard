#!/bin/bash

# The command to run
# The config file and its backup

SCRIPT_DIR="$(dirname "$(realpath "$0")")"

cd "$SCRIPT_DIR"
COMMAND=""$SCRIPT_DIR/kanata_linux_x64" $@"
CONFIG_FILE="$SCRIPT_DIR/../kanata-config.kbd"
BACKUP_FILE="$SCRIPT_DIR/kanata-backup.kbd"
LOG_FILE="$SCRIPT_DIR/kanata-log.log"

A1=""$COMMAND" --cfg "$CONFIG_FILE""
A2="cp "$CONFIG_FILE" "$BACKUP_FILE""
# Assign the command to a variable
A='
(
echo "--------";
echo "Running: '$A1'";
echo "" > '$LOG_FILE';
eval '$A1' 2> >(tee '$LOG_FILE' >&2) & A1_PID=$!;
(sleep 1;
if ps -p $A1_PID > /dev/null;
then
eval '$A2';
echo "Updated backup with this working configuration";
notify-send -t 500 "OK!";
else
echo "Backup was not overwritten";
notify-send -t 5000 "$(cat '$LOG_FILE')";
fi
) & A2_PID=$!;
wait $A1_PID;
A1_EXIT_CODE=$?;
wait $A2_PID;
exit $A1_EXIT_CODE
)'
B1=""$COMMAND" --cfg "$BACKUP_FILE""
B="(echo \"BACKUP: '$B1'\"; eval '$B1')"

echo "$CONFIG_FILE" | entr -r sh -c "$A || $B"