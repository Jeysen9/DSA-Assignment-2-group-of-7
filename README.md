# DSA-Assignment-2-group-of-7
this repo is to complete assignment 2 which requires users to be able to concurrently book seats on a bus. we are required to apply docker, kafka and a database to complete this 

 Group members:

1.Joshua Madzimure, cybernust@gmail.com (219138451)

2.Jeysen Nyandoro, jeysennyandoro@gmail.com (224002058)

3.Rowan van Wyk, rjvanwyk@icloud.com (224002244)

4.Geraldo Liebenberg, geraldo.liebenberg@gmail.com (220029326)

5.Alina N Daniel, alinadaniel.n@gmail.com (220045216)

6.Beauty Masene, bmoonchino07@gmail.com (220035687)

7.Marcheline Matroos, 2000marcheline@gmail.com (220074291)

# Smart Public Transport Ticketing System 🚌🎫

A modern, distributed ticketing system for public transport built with Ballerina, featuring microservices architecture, event-driven communication, and containerized deployment.

## 📋 Project Overview

This system replaces traditional paper-based ticketing with a scalable, fault-tolerant platform that handles passenger registration, ticket purchasing, payment processing, and real-time notifications. Designed for high concurrency during peak hours, it serves passengers, transport administrators, and vehicle validators.

### Key Features
- **Passenger Management**: Account creation, login, and ticket viewing
- **Route & Trip Management**: Create and manage transport schedules
- **Ticket Lifecycle**: Complete ticket flow (CREATED → PAID → VALIDATED → EXPIRED)
- **Payment Processing**: Simulated payment gateway integration
- **Real-time Notifications**: Service updates and ticket status changes
- **Admin Controls**: System management and announcements

## 🏗️ System Architecture

### Microservices Structure
```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│  Passenger      │    │   Transport      │    │    Ticketing    │
│    Service      │    │     Service      │    │     Service     │
│  (Port 8080)    │    │   (Port 8081)    │    │   (Port 8082)   │
└─────────────────┘    └──────────────────┘    └─────────────────┘
         │                       │                       │
         └─────────────────────────────────────────────────┐
                                     │                     │
                                     ▼                     ▼
┌─────────────────┐    ┌─────────────────────────────────────────┐
│   Payment       │    │               KAFKA                    │
│    Service      │◄───┤            Event Bus                   │
│  (Port 8083)    │    │ ticket.requests, payments.processed,   │
└─────────────────┘    │ schedule.updates, ticket.validations   │
         │              └─────────────────────────────────────────┘
         │                       │                     ▲
         └───────────────────────┼─────────────────────┘
                                 │
                                 ▼
┌─────────────────┐    ┌─────────────────┐
│  Notification   │    │     Admin       │
│    Service      │    │     Service     │
│  (Port 8084)    │    │   (Port 8085)   │
└─────────────────┘    └─────────────────┘
```

### Technology Stack
- **Ballerina** - Main programming language for all services
- **Kafka** - Event-driven communication between services
- **SQL Server** - Persistent data storage
- **Docker** - Containerization and orchestration
- **REST APIs** - Service communication and external interfaces

## 🚀 Quick Start

### Prerequisites
- Docker Desktop
- Ballerina Swan Lake 2201.8.0+
- SQL Server (or use the provided Docker setup)

### Installation & Running

1. **Clone and setup infrastructure:**
```bash
# Start required services
docker-compose up -d

# Create Kafka topics
chmod +x kafka-setup/create-topics.sh
./kafka-setup/create-topics.sh
```

2. **Build and run the application:**
```bash
# Build Ballerina project
bal build

# Run the system
bal run
```

3. **Verify services are running:**
```bash
curl http://localhost:8085/api/admin/health
# Should return: "Admin Service is running smoothly"
```

## 🎯 How It Works

### Complete Passenger Journey

#### 1. **Passenger Registration**
```ballerina
// Passenger registers in the system
POST /api/passengers/register
{
    "email": "john@example.com",
    "password": "password123",
    "firstName": "John",
    "lastName": "Doe"
}
```

#### 2. **Browse Available Routes**
```ballerina
// View all active transport routes
GET /api/transport/routes
// Returns available routes with fares and schedules
```

#### 3. **Purchase Ticket**
```ballerina
// Request a ticket for a trip
POST /api/tickets/request
{
    "passengerId": 1,
    "tripId": 1,
    "price": 2.50,
    "ticketType": "SINGLE_RIDE"
}
```

#### 4. **Payment Processing** (Event-Driven)
```ballerina
// Kafka Event Flow:
// 1. Ticketing Service → "ticket.requests" topic
// 2. Payment Service processes payment → "payments.processed" topic  
// 3. Ticketing Service updates ticket status to PAID
// 4. Notification Service sends confirmation
```

#### 5. **Ticket Validation**
```ballerina
// Validate ticket when boarding
POST /api/tickets/1/validate
// Updates status to VALIDATED and notifies all services
```

### Event-Driven Communication

The system uses Kafka topics for loose coupling between services:

| Topic | Purpose | Producers | Consumers |
|-------|---------|-----------|-----------|
| `ticket.requests` | New ticket requests | Ticketing | Payment |
| `payments.processed` | Payment confirmations | Payment | Ticketing, Notification |
| `schedule.updates` | Route/trip changes | Transport, Admin | Notification |
| `ticket.validations` | Ticket usage events | Ticketing | Notification |

## 📁 Project Structure

```
smart-ticketing-system/
├── Ballerina.toml          # Dependencies and package config
├── main.bal                # Application entry point
├── config.bal              # Configuration constants
├── models.bal              # Data structures and types
├── database.bal            # Database operations
├── kafka_clients.bal       # Kafka producers/consumers
├── services/               # Individual microservices
│   ├── passenger_service.bal
│   ├── transport_service.bal
│   ├── ticketing_service.bal
│   ├── payment_service.bal
│   ├── notification_service.bal
│   └── admin_service.bal
├── docker-compose.yml      # Infrastructure setup
└── kafka-setup/
    └── create-topics.sh    # Kafka topic initialization
```

## 🔧 API Endpoints

### Passenger Service (`:8080`)
- `POST /api/passengers/register` - Create new passenger account
- `POST /api/passengers/login` - Passenger authentication
- `GET /api/passengers` - List all passengers
- `GET /api/passengers/{id}` - Get passenger details

### Transport Service (`:8081`)
- `POST /api/transport/routes` - Create new transport route
- `POST /api/transport/trips` - Schedule new trip
- `GET /api/transport/routes` - Get all active routes
- `PUT /api/transport/trips/{id}/status` - Update trip status

### Ticketing Service (`:8082`)
- `POST /api/tickets/request` - Request new ticket
- `POST /api/tickets/{id}/validate` - Validate ticket
- `GET /api/tickets/passenger/{id}` - Get passenger's tickets

### Admin Service (`:8085`)
- `POST /api/admin/announcements/disruption` - Publish service disruptions
- `POST /api/admin/announcements/general` - Send general announcements
- `GET /api/admin/health` - System health check

## 🐳 Docker Deployment

The system is fully containerized:

```bash
# Build and start all services
docker-compose up --build

# View logs
docker-compose logs -f

# Scale specific services
docker-compose up --scale ticketing-service=3
```

## 🎨 Key Design Patterns

### 1. **Microservices Architecture**
Each service has a single responsibility and can be developed, deployed, and scaled independently.

### 2. **Event-Driven Communication**
Services communicate asynchronously via Kafka, ensuring:
- Loose coupling between services
- Fault tolerance (messages persist if services are down)
- Scalability (multiple instances can process events)

### 3. **Database Per Service Pattern**
Each service manages its own data while sharing the database instance, maintaining clear data boundaries.

### 4. **Containerization**
Docker provides consistent environments from development to production.

## 📊 Monitoring & Observability

The system includes built-in logging and can be extended with:
- **Ballerina Observability** - Built-in metrics and tracing
- **Prometheus/Grafana** - Metrics collection and visualization
- **Kafka Tool** - Monitor topic health and message flow

## 🔮 Future Enhancements

- [ ] Real-time seat reservations with concurrency control
- [ ] Web dashboard for trip and ticket monitoring
- [ ] Kubernetes deployment with auto-scaling
- [ ] Integration with actual payment gateways
- [ ] Mobile app with QR code validation
- [ ] Predictive analytics for route optimization

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 🙏 Acknowledgments

- Ballerina Language for excellent distributed systems support
- Apache Kafka for robust event streaming
- Docker for seamless containerization
- Windhoek City Council for the project inspiration


