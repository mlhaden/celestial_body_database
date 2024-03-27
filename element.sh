#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

CHECK_ARGUMENT() {
  if [[ -z $1 ]]
  then
    echo Please provide an element as an argument.
  else
    PRINT_ELEMENT $1
  fi
}

PRINT_ELEMENT() {
  INPUT=$1
  if [[ $INPUT =~ ^[0-9]+$ ]]
  then
    ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number = $INPUT")
  else
    ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE symbol = '$INPUT' OR name = '$INPUT'")
  fi
  
  if [[ -z $ATOMIC_NUMBER ]]
  then
    echo I could not find that element in the database.
  else
    NAME=$(echo $($PSQL "SELECT name FROM elements WHERE atomic_number = $ATOMIC_NUMBER") | sed 's/ //g')
    SYMBOL=$(echo $($PSQL "SELECT symbol FROM elements WHERE atomic_number = $ATOMIC_NUMBER") | sed 's/ //g')
    TYPE=$(echo $($PSQL "SELECT type FROM types INNER JOIN properties USING(type_id) WHERE atomic_number = $ATOMIC_NUMBER") | sed 's/ //g')
    ATOMIC_MASS=$(echo $($PSQL "SELECT atomic_mass FROM properties WHERE atomic_number = $ATOMIC_NUMBER") | sed 's/ //g')
    MELTING_POINT=$(echo $($PSQL "SELECT melting_point_celsius FROM properties WHERE atomic_number = $ATOMIC_NUMBER") | sed 's/ //g')
    BOILING_POINT=$(echo $($PSQL "SELECT boiling_point_celsius FROM properties WHERE atomic_number = $ATOMIC_NUMBER") | sed 's/ //g')
  
    echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
  fi
}

CHECK_ARGUMENT $1
