# Define the Kubernetes namespace and Pod name
NAMESPACE="connected-kiln"
CLIENT_POD="mosquitto-test-client"

echo "Starting repeated MQTT publishing (10 cycles)..."

for i in {1..10}; do
    # Generate a random offset for temperature (e.g., between -1.0 and 1.0)
    OFFSET=$(awk -v min=-1.0 -v max=1.0 'BEGIN{srand(); print min+rand()*(max-min)}')

    # Calculate new fluctuating values
    NEW_TEMP=$(awk "BEGIN {printf \"%.1f\", 1250.0 + $OFFSET}")
    NEW_PRESSURE=$(awk "BEGIN {printf \"%.2f\", 1.10 + $OFFSET/100.0}")

    # Construct the JSON payload
    PAYLOAD="{\"temp\": ${NEW_TEMP}, \"pressure\": ${NEW_PRESSURE}, \"device_id\": \"kiln-01\"}"

    # Execute mosquitto_pub inside the secure pod
    kubectl exec $CLIENT_POD -n $NAMESPACE -- mosquitto_pub -h mosquitto-service -p 1883 -t "kiln/furnace/01" -m "$PAYLOAD"

    echo "Sent data point $i: temp=${NEW_TEMP}"

    # Wait 2 seconds before sending the next message
    sleep 2
done

echo "Publishing complete."