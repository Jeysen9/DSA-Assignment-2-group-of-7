import ballerina/http;
import ballerina/log;

// Transport Service: Manages routes, trips, and publishes schedule updates

service /api/transport on new http:Listener(TRANSPORT_SERVICE_PORT) {

    // Create a new route
    resource function post routes(@http:Payload Route route) returns Route|http:BadRequest {
        log:printInfo("Creating new route: " + route.origin + " to " + route.destination);
        
        int routeId = check insertRecord("routes",
            [route.origin, route.destination, route.distance, route.baseFare, route.active]);
        
        route.id = routeId;
        return route;
    }
    
    // Create a new trip
    resource function post trips(@http:Payload Trip trip) returns Trip|http:BadRequest {
        log:printInfo("Creating new trip for route: " + trip.routeId.toString());
        
        int tripId = check insertRecord("trips",
            [trip.routeId, trip.departureTime, trip.arrivalTime, trip.availableSeats, trip.status]);
        
        trip.id = tripId;
        
        // Publish schedule update to Kafka
        string scheduleUpdate = "New trip scheduled: Route " + trip.routeId.toString() + 
                               " at " + trip.departureTime.toString();
        _ = publishEvent(SCHEDULE_UPDATES_TOPIC, scheduleUpdate);
        
        return trip;
    }
    
    // Get all active routes
    resource function get routes() returns stream<Route, error?>|http:InternalServerError {
        stream<record {}> result = check queryRecords("routes", "active=1");
        
        return result.map(function(record {} rec) returns Route {
            record {|int id; string origin; string destination; decimal distance; decimal baseFare; boolean active;|} routeRec = 
                <record {|int id; string origin; string destination; decimal distance; decimal baseFare; boolean active;|}>rec;
            return {
                id: routeRec.id,
                origin: routeRec.origin,
                destination: routeRec.destination,
                distance: routeRec.distance,
                baseFare: routeRec.baseFare,
                active: routeRec.active
            };
        });
    }
    
    // Update trip status
    resource function put trips/[int tripId]/status(string status) returns Trip|http:NotFound {
        // Update trip status in database
        _ = check dbClient->execute(`UPDATE trips SET status=${status} WHERE id=${tripId}`);
        
        // Get updated trip
        stream<record {}> result = check queryRecords("trips", "id=" + tripId.toString());
        record {|int id; int routeId; time:Utc departureTime; time:Utc arrivalTime; int availableSeats; string status;|}? tripRecord = check result.next();
        
        if tripRecord is () {
            return <http:NotFound>{body: "Trip not found"};
        }
        
        Trip trip = {
            id: tripRecord.id,
            routeId: tripRecord.routeId,
            departureTime: tripRecord.departureTime,
            arrivalTime: tripRecord.arrivalTime,
            availableSeats: tripRecord.availableSeats,
            status: tripRecord.status
        };
        
        // Notify about status change
        string statusUpdate = "Trip " + tripId.toString() + " status changed to: " + status;
        _ = publishEvent(SCHEDULE_UPDATES_TOPIC, statusUpdate);
        
        log:printInfo("Trip status updated: " + statusUpdate);
        return trip;
    }
}
