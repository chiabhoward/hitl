#!/bin/bash

MAX_TOTAL_RUNS=500         # Max total simulations before stopping
RESTART_EVERY_N=10         # Restart simulator every N simulations
SIMULATOR_CMD="$HOME/CarlaUE4.sh"

START_RUN=0
END_RUN=499

TOTAL_RUNS=$START_RUN
RUNS_SINCE_RESTART=0

INPUT_SCRIPT="$HOME/hitl/${1}.py"

# Function to start simulator in background
start_simulator() {
    echo "Starting simulator..."
    nohup $SIMULATOR_CMD > /dev/null 2>&1 &
    sleep 10
}


# Function to stop simulator
stop_simulator() {
    echo "Stopping simulator..."
    pkill -f "CarlaUE4"
    sleep 5
}

# Start simulator
start_simulator

# Main control loop
while [ "$TOTAL_RUNS" -le "$END_RUN" ]; do
    echo "=== Running simulation $TOTAL_RUNS ==="

    while ! pgrep -f "CarlaUE4" > /dev/null; do
        echo "Simulator not running. Restarting..."
        start_simulator
        sleep 5
    done


    ARGS=(
        --input_scenario "$1"
        --seed "$TOTAL_RUNS"
    )
    [ "$2" != "good" ] && ARGS+=(--bad_behavior)

    python3 "$INPUT_SCRIPT" "${ARGS[@]}"
    # Build and run the controller command
    

    TOTAL_RUNS=$((TOTAL_RUNS + 1))
    RUNS_SINCE_RESTART=$((RUNS_SINCE_RESTART + 1))

    echo "Completed $TOTAL_RUNS simulations."

    # if [ "$RUNS_SINCE_RESTART" -ge "$RESTART_EVERY_N" ]; then
    #     stop_simulator
    #     sleep 2
    #     start_simulator
    #     RUNS_SINCE_RESTART=0
    # fi
done

echo "Reached $MAX_TOTAL_RUNS simulations. Shutting down..."
stop_simulator
