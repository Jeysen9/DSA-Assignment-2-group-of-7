import ballerina/log;
import ballerina/kafka;

// Kafka consumer for payment processing
public final kafka:Consumer paymentConsumer = checkpanic new ({
    topics: ["ticket.requests"],
    groupId: "payment-service",
    bootstrapServers: KAFKA_BROKER
});

// Payment service that listens for ticket requests
public function startPaymentService() {
    log:printInfo("Payment service started");
    
    while true {
        // Poll for new messages
        kafka:ConsumerRecord[]|error records = paymentConsumer->poll(1000);
        
        if records is kafka:ConsumerRecord[] {
            foreach var record in records {
                string message = checkpanic record.value;
                log:printInfo("Payment processing: " + message);
                
                // Simulate payment processing
                sendToKafka("payments.processed", "PAYMENT_SUCCESS:" + message);
            }
            // Commit the offsets
            _ = paymentConsumer->commit();
        }
    }
}
