#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

declare -A inserted_teams
sql="BEGIN;"

while IFS=, read -r year round winner opponent winner_goals opponent_goals
do
  [[ -z "$year" ]] && continue

  for team in "$winner" "$opponent"
  do
    if [[ -z "${inserted_teams[$team]}" ]]
    then
      sql+=" INSERT INTO teams(name) VALUES('$team') ON CONFLICT (name) DO NOTHING;"
      inserted_teams[$team]=1
    fi
  done

  sql+=" INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($year, '$round', (SELECT team_id FROM teams WHERE name = '$winner'), (SELECT team_id FROM teams WHERE name = '$opponent'), $winner_goals, $opponent_goals);"
done < <(tail -n +2 games.csv)

sql+=" COMMIT;"
echo "$($PSQL "$sql")"
