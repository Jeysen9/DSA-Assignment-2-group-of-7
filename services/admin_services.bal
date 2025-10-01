import ballerina/http;
import ballerina/log;

// Admin Service: Administrative functions and announcements

service /api/admin on new http:Listener(ADMIN_SERVICE_PORT) {

    // Publish service disruption announcement
    resource function post announcements/disruption(string message) returns http:Ok|http:BadRequest {
        _ = publishEvent(SCHEDULE_UPDATES_TOPIC, "DISRUPTION: " + message);
        log:printInfo("Disruption announcement published: " + message);
        return {body: "Disruption announcement published successfully"};
    }
    
    // Publish general announcement  
    resource function post announcements/general(string message) returns http:Ok|http:BadRequest {
        _ = publishEvent(NOTIFICATIONS_TOPIC, "ANNOUNCEMENT: " + message);
        log:printInfo("General announcement published: " + message);
        return {body: "Announcement published successfully"};
    }
    
    // System health check
    resource function get health() returns http:Ok {
        return {body: "Admin Service is running smoothly"};
    }
}
