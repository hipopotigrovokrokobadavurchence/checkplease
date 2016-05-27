echo "Initializing environment..."

export API_PORT="9933"
export DB_CONNECTION_STRING="user=app_api1 password=123 dbname=barbuddy sslmode=disable"
export DB_CONNECTION_DRIVER="postgres"

echo "Starting server..."
./api/api -logtostderr=true

