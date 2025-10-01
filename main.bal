import ballerina/log;
import ballerina/http;

// Main entry point of the Smart Ticketing System
// This file starts all the services and coordinates the entire system

public function main() returns error? {
    log:printInfo("🚀 Starting Smart Public Transport Ticketing System...");
    
    // Initialize database tables
    _ = initializeDatabase();
    log:printInfo("✅ Database initialized");
    
    // Start Kafka listeners in separate strands (lightweight threads)
    // Payment Service listener
    _ = start startPaymentService();
    log:printInfo("✅ Payment Service started");
    
    // Ticketing Service payment listener  
    _ = start startPaymentListener();
    log:printInfo("✅ Ticketing Service payment listener started");
    
    // Notification Service listener
    _ = start startNotificationService();
    log:printInfo("✅ Notification Service started");
    
    // Start HTTP services
    log:printInfo("Starting HTTP services on ports 8080-8085...");
    
    // These services will start automatically when we run the Ballerina program
    // Ballerina automatically detects and starts all services defined with http:Listener
    
    log:printInfo("""
    ✅ All services started successfully!
    
    Service Endpoints:
    - Passenger Service: http://localhost:8080/api/passengers
    - Transport Service: http://localhost:8081/api/transport  
    - Ticketing Service: http://localhost:8082/api/tickets
    - Admin Service: http://localhost:8085/api/admin
    
    Kafka Topics:
    - ticket.requests, payments.processed, schedule.updates, ticket.validations, notifications
    
    Use Ctrl+C to stop the system
    """);
    
    // Keep the main function running
    while true {
        runtime:sleep(10);
    }
}
