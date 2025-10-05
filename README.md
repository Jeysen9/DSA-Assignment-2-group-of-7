Smart Public Transport Ticketing System
Group members:

1.Joshua Madzimure, cybernust@gmail.com (219138451)

2.Jeysen Nyandoro, jeysennyandoro@gmail.com (224002058)

3.Rowan van Wyk, rjvanwyk@icloud.com (224002244)

4.Geraldo Liebenberg, geraldo.liebenberg@gmail.com (220029326)

5.Alina N Daniel, alinadaniel.n@gmail.com (220045216)

6.Beauty Masene, bmoonchino07@gmail.com (220035687)

7.Marcheline Matroos, 2000marcheline@gmail.com (220074291)

A distributed microservices-based ticketing system for public transport built with Ballerina, featuring event-driven architecture with Kafka and SQL Server database.
Project Overview

This system provides a modern ticketing platform for public transport with the following key features:

    Passenger registration and management

    Route and trip management

    Ticket purchasing and validation

    Payment processing simulation

    Real-time notifications

    Administrative controls

Technology Stack

    Ballerina - Main programming language

    Apache Kafka - Event-driven communication

    SQL Server - Persistent data storage

    Docker - Containerization

    REST APIs - Service interfaces

Project Structure
text

dsa-project-2-final-version/
├── Ballerina.toml
├── config.bal
├── database.bal
├── kafka.bal
├── main.bal
├── services/
│   ├── passenger_service.bal
│   ├── transport_service.bal
│   ├── ticketing_service.bal
│   ├── payment_service.bal
│   ├── notification_service.bal
│   └── admin_service.bal
├── docker-compose.yml
└── README.md

Service Architecture
Core Services

    Passenger Service (8080) - User registration and management

    Transport Service (8081) - Route and trip management

    Ticketing Service (8082) - Ticket lifecycle management

    Admin Service (8085) - System administration and announcements

Background Services

    Payment Service - Processes ticket payments via Kafka

    Notification Service - Handles system notifications via Kafka

Kafka Topics

    ticket.requests - New ticket purchase requests

    payments.processed - Payment confirmation events

    schedule.updates - Route and schedule changes

    ticket.validations - Ticket validation events

Database Schema
Tables

    passengers - User accounts and information

    routes - Transport routes with fares

    tickets - Ticket records with status tracking

Installation and Setup
Prerequisites

    Docker Desktop

    Ballerina Swan Lake

    SQL Server (local instance)

Step 1: Configure Database

Update config.bal with your SQL Server credentials:
ballerina

public const string DB_URL = "jdbc:sqlserver://localhost:1433;databaseName=dsa;encrypt=false";
public const string DB_USERNAME = "jeysen";
public const string DB_PASSWORD = "your_password_here";

Step 2: Start Infrastructure
bash

# Start Kafka and Zookeeper
docker-compose up -d

# Wait 60 seconds for services to start, then create Kafka topics
docker exec -it dsa-project-2-final-version-kafka-1 kafka-topics --create --bootstrap-server localhost:9092 --topic ticket.requests --replication-factor 1 --partitions 1
docker exec -it dsa-project-2-final-version-kafka-1 kafka-topics --create --bootstrap-server localhost:9092 --topic payments.processed --replication-factor 1 --partitions 1
docker exec -it dsa-project-2-final-version-kafka-1 kafka-topics --create --bootstrap-server localhost:9092 --topic schedule.updates --replication-factor 1 --partitions 1
docker exec -it dsa-project-2-final-version-kafka-1 kafka-topics --create --bootstrap-server localhost:9092 --topic ticket.validations --replication-factor 1 --partitions 1

Step 3: Run Application
bash

# Build and run the Ballerina application
bal run

API Endpoints
Passenger Service (8080)

Register Passenger
text

POST /passengers/register?email=user@example.com&name=John Doe

Get All Passengers
text

GET /passengers

Transport Service (8081)

Create Route
text

POST /transport/routes?origin=City Center&destination=Airport&fare=2.50

Get All Routes
text

GET /transport

Ticketing Service (8082)

Request Ticket
text

POST /tickets/request?passengerId=1&routeId=1

Validate Ticket
text

POST /tickets/validate/1

Admin Service (8085)

Send Announcement
text

POST /admin/announcements?message=Service Update

Health Check
text

GET /admin/health

Usage Example
Complete Passenger Journey

    Register Passenger

bash

curl -X POST "http://localhost:8080/passengers/register?email=john@example.com&name=John%20Doe"

    Create Route

bash

curl -X POST "http://localhost:8081/transport/routes?origin=City%20Center&destination=Airport&fare=2.50"

    Purchase Ticket

bash

curl -X POST "http://localhost:8082/tickets/request?passengerId=1&routeId=1"

    Validate Ticket

bash

curl -X POST "http://localhost:8082/tickets/validate/1"

    Send Announcement

bash

curl -X POST "http://localhost:8085/admin/announcements?message=Route%20delays%20expected"

Event Flow

    Ticket Request: Ticketing Service → ticket.requests topic

    Payment Processing: Payment Service processes request → payments.processed topic

    Notification: Notification Service listens to all events

    Schedule Updates: Transport/Admin Services → schedule.updates topic

    Ticket Validation: Ticketing Service → ticket.validations topic

System Requirements

    Minimum 4GB RAM

    Docker Desktop with WSL2 backend (Windows)

    SQL Server 2019 or later

    Ballerina Swan Lake 2201.8.0+

Troubleshooting
Kafka Container Issues

If Kafka stops immediately:

    Check Docker Desktop has sufficient memory (4GB+)

    Ensure ports 9092 and 2181 are available

    Use docker logs dsa-project-2-final-version-kafka-1 to view errors

Database Connection Issues

    Verify SQL Server is running on localhost:1433

    Check database credentials in config.bal

    Ensure the dsa database exists

Build Issues

    Run bal clean before building

    Verify all dependencies in Ballerina.toml

    Check Ballerina version compatibility

Development

The system uses Ballerina's built-in HTTP services and Kafka clients for event-driven communication. Each service is independent and communicates asynchronously via Kafka topics.
