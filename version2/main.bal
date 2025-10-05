import ballerina/log;
import ballerina/lang.runtime;

// Main application entry point
public function main() returns error? {
    log:printInfo(" Starting Smart Public Transport Ticketing System...");
    
    // Initialize database
    initDatabase();
    
    // Start background services
    _ = start startPaymentService();
    _ = start startNotificationService();
    
    log:printInfo(" All services started successfully!");
    log:printInfo(" Service endpoints:");
    log:printInfo("   - Passenger: http://localhost:8080/passengers");
    log:printInfo("   - Transport: http://localhost:8081/transport"); 
    log:printInfo("   - Ticketing: http://localhost:8082/tickets");
    log:printInfo("   - Admin:     http://localhost:8085/admin");
    log:printInfo("");
    log:printInfo("Press Ctrl+C to stop the system");
    
    // Keep the main thread alive
    while true {
        runtime:sleep(10);
    }
}
