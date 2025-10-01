import ballerina/http;
import ballerina/log;

// Passenger Service: Handles passenger registration, login, and account management

service /api/passengers on new http:Listener(PASSENGER_SERVICE_PORT) {

    // Register a new passenger
    resource function post register(@http:Payload Passenger passenger) returns Passenger|http:BadRequest {
        log:printInfo("Registering new passenger: " + passenger.email);
        
        // Insert passenger into database
        int passengerId = check insertRecord("passengers", 
            [passenger.email, passenger.password, passenger.firstName, passenger.lastName, passenger.accountBalance]);
        
        // Return the created passenger with generated ID
        passenger.id = passengerId;
        return passenger;
    }
    
    // Passenger login
    resource function post login(string email, string password) returns Passenger|http:NotFound {
        log:printInfo("Login attempt for: " + email);
        
        // Query database for matching passenger
        stream<record {}> result = check queryRecords("passengers", 
            "email='" + email + "' AND password='" + password + "'");
        
        record {|int id; string email; string password; string firstName; string lastName; decimal accountBalance;|}? passengerRecord = check result.next();
        
        if passengerRecord is () {
            return <http:NotFound>{body: "Invalid email or password"};
        }
        
        // Convert database record to Passenger type
        Passenger passenger = {
            id: passengerRecord.id,
            email: passengerRecord.email,
            password: passengerRecord.password, 
            firstName: passengerRecord.firstName,
            lastName: passengerRecord.lastName,
            accountBalance: passengerRecord.accountBalance
        };
        
        log:printInfo("Login successful for: " + email);
        return passenger;
    }
    
    // Get all passengers (for admin purposes)
    resource function get .() returns stream<Passenger, error?>|http:InternalServerError {
        stream<record {}> result = check queryRecords("passengers");
        
        // Convert each database record to Passenger type
        return result.map(function(record {} rec) returns Passenger {
            record {|int id; string email; string password; string firstName; string lastName; decimal accountBalance;|} passengerRec = <record {|int id; string email; string password; string firstName; string lastName; decimal accountBalance;|}>rec;
            return {
                id: passengerRec.id,
                email: passengerRec.email,
                password: passengerRec.password,
                firstName: passengerRec.firstName,
                lastName: passengerRec.lastName,
                accountBalance: passengerRec.accountBalance
            };
        });
    }
    
    // Get passenger by ID
    resource function get [int id]() returns Passenger|http:NotFound {
        stream<record {}> result = check queryRecords("passengers", "id=" + id.toString());
        
        record {|int id; string email; string password; string firstName; string lastName; decimal accountBalance;|}? passengerRecord = check result.next();
        
        if passengerRecord is () {
            return <http:NotFound>{body: "Passenger not found"};
        }
        
        return {
            id: passengerRecord.id,
            email: passengerRecord.email,
            password: passengerRecord.password,
            firstName: passengerRecord.firstName,
            lastName: passengerRecord.lastName,
            accountBalance: passengerRecord.accountBalance
        };
    }
}
