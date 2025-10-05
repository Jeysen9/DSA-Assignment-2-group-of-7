import ballerina/kafka;

// This file sets up Kafka producers and consumers for event-driven communication

// Create a Kafka producer instance that connects to the Kafka broker
kafka:Producer kafkaProducer = check new (KAFKA_BROKER);

// Function to publish events to Kafka topics
public function publishEvent(string topic, string message) returns error? {
    kafka:ProducerError? result = kafkaProducer->send(message, topic);
    if result is kafka:ProducerError {
        log:printError("Failed to send message to Kafka topic: " + topic, 'error = result);
        return error("Kafka send failed");
    }
    log:printInfo("Message sent to Kafka topic '" + topic + "': " + message);
}

// Kafka consumer for ticket requests (used by Payment Service)
kafka:Consumer ticketRequestsConsumer = check new ({
    topics: [TICKET_REQUESTS_TOPIC],
    groupId: "payment-service",
    bootstrapServers: KAFKA_BROKER
});

// Kafka consumer for payment events (used by Ticketing Service)
kafka:Consumer paymentEventsConsumer = check new ({
    topics: [PAYMENTS_PROCESSED_TOPIC],
    groupId: "ticketing-service", 
    bootstrapServers: KAFKA_BROKER
});

// Kafka consumer for various notifications (used by Notification Service)
kafka:Consumer notificationsConsumer = check new ({
    topics: [SCHEDULE_UPDATES_TOPIC, PAYMENTS_PROCESSED_TOPIC, TICKET_VALIDATIONS_TOPIC],
    groupId: "notification-service",
    bootstrapServers: KAFKA_BROKER
});
