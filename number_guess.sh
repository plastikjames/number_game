#!/bin/bash

PSQL="psql -XA --username=freecodecamp --dbname=number_guess --tuples-only -c "

# Set random number to guess
ANSWER=$((1 + $RANDOM % 1000))
echo $ANSWER

NUMBER_OF_GUESSES=1

echo -e "Enter your username:"
read USERNAME

#Get records from the DB
USERID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
#if no user in DB
if [[ -z $USERID ]]
then
  #add user and print message
    INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  BEST_GAME=999
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  # else print welcome back message
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE user_id='$USERID'")
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE user_id='$USERID'")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

echo "Guess the secret number between 1 and 1000:"
read USERINPUT

while [[ $USERINPUT != $ANSWER ]] 
do
  if ! [[ $USERINPUT =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  elif [[ $USERINPUT > $ANSWER ]]
  then
    echo "It's lower than that, guess again:"
  else
    echo "It's higher than that, guess again:" 
  fi
  let "NUMBER_OF_GUESSES+=1"
  read USERINPUT
done

#check if this game has lower amount of guesses than the current record
if [[ $BEST_GAME > $NUMBER_OF_GUESSES ]]
then
  BEST_GAME=$NUMBER_OF_GUESSES
fi

#Incrment the number of games played before updating the DB 
let "GAMES_PLAYED+=1"

UPDATE_DB_RESULT=$($PSQL "UPDATE users SET games_played=$GAMES_PLAYED, best_game=$BEST_GAME WHERE username='$USERNAME'")
echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $ANSWER. Nice job!"
