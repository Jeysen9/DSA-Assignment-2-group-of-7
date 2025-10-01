import ballerina/time;

// This file defines all the data structures (records) used across the system

// Represents a passenger/user of the system
public type Passenger record {|
    readonly int id?;
    string email;
    string password;
    string firstName;
    string lastName;
    decimal accountBalance = 0.0;
|};

// Represents a transport route (e.g., "Downtown to Airport")
public type Route record {|
    readonly int id?;
    string origin;
    string destination;
    decimal distance;  // in kilometers
    decimal baseFare;
    boolean active = true;
|};

// Represents a scheduled trip on a specific route
public type Trip record {|
    readonly int id?;
    int routeId;
    time:Utc departureTime;
    time:Utc arrivalTime;
    int availableSeats;
    string status = "SCHEDULED";  // SCHEDULED, DEPARTED, ARRIVED, CANCELLED
|};

// Represents a ticket with its lifecycle states
public type Ticket record {|
    readonly int id?;
    int passengerId;
    int tripId;
    decimal price;
    string ticketType;  // SINGLE_RIDE, MULTI_RIDE, PASS
    string status = "CREATED";  // CREATED → PAID → VALIDATED → EXPIRED
    time:Utc createdAt = time:utcNow();
    time:Utc validatedAt?;
    time:Utc expiresAt = time:utcAddSeconds(time:utcNow(), 86400); // 24 hours
|};

// Custom error type for consistent error handling
public type Error record {|
    string message;
    string code;
|};
