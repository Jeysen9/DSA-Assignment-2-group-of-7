import ballerina/http;
import ballerina/log;

// Admin service on port 8085
service /admin on new http:Listener(8085) {
    
    // Send announcements
    resource function post announcements(string message) returns json {
        sendToKafka("schedule.updates", "ANNOUNCEMENT: " + message);
        return {message: "Announcement sent: " + message};
    }
    
    // Health check
    resource function get health() returns json {
        return {status: "All services running"};
    }
}
