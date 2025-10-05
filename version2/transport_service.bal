import ballerina/http;
import ballerina/log;

// Transport service on port 8081  
service /transport on new http:Listener(8081) {
    
    // Create a new route
    resource function post routes(string origin, string destination, decimal fare) returns json {
        sql:ExecutionResult result = dbClient->execute(`
            INSERT INTO routes (origin, destination, fare) 
            VALUES (${origin}, ${destination}, ${fare})
        `);
        
        sendToKafka("schedule.updates", "New route: " + origin + " to " + destination);
        
        return {
            id: result.lastInsertId,
            origin: origin,
            destination: destination, 
            fare: fare
        };
    }
    
    // Get all routes
    resource function get .() returns json {
        stream<record {}, error?> result = dbClient->query("SELECT * FROM routes");
        record {}[] routes = [];
        record {}? route = result.next();
        
        while route is record {} {
            routes.push(route);
            route = result.next();
        }
        result.close();
        return routes;
    }
}
