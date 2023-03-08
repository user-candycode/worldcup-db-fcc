#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo $($PSQL "TRUNCATE TABLE games, teams RESTART IDENTITY")
echo "TABLE CLEARED"
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPENENT_GOALS
do
if [[ $WINNER != 'winner' ]]
then
  #get team_id from teams
  TEAM_ID_W="$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")"
  TEAM_ID_O="$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")"
  #If not found
  if [[ -z $TEAM_ID_O ]]
  then
    #INSERT TEAM
    INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
    if [[ $INSERT_TEAM_RESULT == "INSERT 0 1" ]]
    then
        echo 'inserted:' $OPPONENT
    fi
    #GET NEW INSERTED opponent as team id
    TEAM_ID_O="$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")"
  fi

  if [[ -z $TEAM_ID_W ]]
  then
    #INSERT REST OF THE OUTLIERS in team
    INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
    if [[ $INSERT_TEAM_RESULT == "INSERT 0 1" ]]
    then
        echo 'inserted:' $WINNER
    fi
    #GET NEW INSERTED winner outliers as team id
    TEAM_ID_W="$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")"
  fi

  #push rest of the data into games table
  INSERT_GAMES_RESULT="$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $TEAM_ID_W, $TEAM_ID_O, $WINNER_GOALS, $OPPENENT_GOALS)")"
  if [[ $INSERT_GAMES_RESULT == "INSERT 0 1" ]]
  then
      echo Inserted into games, $YEAR "$ROUND" $TEAM_ID_W $TEAM_ID_O $WINNER_GOALS $OPPENENT_GOALS 
  fi
fi

done
