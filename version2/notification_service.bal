import ballerina/log;
import ballerina/kafka;

// Kafka consumer for notifications
public final kafka:Consumer notifyConsumer = checkpanic new ({
    topics: ["schedule.updates", "payments.processed", "ticket.validations"],
    groupId: "notification-service",
    bootstrapServers: KAFKA_BROKER
});

// Notification service that listens to all topics
public function startNotificationService() {
    log:printInfo("Notification service started");
    
    while true {
        // Poll for new messages
        kafka:ConsumerRecord[]|error records = notifyConsumer->poll(1000);
        
        if records is kafka:ConsumerRecord[] {
            foreach var record in records {
                string message = checkpanic record.value;
                log:printInfo("NOTIFICATION [" + record.topic + "]: " + message);
            }
            // Commit the offsets
            _ = notifyConsumer->commit();
        }
    }
}
