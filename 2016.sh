#!/bin/bash

# Ensure the repository is up-to-date


input_year=2016

# Set variables
start_date="$input_year-07-01"
end_date="$input_year-09-31"
total_commits=45       # Total commits to generate (multiple per day allowed)

# Generate Philippines public holidays
generate_holidays() {
    local year=$1
holidays=(
    "$year-01-01"   # New Year
    "$year-01-02"

    "$year-01-05"   # Sunday
    "$year-01-12"
    "$year-01-19"

    "$year-01-24"   # Unirea Principatelor

    "$year-01-26"

    "$year-02-02"
    "$year-02-09"
    "$year-02-16"
    "$year-02-23"

    "$year-03-02"
    "$year-03-09"
    "$year-03-16"
    "$year-03-23"
    "$year-03-30"

    "$year-04-06"
    "$year-04-13"

    "$year-04-20"   # Easter Sunday
    "$year-04-21"   # Easter Monday

    "$year-04-27"

    "$year-05-01"   # Labour Day
    "$year-05-04"
    "$year-05-11"
    "$year-05-18"
    "$year-05-25"

    "$year-06-01"
    "$year-06-08"   # Pentecost
    "$year-06-09"   # Pentecost Monday
    "$year-06-15"
    "$year-06-22"
    "$year-06-29"

    "$year-07-06"
    "$year-07-13"
    "$year-07-20"
    "$year-07-27"

    "$year-08-03"
    "$year-08-10"

    "$year-08-15"   # Assumption

    "$year-08-17"
    "$year-08-24"
    "$year-08-31"

    "$year-09-07"
    "$year-09-14"
    "$year-09-21"
    "$year-09-28"

    "$year-10-05"
    "$year-10-12"
    "$year-10-19"
    "$year-10-26"

    "$year-11-02"
    "$year-11-09"
    "$year-11-16"
    "$year-11-23"

    "$year-11-30"   # St Andrew

    "$year-12-01"   # National Day

    "$year-12-07"
    "$year-12-14"
    "$year-12-21"

    "$year-12-25"   # Christmas
    "$year-12-26"

    "$year-12-28"
)

    # Movable holidays (approximations)
    # Maundy Thursday & Good Friday (Easter-based)
    easter_sunday=$(date -d "$year-03-21 + $(expr $(date -d "$year-03-21" +%j) % 7) days + 50 days" +%Y-%m-%d 2>/dev/null || echo "$year-04-04")  # Approx
    good_friday=$(date -d "$easter_sunday - 2 days" +%Y-%m-%d 2>/dev/null || echo "$year-04-02")
    maundy_thursday=$(date -d "$easter_sunday - 3 days" +%Y-%m-%d 2>/dev/null || echo "$year-04-01")

    holidays+=("$maundy_thursday" "$good_friday")
}

generate_holidays "$input_year"

# Generate weekdays (Monday - Friday) within date range excluding holidays
dates_weekdays=()
current_date="$start_date"

while [[ "$current_date" < "$end_date" ]] || [[ "$current_date" == "$end_date" ]]; do
    day_of_week=$(date -d "$current_date" +%u 2>/dev/null || echo $(date -j -f "%Y-%m-%d" "$current_date" +%u))

    # Skip weekends and holidays
    if [[ "$day_of_week" -lt 6 ]] && [[ ! " ${holidays[@]} " =~ " $current_date " ]]; then
        dates_weekdays+=("$current_date")
    fi

    current_date=$(date -I -d "$current_date + 1 day" 2>/dev/null || echo $(date -j -v+1d -f "%Y-%m-%d" "$current_date" "+%Y-%m-%d"))
done

total_days=${#dates_weekdays[@]}
echo "Number of valid weekdays: $total_days"

if [[ "$total_days" -eq 0 ]]; then
    echo "No valid weekdays available."
    exit 1
fi

# Make commits
for ((i=1; i<=total_commits; i++)); do
    # Pick a random day from valid weekdays
    day=${dates_weekdays[$RANDOM % total_days]}

    # Pick a random hour and minute (so multiple commits appear separately)
    hour=$(printf "%02d" $((RANDOM % 9 + 9)))   # 09:00 - 17:59
    minute=$(printf "%02d" $((RANDOM % 60)))
    second=$(printf "%02d" $((RANDOM % 60)))

    commit_date="$day $hour:$minute:$second"
    export GIT_COMMITTER_DATE="$commit_date"
    export GIT_AUTHOR_DATE="$commit_date"

    git commit --allow-empty -m "Modify files" --date "$commit_date"
done

git push origin main
echo "Multiple commits per day generated successfully (Poland holidays)."