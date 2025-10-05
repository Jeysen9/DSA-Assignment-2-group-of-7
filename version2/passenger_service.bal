import ballerina/http;
import ballerina/log;

// Passenger service on port 8080
service /passengers on new http:Listener(8080) {
    
    // Register a new passenger
    resource function post register(string email, string name) returns json {
        sql:ExecutionResult result = dbClient->execute(`
            INSERT INTO passengers (email, name) 
            VALUES (${email}, ${name})
        `);
        return {
            id: result.lastInsertId,
            email: email,
            name: name
        };
    }
    
    // Get all passengers
    resource function get .() returns json {
        stream<record {}, error?> result = dbClient->query("SELECT * FROM passengers");
        record {}[] passengers = [];
        record {}? passenger = result.next();
        
        while passenger is record {} {
            passengers.push(passenger);
            passenger = result.next();
        }
        result.close();
        return passengers;
    }
}
