import ballerina/sql;
import ballerina/java.jdbc;
import ballerina/log;

public final jdbc:Client dbClient = checkpanic new (DB_URL, DB_USERNAME, DB_PASSWORD);

public function initDatabase() {
    // Clean up existing tables
    _ = dbClient->execute(`DROP TABLE IF EXISTS tickets`);
    _ = dbClient->execute(`DROP TABLE IF EXISTS routes`); 
    _ = dbClient->execute(`DROP TABLE IF EXISTS passengers`);

    // Create tables
    _ = dbClient->execute(`CREATE TABLE passengers (
        id INT IDENTITY(1,1) PRIMARY KEY, 
        email VARCHAR(255), 
        name VARCHAR(100)
    )`);
    
    _ = dbClient->execute(`CREATE TABLE routes (
        id INT IDENTITY(1,1) PRIMARY KEY,
        origin VARCHAR(100), 
        destination VARCHAR(100), 
        fare DECIMAL(10,2)
    )`);
    
    _ = dbClient->execute(`CREATE TABLE tickets (
        id INT IDENTITY(1,1) PRIMARY KEY,
        passengerId INT, 
        routeId INT, 
        status VARCHAR(20) DEFAULT 'CREATED'
    )`);
    
    log:printInfo("Database tables created successfully");
}
