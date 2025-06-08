#!/bin/bash
# Simple wrapper to run tests with clean output

# Run tests and filter out verbose benchmark output
python3 launch_factorio.py --run-tests --timeout 60 2>&1 | grep -v "Running update" | grep -v "out 1 Press"