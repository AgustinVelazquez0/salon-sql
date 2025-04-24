# Mostrar los servicios disponibles
echo -e "\nEstas son los servicios disponibles:"
PSQL="psql --username=postgres --dbname=salon -t -c"

# Mostrar lista de servicios
$PSQL "SELECT service_id, name FROM services" | while read SERVICE_ID SERVICE_NAME
do
  echo "$SERVICE_ID) $SERVICE_NAME"
done

# Solicitar que el usuario elija un servicio
echo -e "\nPor favor, elija el ID del servicio:"
read SERVICE_ID_SELECTED

# Verificar si el servicio existe
SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

if [[ -z $SERVICE_NAME ]]
then
  echo "El servicio no existe."
  exit
fi

# Solicitar el número de teléfono del cliente
echo -e "\nPor favor, ingrese su número de teléfono:"
read CUSTOMER_PHONE

# Verificar si el cliente ya está en la base de datos
CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

if [[ -z $CUSTOMER_NAME ]]
then
  # Si no existe, pedir nombre e insertarlo
  echo -e "\nEste teléfono no está registrado. ¿Cómo te llamas?"
  read CUSTOMER_NAME
  INSERT_CUSTOMER=$($PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
  echo "Cliente registrado con éxito."
fi

# Pedir la hora para la cita
echo -e "\n¿A qué hora le gustaría agendar su cita?"
read SERVICE_TIME

# Obtener el customer_id
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

# Insertar la cita en la tabla appointments
INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

# Confirmación de la cita
echo -e "\nTe he agendado para un/a $SERVICE_NAME a las $SERVICE_TIME, $CUSTOMER_NAME."
