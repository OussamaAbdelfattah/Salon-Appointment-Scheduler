#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --no-align --tuples-only -c"
#echo $($PSQL "TRUNCATE services, appointments, customers")

echo -e "\n~~~~~ MY SALON ~~~~~\n"

echo -e "\nWelcome to My Salon, how can I help you?\n"
echo "$($PSQL "SELECT * FROM services order by service_id")" | sed 's/|/) /g'
read SERVICE_ID_SELECTED 
SERVICE_ID_RESULT=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")
while [[ -z $SERVICE_ID_RESULT ]]
do
  echo -e "\nI could not find that service. What would you like today?"
  echo "$($PSQL "SELECT * FROM services order by service_id")" | sed 's/|/) /g'
  read SERVICE_ID_SELECTED
  SERVICE_ID_RESULT=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")
done
echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE
# get customer
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
# if not found
if [[ -z $CUSTOMER_ID ]]
then
  echo -e "\nI don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME
  # insert major
  INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
  if [[ $INSERT_CUSTOMER_RESULT != "INSERT 0 1" ]]
  then
    echo erreur
  fi
  # get new major_id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE name='$CUSTOMER_NAME'")
fi
# get service_name
SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
read SERVICE_TIME
# insert into appointements
INSERT_APPOINTMENTS_RESULT=$($PSQL "INSERT INTO appointments (time, customer_id, service_id) VALUES('$SERVICE_TIME', $CUSTOMER_ID, $SERVICE_ID_SELECTED)")
if [[ $INSERT_APPOINTMENTS_RESULT == "INSERT 0 1" ]]
then
  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
fi
