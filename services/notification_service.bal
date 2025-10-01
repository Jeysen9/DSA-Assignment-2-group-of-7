import ballerina/log;

// Notification Service: Listens to events and sends notifications

// Kafka listener for various events
public function startNotificationService() {
    while true {
        var notifications = notificationsConsumer->poll(1000);
        
        if notifications is kafka:ConsumerRecord[] {
            foreach var record in notifications {
                string message = check record.value;
                string topic = record.topic;
                
                match topic {
                    SCHEDULE_UPDATES_TOPIC => {
                        log:printInfo("🔔 NOTIFICATION: Schedule Update - " + message);
                    }
                    PAYMENTS_PROCESSED_TOPIC => {
                        if message.startsWith("PAYMENT_SUCCESS:") {
                            string[] parts = message.split(":");
                            log:printInfo("🔔 NOTIFICATION: Payment Successful - Ticket " + parts[1] + " has been paid");
                        } else if message.startsWith("PAYMENT_FAILED:") {
                            string[] parts = message.split(":");
                            log:printInfo("🔔 NOTIFICATION: Payment Failed - Ticket " + parts[1] + " payment failed");
                        }
                    }
                    TICKET_VALIDATIONS_TOPIC => {
                        log:printInfo("🔔 NOTIFICATION: Ticket Validated - " + message);
                    }
                }
            }
            _ = notificationsConsumer->commit();
        }
    }
}
