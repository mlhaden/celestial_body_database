#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

GET_USER() {
  echo -e "\nEnter your username:"
  read USERNAME

  PLAYER_ID=$($PSQL "SELECT player_id FROM players WHERE username = '$USERNAME'")
  if [[ -z $PLAYER_ID ]]
  then
    INSERT_RESULT=$($PSQL "INSERT INTO players(username) VALUES('$USERNAME')")
    PLAYER_ID=$($PSQL "SELECT player_id FROM players WHERE username = '$USERNAME'")
    echo Welcome, $USERNAME! It looks like this is your first time here.
  else
    GAMES_PLAYED=$($PSQL "SELECT games_played FROM players WHERE player_id = $PLAYER_ID")
    BEST_GAME=$($PSQL "SELECT best_game FROM players WHERE player_id = $PLAYER_ID")
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  fi

  GAME $PLAYER_ID
}

GAME() {
  SECRET_NUMBER=$((1 + $RANDOM % 1000))
  GAME_WON='false'
  NUMBER_OF_GUESSES=0
  PLAYER_ID=$1
  ADD_GAME=$($PSQL "UPDATE players SET games_played = (games_played + 1) WHERE player_id = $PLAYER_ID")
  BEST_GAME=$($PSQL "SELECT best_game FROM players WHERE player_id = $PLAYER_ID")
  echo -e "\nGuess the secret number between 1 and 1000:"

  while [[ $GAME_WON == 'false' ]]
  do
    read GUESS
    NUMBER_OF_GUESSES=$(($NUMBER_OF_GUESSES + 1))
    if [[ ! $GUESS =~ ^[0-9]+$ ]]
    then
      echo That is not an integer, guess again:
    elif [[ $GUESS > $SECRET_NUMBER ]]
    then
      echo "It's lower than that, guess again:"
    elif [[ $GUESS < $SECRET_NUMBER ]]
    then
      echo "It's higher than that, guess again:"
    elif [[ $GUESS == $SECRET_NUMBER ]]
    then
      if [[ -z $BEST_GAME || $BEST_GAME > $NUMBER_OF_GUESSES ]]
      then
        CHANGE_BEST=$($PSQL "UPDATE players SET best_game = $NUMBER_OF_GUESSES WHERE player_id = $PLAYER_ID")
      fi
      echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
      GAME_WON='true'
    else
      GAME_WON='true'
      echo ERROR
    fi
  done
}

GET_USER
