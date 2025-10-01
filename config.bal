// This file contains all configuration constants and settings for the entire system

// Database configuration
public const string DB_URL = "jdbc:sqlserver://localhost:1433;databaseName=ticketing;encrypt=false";
public const string DB_USERNAME = "sa";
public const string DB_PASSWORD = "YourPassword123!";

// Kafka configuration
public const string KAFKA_BROKER = "localhost:9092";

// Service ports - each service runs on a different port
public const int PASSENGER_SERVICE_PORT = 8080;
public const int TRANSPORT_SERVICE_PORT = 8081;
public const int TICKETING_SERVICE_PORT = 8082;
public const int PAYMENT_SERVICE_PORT = 8083;
public const int NOTIFICATION_SERVICE_PORT = 8084;
public const int ADMIN_SERVICE_PORT = 8085;

// Kafka topic names for event-driven communication
public const string TICKET_REQUESTS_TOPIC = "ticket.requests";
public const string PAYMENTS_PROCESSED_TOPIC = "payments.processed";
public const string SCHEDULE_UPDATES_TOPIC = "schedule.updates";
public const string TICKET_VALIDATIONS_TOPIC = "ticket.validations";
public const string NOTIFICATIONS_TOPIC = "notifications";
