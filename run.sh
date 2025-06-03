#!/bin/bash

MAX_TOTAL_RUNS=500         # Max total simulations before stopping
RESTART_EVERY_N=10         # Restart simulator every N simulations
SIMULATOR_CMD="$HOME/CarlaUE4.sh"

START_RUN=0
END_RUN=499

TOTAL_RUNS=$START_RUN
RUNS_SINCE_RESTART=0


INPUT_FILE="$HOME/hitl/scenario2.scenic"
OUTPUT_DIR="$HOME/hitl/dataset/scenario2/bad"

# Function to start simulator in background
start_simulator() {
    echo "Starting simulator..."
    $SIMULATOR_CMD &
    SIM_PID=$!
    echo "Simulator PID: $SIM_PID"
    sleep 10
}

# Function to stop simulator
stop_simulator() {
    echo "Stopping simulator (PID $SIM_PID)..."
    kill $SIM_PID 2>/dev/null
    wait $SIM_PID 2>/dev/null
}

# Start simulator
start_simulator

# Main control loop
while [ "$TOTAL_RUNS" -le "$END_RUN" ]; do
    OUTPUT_FILENAME="output_${TOTAL_RUNS}.csv"
    echo "=== Running simulation $TOTAL_RUNS ==="
    echo "Saving results to: $OUTPUT_FILENAME"

    # Build and run the controller command
    python3 example.py \
        --input_filename "$INPUT_FILE" \
        --output_directory "$OUTPUT_DIR" \
        --output_filename "$OUTPUT_FILENAME" \
        --seed "$TOTAL_RUNS"

    TOTAL_RUNS=$((TOTAL_RUNS + 1))
    RUNS_SINCE_RESTART=$((RUNS_SINCE_RESTART + 1))

    echo "Completed $TOTAL_RUNS simulations."

    if [ "$RUNS_SINCE_RESTART" -ge "$RESTART_EVERY_N" ]; then
        stop_simulator
        sleep 2
        start_simulator
        RUNS_SINCE_RESTART=0
    fi
done

echo "Reached $MAX_TOTAL_RUNS simulations. Shutting down..."
stop_simulator
