#!/bin/bash

# Configuration
DB_NAME="your_database_name"
DB_USER="your_username"
DB_PASSWORD="your_password"
ITERATIONS=1000

# Function to run benchmark
run_benchmark() {
  local query="$1"
  local result_file="$2"

  for ((i=1; i<=$ITERATIONS; i++))
  do
    # Execute the query and capture the execution time
    start_time="$(date +%s.%N)"
    psql -d $DB_NAME -U $DB_USER -c "$query" >/dev/null
    end_time="$(date +%s.%N)"

    # Calculate the execution time in milliseconds
    execution_time=$(echo "scale=3; ($end_time - $start_time) * 1000" | bc)

    # Append the result to the result file
    echo "$i,$execution_time" >> $result_file
  done
}

# Clear previous result files
rm -f without_pg_stat_monitor.csv
rm -f with_pg_stat_monitor.csv

# Query to benchmark
query="SELECT COUNT(*) FROM your_table"

# Benchmark without pg_stat_monitor
echo "Running benchmark without pg_stat_monitor..."
for ((i=1; i<=$ITERATIONS; i++))
do
  run_benchmark "$query" "without_pg_stat_monitor.csv"
done

# Enable pg_stat_monitor
psql -d $DB_NAME -U $DB_USER -c "LOAD 'pg_stat_monitor';"

# Benchmark with pg_stat_monitor
echo "Running benchmark with pg_stat_monitor..."
for ((i=1; i<=$ITERATIONS; i++))
do
  run_benchmark "$query" "with_pg_stat_monitor.csv"
done

# Disable pg_stat_monitor
psql -d $DB_NAME -U $DB_USER -c "UNLOAD 'pg_stat_monitor';"

echo "Benchmark complete."

