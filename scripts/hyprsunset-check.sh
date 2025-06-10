#!/usr/bin/env bash

# Kill current hyprsunset session
pkill -x hyprsunset 2>/dev/null

# Get current time
current_hour=$(date +%H)
current_minute=$(date +%M)

# Convert to decimal hours for more precision
current_time=$(echo "scale=2; $current_hour + $current_minute/60" | bc)

# Function to calculate temperature based on time
calculate_temperature() {
    local time=$1
    local temp

    # Temperature curve:
    # 7:00-17:00: 6500K (daylight)
    # 17:00-19:00: gradual transition 6500K -> 4000K
    # 19:00-23:00: gradual transition 4000K -> 3000K
    # 23:00-07:00: 3000K (warm night)

    if (($(echo "$time >= 7 && $time < 17" | bc -l))); then
        # Daylight hours - no filter
        temp=6500
    elif (($(echo "$time >= 17 && $time < 19" | bc -l))); then
        # Evening transition (17:00-19:00): 6500K -> 4000K
        progress=$(echo "scale=2; ($time - 17) / 2" | bc)
        temp=$(echo "scale=0; 6500 - (2500 * $progress)" | bc)
    elif (($(echo "$time >= 19 && $time < 23" | bc -l))); then
        # Night transition (19:00-23:00): 4000K -> 3000K
        progress=$(echo "scale=2; ($time - 19) / 4" | bc)
        temp=$(echo "scale=0; 4000 - (1000 * $progress)" | bc)
    else
        # Deep night (23:00-07:00): 3000K
        temp=3000
    fi

    echo $temp
}

# Calculate target temperature
target_temp=$(calculate_temperature $current_time)

# Only apply filter if temperature is below daylight
if [ "$target_temp" -lt 6500 ]; then
    echo "Setting hyprsunset to ${target_temp}K (time: ${current_hour}:$(printf "%02d" $current_minute))"
    hyprsunset -t $target_temp
else
    echo "Daylight hours - no filter applied (time: ${current_hour}:$(printf "%02d" $current_minute))"
fi
