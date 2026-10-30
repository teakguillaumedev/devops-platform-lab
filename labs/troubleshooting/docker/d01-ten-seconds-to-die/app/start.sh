#!/bin/sh
echo "start.sh: preparing environment"
export WORKER_MODE=production
python /app/worker.py
echo "start.sh: worker exited with code $?"
