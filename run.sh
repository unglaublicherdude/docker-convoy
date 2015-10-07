#!/bin/bash
set -x -e

[ -n "$DATA_SIZE_MB" ]
[ -n "$METADATA_SIZE_MB" ]

clean() {
	rm -f $PID_FILE
	losetup -d ${LOOP_DATA}
	losetup -d ${LOOP_METADATA}
}

# START IN BACKGROUND
start() {
    echo "Starting : $bin $ARGS"
    $bin $ARGS &
    set_pid $!
    echo "Started with pid $(get_pid)"
}

# STOP, QUICK SAVE AND QUIT
stop() {
	set +e
    echo "Stopping $(get_pid)"
    kill -TERM $(get_pid)
    is_running && sleep 5 && kill -9 $(get_pid)
    echo "$(get_pid) stopped"

    save='cp ./shared/date.txt ./data/backup.txt'
    echo "Saving : $save"
    $save && echo "Saved"

    clean
    kill -9 $$
}

# RESTART DAEMON
daemon() {
    while true
    do
        is_running || start
        wait $(get_pid) || true
        sleep 1
    done
}

# PID
is_running() {
    pid=$(get_pid) &&
    ps $pid >&2 > /dev/null
}

get_pid() {
    cat $PID_FILE 2> /dev/null
}

set_pid() {
    echo $1 > $PID_FILE
}

# SIGNAL TRAPING
trap stop SIGHUP SIGINT SIGTERM
#EXIT SIGHUP SIGINT SIGTERM SIGUSR1 SIGUSR2 SIGQUIT

create_loop () {
    sudo mknod -m660 /dev/loop$1 b 7 8 &&
    sudo chown root.disk /dev/loop$1 &&
    sudo chmod 666 /dev/loop$1
}

for loop in {0..7}
do
    create_loop $loop || true
done

[ -f "$DATA" ] || dd if=/dev/zero of="${DATA}" count="${DATA_SIZE_MB}" bs=1M
[ -f "$METADATA" ] || dd if=/dev/zero of="${METADATA}" count="${METADATA_SIZE_MB}" bs=1M

LOOP_DATA=$(losetup -f)
losetup ${LOOP_DATA} "${DATA}"
LOOP_METADATA=$(losetup -f)
losetup ${LOOP_METADATA} "${METADATA}"

mkdir -p /etc/docker/plugins/
echo "unix:///var/run/convoy/convoy.sock" > /etc/docker/plugins/convoy.spec

ARGS="daemon --drivers devicemapper --driver-opts dm.datadev=${LOOP_DATA} --driver-opts dm.metadatadev=${LOOP_METADATA}"
PID_FILE='./pid'
bin='convoy'

daemon &
wait


