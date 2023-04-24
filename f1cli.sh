#!/bin/bash

API_BASE_URL="http://ergast.com/api/f1/"

while [[ $# -gt 0 ]]
do
    key="$1"

    case $key in
        -n|--news)
        NEWS=true
        shift
        ;;
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
        DRIVER="$2"
        shift
        shift
        ;;
        -t|--team)
        TEAM="$2"
        shift
        shift
        ;;
        -l|--language)
        LANGUAGE="$2"
        shift
        shift
        ;;
        -u|--units)
        UNITS="$2"
        shift
        shift
        ;;
        *)
        shift
        ;;
    esac
done

# Construire l'URL de l'API en fonction des options de langue et d'unité
URL="${API_BASE_URL}"

# Si l'utilisateur a demandé les dernières nouvelles, afficher les dernières nouvelles et rumeurs.
if [ "$NEWS" = true ]; then
    ENDPOINT="news.json"
    RESPONSE=$(curl -s "$URL$ENDPOINT")
    echo "Dernières nouvelles et rumeurs de la Formule 1 :"
    echo "+------------------------------------------------+---------------------+-------------------------------+"
    echo "|                      Titre                     |        Date         |              URL              |"
    echo "+------------------------------------------------+---------------------+-------------------------------+"
    echo "$RESPONSE" | jq -r '.MRData.RaceTable.Races[] | "|\(.raceName) | \(.date) | \(.url)|"' | awk -F "|" '{printf("| %-46s | %-19s | %-30s|\n", $2,$4,$6)}'
    echo "+------------------------------------------------+---------------------+-------------------------------+"
fi

# Si l'utilisateur a demandé les résultats des dernières courses, afficher les résultats des dernières courses
if [ "$RESULTS" = true ]; then
    ENDPOINT="current/last/results.json"
    RESPONSE=$(curl -s "$URL$ENDPOINT")
    echo "Résultats des dernières courses de la Formule 1 :"
    echo "+------------------------------------+----------------------+---------------+----------------------+-----------------------+"
    echo "|             Pilote                 |       Constructeur   | Temps total   | Tour le plus rapide  |           Course      |"
    echo "+------------------------------------+----------------------+---------------+----------------------+-----------------------+"
    echo "$RESPONSE" | jq -r '.MRData.RaceTable.Races[0].Results[] | "\(.Driver.givenName) \(.Driver.familyName) | \(.Constructor.name) | \(.Time.time) | \(.FastestLap.Time.time) | \(.raceName)"' | awk -F "|" '{printf("| %-35s | %-20s | %-13s | %-20s | %-21s|\n", $1,$2,$3,$4,$5)}'
    echo "+------------------------------------+----------------------+---------------+----------------------+-----------------------+"
fi


# Si l'utilisateur a demandé les classements des pilotes et des constructeurs, afficher les classements des pilotes et des constructeurs
if [ "$STANDINGS" = true ]; then
    ENDPOINT="current/driverStandings.json"
    RESPONSE=$(curl -s "$URL$ENDPOINT")
    echo "Classement des pilotes :"
    echo "+-------+------------------------+------------------------+----------------------------+--------+"
    echo "| Place |          Pilote        |        Constructeur     |           Nationalité       | Points |"
    echo "+-------+------------------------+------------------------+----------------------------+--------+"
    echo "$RESPONSE" | jq -r '.MRData.StandingsTable.StandingsLists[0].DriverStandings[] | "\(.position) | \(.Driver.givenName) \(.Driver.familyName) | \(.Constructors[0].name) | \(.Driver.nationality) | \(.points)"' | awk -F "|" '{printf("| %-5s | %-23s | %-23s | %-27s | %-6s |\n", $1,$2,$3,$4,$5)}'
    echo "+-------+------------------------+------------------------+----------------------------+--------+"
    echo ""
    ENDPOINT="current/constructorStandings.json"
    RESPONSE=$(curl -s "$URL$ENDPOINT")
    echo "Classement des constructeurs :"
    echo "+-------+------------------------+--------+"
    echo "| Place |      Constructeur      | Points |"
    echo "+-------+------------------------+--------+"
    echo "$RESPONSE" | jq -r '.MRData.StandingsTable.StandingsLists[0].ConstructorStandings[] | "\(.position) | \(.Constructor.name) | \(.points)"' | awk -F "|" '{printf("| %-5s | %-23s | %-6s |\n", $1,$2,$3)}'
    echo "+-------+------------------------+--------+"
fi

# Si l'utilisateur a demandé les statistiques pour un pilote spécifique, afficher les statistiques pour ce pilote
if [ -n "$DRIVER" ]; then
    ENDPOINT="current/drivers/${DRIVER}/driverStandings.json"
    RESPONSE=$(curl -s "$URL$ENDPOINT")
    echo "Statistiques pour le pilote $DRIVER :"
    echo "+------------------+--------+---------+--------+---------+"
    echo "|      Saison      | Points | Victoires | Podiums |  Poles  |"
    echo "+------------------+--------+---------+--------+---------+"
    echo "$RESPONSE" | jq -r '.MRData.StandingsTable.StandingsLists[0] | "\(.season)"' | '.MRData.StandingsTable.StandingsLists[0].DriverStandings[] | "\(.points) | \(.wins) | \(.podiums) | \(.poles)"' | awk -F "|" '{printf("| %-16s | %-6s | %-8s | %-7s | %-7s |\n", $1,$2,$3,$4,$5)}'
    echo "+------------------+--------+---------+--------+---------+"
fi


# Si l'utilisateur a demandé les statistiques pour une équipe spécifique, afficher les statistiques pour cette équipe
if [ -n "$TEAM" ]; then
    ENDPOINT="constructors/${TEAM}/constructorStandings.json"
    RESPONSE=$(curl -s "$URL$ENDPOINT")
    echo "Statistiques pour l'équipe $TEAM :"
    echo "---------------------------------"
    VICTOIRES=$(echo $RESPONSE | jq -r '.MRData.StandingsTable.StandingsLists[0].ConstructorStandings[0].wins')
    PODIUMS=$(echo $RESPONSE | jq -r '.MRData.StandingsTable.StandingsLists[0].ConstructorStandings[0].podiums')
    echo "Nombre de victoires : $VICTOIRES"
    echo "Nombre de podiums : $PODIUMS"
    echo "---------------------------------"
fi

# Si l'utilisateur n'a spécifié aucune option, afficher une aide
if [ "$HELP" = true ]; then
    echo "F1CLI est un outil en ligne de commande qui vous permet de suivre les dernières nouvelles, résultats et statistiques de la Formule 1."
    echo "Utilisation : ./f1cli.sh [OPTIONS]"
    echo "Options :"
    echo "  -n, --news                      Afficher les dernières nouvelles et rumeurs."
    echo "  -r, --results                   Afficher les résultats des dernières courses."
    echo "  -s, --standings                 Afficher les classements des pilotes et des constructeurs."
    echo "  -d, --driver <nom>              Afficher les statistiques pour un pilote spécifique."
    echo "  -t, --team <nom>                Afficher les statistiques pour une équipe spécifique."
fi

exit 0
