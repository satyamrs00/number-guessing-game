#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

GAME(){
  NUMBER=$(( $RANDOM % 1000 + 1 ))

  echo -e "\nEnter your username:"
  read USERNAME

  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")

  if [[ $USER_ID ]]
  then
    GAMES_PLAYED=$($PSQL "SELECT games_played FROM details WHERE user_id=$USER_ID")
    BEST_GAME=$($PSQL "SELECT best_game FROM details WHERE user_id=$USER_ID")
    
    echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  else 
    echo "Welcome, $USERNAME! It looks like this is your first time here."
    RESULT=$($PSQL "INSERT INTO users (username) VALUES ('$USERNAME')")
    USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
    RESULT=$($PSQL "INSERT INTO details (user_id, games_played) VALUES ($USER_ID, 0)")
    GAMES_PLAYED=$($PSQL "SELECT games_played FROM details WHERE user_id=$USER_ID")
  fi

  echo -e "\nGuess the secret number between 1 and 1000:"
  read USER_NUMBER
  TRIES=1

  while (( $USER_NUMBER != $NUMBER ))
  do
    TRIES=$(( $TRIES+1 ))
    if [[ $USER_NUMBER =~ ^[0-9]+$ ]]
    then
      if (( $USER_NUMBER > $NUMBER ))
      then
        echo "It's lower than that, guess again:"
        read USER_NUMBER
      else 
        echo "It's higher than that, guess again:"
        read USER_NUMBER
      fi
    else
      echo "That is not an integer, guess again:"
      read USER_NUMBER
    fi
  done

  echo -e "\nYou guessed it in $TRIES tries. The secret number was $NUMBER. Nice job!"

  if [[ $GAMES_PLAYED -eq 0 ]]
  then
    RESULT=$($PSQL "UPDATE details SET best_game=$TRIES WHERE user_id=$USER_ID")
  else
    if [[ $TRIES -lt $BEST_GAME ]]
    then
      RESULT=$($PSQL "UPDATE details SET best_game=$TRIES WHERE user_id=$USER_ID")
    fi
  fi
  
  RESULT=$($PSQL "UPDATE details SET games_played=$(( $GAMES_PLAYED + 1 )) WHERE user_id=$USER_ID")
}

GAME