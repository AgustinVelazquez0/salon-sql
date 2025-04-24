#!/bin/bash

PSQL="psql --username=postgres --dbname=salon -t -c"

MAIN_MENU() {
  echo -e "\nEstas son los servicios disponibles:"
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  echo -e "\nPor favor, elija el ID del servicio:"
  read SERVICE_ID_SELECTED
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  SERVICE_NAME=$(echo $SERVICE_NAME | xargs)  # <-- trim espacios

  if [[ -z $SERVICE_NAME ]]
  then
    echo -e "\nServicio no válido. Intente de nuevo."
    MAIN_MENU
  else
    PEDIR_DATOS_CLIENTE
  fi
}

PEDIR_DATOS_CLIENTE() {
  echo -e "\nPor favor, ingrese su número de teléfono:"
  read CUSTOMER_PHONE

  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  CUSTOMER_NAME=$(echo $CUSTOMER_NAME | xargs)  # <-- trim espacios

  if [[ -z $CUSTOMER_NAME ]]
  then
    echo -e "\nEste teléfono no está registrado. ¿Cómo te llamás?"
    read CUSTOMER_NAME
    INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
  fi

  echo -e "\n¿A qué hora querés la cita?"
  read SERVICE_TIME

  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
}

MAIN_MENU
