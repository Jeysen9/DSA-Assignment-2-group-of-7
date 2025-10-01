import ballerina/log;

// Payment Service: Processes payments and publishes payment events

// Kafka listener for ticket requests
public function startPaymentService() {
    while true {
        // Listen for ticket request events
        var ticketRequests = ticketRequestsConsumer->poll(1000);
        
        if ticketRequests is kafka:ConsumerRecord[] {
            foreach var record in ticketRequests {
                string message = check record.value;
                log:printInfo("Received ticket request: " + message);
                
                // Process ticket request
                if message.startsWith("TICKET_REQUEST:") {
                    string[] parts = message.split(":");
                    if parts.length() >= 4 {
                        string ticketId = parts[1];
                        string passengerId = parts[2];
                        string amount = parts[3];
                        
                        // Simulate payment processing
                        boolean paymentSuccess = simulatePayment(passengerId, amount);
                        
                        if paymentSuccess {
                            // Publish payment success event
                            string paymentEvent = "PAYMENT_SUCCESS:" + ticketId + ":" + amount;
                            _ = publishEvent(PAYMENTS_PROCESSED_TOPIC, paymentEvent);
                            log:printInfo("Payment processed successfully for ticket: " + ticketId);
                        } else {
                            // Publish payment failure event
                            string paymentEvent = "PAYMENT_FAILED:" + ticketId + ":" + amount;
                            _ = publishEvent(PAYMENTS_PROCESSED_TOPIC, paymentEvent);
                            log:printInfo("Payment failed for ticket: " + ticketId);
                        }
                    }
                }
            }
            _ = ticketRequestsConsumer->commit();
        }
    }
}

// Simulate payment processing
function simulatePayment(string passengerId, string amount) returns boolean {
    log:printInfo("Processing payment of " + amount + " for passenger " + passengerId);
    // In real system, this would integrate with payment gateway
    // For demo, always return true
    return true;
}
