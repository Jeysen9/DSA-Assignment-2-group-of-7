import ballerina/sql;
import ballerina/java.jdbc;

// This file handles all database operations and setup

// Database client for SQL Server connection
jdbc:Client dbClient = check new (DB_URL, DB_USERNAME, DB_PASSWORD);

// Function to initialize the SQL database tables
public function initializeDatabase() returns error? {
    // Creates passengers table
    _ = check dbClient->execute(`
        IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='passengers' AND xtype='U')     // If it doesn’t exist, the table is created with appropriate columns
        CREATE TABLE passengers (
            id INT IDENTITY(1,1) PRIMARY KEY,
            email VARCHAR(255) UNIQUE NOT NULL,
            password VARCHAR(255) NOT NULL,
            firstName VARCHAR(100),
            lastName VARCHAR(100),
            accountBalance DECIMAL(10,2) DEFAULT 0.0
    );
    
    // Create routes table
    // Defines available travel routes between locations
    _ = check dbClient->execute(`
        IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='routes' AND xtype='U')     // If it doesn’t exist, the table is created with appropriate columns
        CREATE TABLE routes (
            id INT IDENTITY(1,1) PRIMARY KEY,    // Auto-incrementing route ID
            origin VARCHAR(100) NOT NULL,
            destination VARCHAR(100) NOT NULL,
            distance DECIMAL(10,2),
            baseFare DECIMAL(10,2),
            active BIT DEFAULT 1
        )
    `);
    
    // Create trips table
    _ = check dbClient->execute(`
        IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='trips' AND xtype='U')
        CREATE TABLE trips (
            id INT IDENTITY(1,1) PRIMARY KEY,
            routeId INT NOT NULL,
            departureTime DATETIME2,
            arrivalTime DATETIME2,
            availableSeats INT,
            status VARCHAR(50) DEFAULT 'SCHEDULED',
            FOREIGN KEY (routeId) REFERENCES routes(id)
        )
    `);
    
    // Create tickets table
    _ = check dbClient->execute(`
        IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='tickets' AND xtype='U')
        CREATE TABLE tickets (
            id INT IDENTITY(1,1) PRIMARY KEY,
            passengerId INT NOT NULL,
            tripId INT NOT NULL,
            price DECIMAL(10,2),
            ticketType VARCHAR(50),
            status VARCHAR(50) DEFAULT 'CREATED',
            createdAt DATETIME2 DEFAULT GETDATE(),
            validatedAt DATETIME2,
            expiresAt DATETIME2,
            FOREIGN KEY (passengerId) REFERENCES passengers(id),
            FOREIGN KEY (tripId) REFERENCES trips(id)
        )
    `);
    
    log:printInfo("Database tables initialized successfully");
}

// Generic functions to insert any record and return the generated ID
public function insertRecord(string tableName, anydata record) returns int|error {
    sql:ParameterizedQuery query = `INSERT INTO ${tableName} VALUES (DEFAULT, ${record[1]}, ${record[2]}, ${record[3]}, ${record[4]}, ${record[5]})`;
    sql:ExecutionResult result = check dbClient->execute(query);
    return <int>result.lastInsertId;
}

// Generic function to query records
public function queryRecords(string tableName, string whereClause = "") returns stream<record {}, error?>|error {
    string queryStr = "SELECT * FROM " + tableName;
    if whereClause != "" {
        queryStr += " WHERE " + whereClause;
    }
    return dbClient->query(queryStr);
}
