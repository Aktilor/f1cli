#!/bin/bash

API_BASE_URL="http://ergast.com/api/f1/"
DISPLAY_DRIVERS=false
DISPLAY_TEAMS=false

while [[ $# -gt 0 ]]
do
    key="$1"

    case $key in
        -r|--results)
        RESULTS=true
        shift
        ;;
        -h|--help)
        HELP=true
        shift
        ;;
        -s|--standings)
        STANDINGS=true
        shift
        ;;
        -d|--driver)
        DISPLAY_DRIVERS=true
        DRIVER="$2"
        if [[ $DRIVER == -* ]]; then
            DRIVER=""
        else
            shift
        fi
        shift
        ;;
        -t|--team)
        DISPLAY_TEAMS=true
        TEAM="$2"
        if [[ $TEAM == -* ]]; then
            TEAM=""
        else
            shift
        fi
        shift
        ;;
        *)
        shift
        ;;
    esac
done

URL="${API_BASE_URL}"

if [ "$RESULTS" = true ]; then
    ENDPOINT="current/last/results.json"
    RESPONSE=$(curl -s "$URL$ENDPOINT")
    echo "Results of the latest Formula 1 race:"
    echo "+------------------------------------+----------------------+---------------+----------------------+-----------------------+"
    echo "|                Driver              |       Constructor    |   Total Time  |      Fastest lap     |       Avg Speed       |"
    echo "+------------------------------------+----------------------+---------------+----------------------+-----------------------+"
    echo "$RESPONSE" | jq -r '.MRData.RaceTable.Races[0].Results[] | "\(.Driver.givenName) \(.Driver.familyName) | \(.Constructor.name) | \(.Time.time) | \(.FastestLap.Time.time) | \(.FastestLap.AverageSpeed.speed) km/h"' | awk -F "|" '{printf("| %-35s | %-20s | %-13s | %-20s | %-21s|\n", $1,$2,$3,$4,$5)}'
    echo "+------------------------------------+----------------------+---------------+----------------------+-----------------------+"
fi

if [ "$STANDINGS" = true ]; then
    ENDPOINT="current/driverStandings.json"
    RESPONSE=$(curl -s "$URL$ENDPOINT")
    echo "Drivers' standings:"
    echo "+-------+------------------------+------------------------+----------------------------+--------+"
    echo "|  Rank |          Driver        |        Constructor     |          Nationality       | Points |"
    echo "+-------+------------------------+------------------------+----------------------------+--------+"
    echo "$RESPONSE" | jq -r '.MRData.StandingsTable.StandingsLists[0].DriverStandings[] | "\(.position) | \(.Driver.givenName) \(.Driver.familyName) | \(.Constructors[0].name) | \(.Driver.nationality) | \(.points)"' | awk -F "|" '{printf("| %-5s | %-23s | %-23s | %-27s | %-6s |\n", $1,$2,$3,$4,$5)}'
    echo "+-------+------------------------+------------------------+----------------------------+--------+"
    echo ""
    ENDPOINT="current/constructorStandings.json"
    RESPONSE=$(curl -s "$URL$ENDPOINT")
    echo "Constructors' standings:"
    echo "+-------+------------------------+--------+"
    echo "|  Rank |       Constructor      | Points |"
    echo "+-------+------------------------+--------+"
    echo "$RESPONSE" | jq -r '.MRData.StandingsTable.StandingsLists[0].ConstructorStandings[] | "\(.position) | \(.Constructor.name) | \(.points)"' | awk -F "|" '{printf("| %-5s | %-23s | %-6s |\n", $1,$2,$3)}'
    echo "+-------+------------------------+--------+"
fi

if [ -n "$DRIVER" ]; then
    ENDPOINT="current/drivers/${DRIVER}/driverStandings.json"
    RESPONSE=$(curl -s "$URL$ENDPOINT")
    echo "Statistics for the driver $DRIVER:"
    echo "+------------------------+--------+-----------+---------+----------+"
    echo "|          Driver        | Points |    Wins   |  Number | DriverId |"
    echo "+------------------------+--------+-----------+---------+----------+"
    echo "$RESPONSE" | jq -r '.MRData.StandingsTable.StandingsLists[0].DriverStandings[] | "\(.Driver.givenName) \(.Driver.familyName)|\(.points)|\(.wins)|\(.Driver.code) \(.Driver.permanentNumber)|\(.Driver.driverId)"' | awk -F "|" '{printf("| %-22s | %-6s | %-9s | %-7s | %-8s |\n", $1,$2,$3,$4,$5)}' 
    echo "+------------------------+--------+-----------+---------+----------+"
elif [ "$DISPLAY_DRIVERS" = true ]; then
    ENDPOINT="current/driverStandings.json"
    RESPONSE=$(curl -s "$URL$ENDPOINT")
    echo "List of drivers for the season:"
    echo "+------------------------+---------+-----------+---------+----------+"
    echo "|          Driver        | Points  |    Wins   |  Number | DriverId |"
    echo "+------------------------+---------+-----------+---------+----------+"
    echo "$RESPONSE" | jq -r '.MRData.StandingsTable.StandingsLists[0].DriverStandings[] | "\(.Driver.givenName) \(.Driver.familyName)|\(.points)|\(.wins)|\(.Driver.code) \(.Driver.permanentNumber)|\(.Driver.driverId)"' | awk -F "|" '{printf("| %-22s | %-7s | %-9s | %-7s | %-8s |\n", $1,$2,$3,$4,$5)}'
    echo "+------------------------+---------+-----------+---------+----------+"
fi

if [ -n "$TEAM" ]; then
    ENDPOINT="current/constructors/${TEAM}/constructorStandings.json"
    RESPONSE=$(curl -s "$URL$ENDPOINT")
    echo "Statistics for the team $TEAM:"
    echo "+------------------+--------+---------+"
    echo "|      Season      | Points |   Wins  |"
    echo "+------------------+--------+---------+"
    echo "$RESPONSE" | jq -r '.MRData.StandingsTable.StandingsLists[0] | "\(.season) | \(.ConstructorStandings[].points) | \(.ConstructorStandings[].wins) | \(.ConstructorStandings[].name)"' | awk -F "|" '{printf("| %-16s | %-6s | %-8s |\n", $1,$2,$3)}'
    echo "+------------------+--------+---------+"
elif [ "$DISPLAY_TEAMS" = true ]; then
    ENDPOINT="current/constructors.json"
    RESPONSE=$(curl -s "$URL$ENDPOINT")
    echo "List of constructors for the season:"
    echo "+------------------------+----------------+"
    echo "|       Constructor      | ConstructorId  |"
    echo "+------------------------+----------------+"
    echo "$RESPONSE" | jq -r '.MRData.ConstructorTable.Constructors[] | "\(.name) | \(.constructorId)"' | awk -F "|" '{printf("| %-22s | %-14s |\n", $1,$2)}'
    echo "+------------------------+----------------+"
fi

if [ "$HELP" = true ]; then
    echo "🏎 F1CLI is a command-line tool that allows you to follow the latest results and statistics of Formula 1."
    echo "Usage: ./f1cli.sh [OPTIONS]"
    echo "Options:"
    echo "  -r, --results                   Display the results of the latest races."
    echo "  -s, --standings                 Display the standings of drivers and constructors."
    echo "  -d, --driver <driver_id>        Display the statistics for a specific driver."
    echo "  -t, --team <constructor_id>     Display the statistics for a specific team."
    echo ""
    echo "Info: You can find the driver_id and constructor_id with -d and -t"
    echo ""
    echo "Examples:"
    echo "  ./f1cli.sh --driver leclerc"
    echo "  ./f1cli.sh --team ferrari"
fi

exit 0