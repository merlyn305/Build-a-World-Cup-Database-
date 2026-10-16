#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

team_rows=()
game_rows=()

while IFS=, read -r year round winner opponent winner_goals opponent_goals
do
  [[ $year == "year" ]] && continue
  team_rows+=("('$winner')" "('$opponent')")
  game_rows+=("($year, '$round', '$winner', '$opponent', $winner_goals, $opponent_goals)")
done < games.csv

team_values=$(IFS=,; printf '%s' "${team_rows[*]}")
game_values=$(IFS=,; printf '%s' "${game_rows[*]}")

SQL="INSERT INTO teams (name) VALUES $team_values ON CONFLICT (name) DO NOTHING;
INSERT INTO games (year, round, winner_id, opponent_id, winner_goals, opponent_goals)
SELECT game.year, game.round, winner.team_id, opponent.team_id, game.winner_goals, game.opponent_goals
FROM (VALUES $game_values) AS game(year, round, winner, opponent, winner_goals, opponent_goals)
JOIN teams AS winner ON winner.name = game.winner
JOIN teams AS opponent ON opponent.name = game.opponent;"

$PSQL "$SQL"
