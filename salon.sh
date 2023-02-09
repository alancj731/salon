#! /bin/bash
# PSQL='psql --username=freecodecamp --dbname=salon -c '
PSQL='psql -X --username=freecodecamp --dbname=salon --tuples-only -c '
# define the funtion to show main menu
MAIN_MENU() {
	echo "$SERVICES" | while read SERVICE_ID BAR NAME
	do
	echo -e "$SERVICE_ID) $NAME"
	done
	
}

# get services information
SERVICES=$($PSQL "SELECT * FROM services ORDER BY service_id;")
SHOW=true

while [ "$SHOW" = true ]
do
	# display main menu
	MAIN_MENU

	# ask input for serive id
	echo -e "\nPlease choose a service"
	# read user input
	read SERVICE_ID_SELECTED

	# check if it is a valid service id
	SERVICE_NAME=$($PSQL "SELECT name from services WHERE service_id=$SERVICE_ID_SELECTED;")
	
	# if service id doesn't exist, return to main menu
	if [[ -z $SERVICE_NAME ]]
	then
		# go back to MAIN_MENU
		continue
	else
		# break the next loop
		SHOW=false
	fi
	
	# ask input for phone number
	echo -e "\nPlease input your phone number"
	# read user phone number
	read CUSTOMER_PHONE

	EXISTING_CUSTOMER=true
	# check phone number to see if it is a existing customer
	CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE';")
	
	# if not already a customer
	if [[ -z $CUSTOMER_NAME ]]
	then
	  # set existing customer to false
		EXISTING_CUSTOMER=false
		# ask customer to enter name
		echo -e "\nPlease enter your name."
		# read customer's name
		read CUSTOMER_NAME
		# insert customer into table customers
		$PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME');" &>/dev/null
	fi
	# get customer id
	CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")

	# ask enter service time
	echo -e "\nPlease enter your service time"
	# read service time
	read SERVICE_TIME
	
	# insert information into appointments table
	$PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES('$CUSTOMER_ID', '$SERVICE_ID_SELECTED', '$SERVICE_TIME');" &>/dev/null
	# show summary
	echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."	
	
done
