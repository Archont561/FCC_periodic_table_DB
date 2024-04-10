#!/bin/bash
# gets specified element info based on tables in periodic_table db;

if [ -z "$1" ]; then
  echo "Please provide an element as an argument."
  exit 0
fi

if [[ "$1" =~ ^[0-9]+$ ]]; then
  QUERY="atomic_number=$1"
else
  QUERY="name='$1' OR symbol='$1'"
fi

PSQL="psql --username=postgres --dbname=periodic_table -t --no-align -c"
EL=$($PSQL "SELECT atomic_number, symbol, name FROM elements WHERE $QUERY")
if [[ -z "$EL" ]]; then
  echo "I could not find that element in the database."
  exit 0
fi 

# Extracting information from the element query
A=$(echo "$EL" | awk -F'|' '{print $1}')
SYMBOL=$(echo "$EL" | awk -F'|' '{print $2}')
NAME=$(echo "$EL" | awk -F'|' '{print $3}')

# Fetching additional information from the properties table
PROPERTIES=$($PSQL "SELECT type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM properties INNER JOIN types USING (type_id) WHERE atomic_number=$A;")

# Extracting information from the properties query
TYPE=$(echo "$PROPERTIES" | awk -F'|' '{print $1}')
MASS=$(echo "$PROPERTIES" | awk -F'|' '{print $2}')
MELTING_POINT=$(echo "$PROPERTIES" | awk -F'|' '{print $3}')
BOILING_POINT=$(echo "$PROPERTIES" | awk -F'|' '{print $4}')

echo "The element with atomic number $A is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
