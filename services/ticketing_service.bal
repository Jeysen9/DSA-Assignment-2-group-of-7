import ballerina/http;
import ballerina/log;

// Ticketing Service: Manages ticket lifecycle and validation

service /api/tickets on new http:Listener(TICKETING_SERVICE_PORT) {

    // Request a new ticket
    resource function post request(@http:Payload Ticket ticket) returns Ticket|http:BadRequest {
        log:printInfo("Ticket request from passenger: " + ticket.passengerId.toString());
        
        int ticketId = check insertRecord("tickets",
            [ticket.passengerId, ticket.tripId, ticket.price, ticket.ticketType, ticket.status]);
        
        ticket.id = ticketId;
        
        // Publish ticket request to Kafka for payment processing
        string ticketRequest = "TICKET_REQUEST:" + ticketId.toString() + ":" + 
                              ticket.passengerId.toString() + ":" + ticket.price.toString();
        _ = publishEvent(TICKET_REQUESTS_TOPIC, ticketRequest);
        
        return ticket;
    }
    
    // Validate a ticket (when passenger boards)
    resource function post [int ticketId]/validate() returns Ticket|http:BadRequest|http:NotFound {
        // Get ticket from database
        stream<record {}> result = check queryRecords("tickets", "id=" + ticketId.toString());
        record {|int id; int passengerId; int tripId; decimal price; string ticketType; string status; time:Utc createdAt; time:Utc validatedAt?; time:Utc expiresAt;|}? ticketRecord = check result.next();
        
        if ticketRecord is () {
            return <http:NotFound>{body: "Ticket not found"};
        }
        
        // Check if ticket is paid
        if ticketRecord.status != "PAID" {
            return <http:BadRequest>{body: "Ticket not paid"};
        }
        
        // Update ticket status to VALIDATED
        _ = check dbClient->execute(`UPDATE tickets SET status='VALIDATED', validatedAt=${time:utcNow()} WHERE id=${ticketId}`);
        
        Ticket validatedTicket = {
            id: ticketRecord.id,
            passengerId: ticketRecord.passengerId,
            tripId: ticketRecord.tripId,
            price: ticketRecord.price,
            ticketType: ticketRecord.ticketType,
            status: "VALIDATED",
            createdAt: ticketRecord.createdAt,
            validatedAt: time:utcNow(),
            expiresAt: ticketRecord.expiresAt
        };
        
        // Publish validation event
        string validationEvent = "TICKET_VALIDATED:" + ticketId.toString() + ":" + ticketRecord.passengerId.toString();
        _ = publishEvent(TICKET_VALIDATIONS_TOPIC, validationEvent);
        
        log:printInfo("Ticket validated: " + ticketId.toString());
        return validatedTicket;
    }
    
    // Get tickets by passenger ID
    resource function get passenger/[int passengerId]() returns stream<Ticket, error?>|http:InternalServerError {
        stream<record {}> result = check queryRecords("tickets", "passengerId=" + passengerId.toString());
        
        return result.map(function(record {} rec) returns Ticket {
            record {|int id; int passengerId; int tripId; decimal price; string ticketType; string status; time:Utc createdAt; time:Utc validatedAt?; time:Utc expiresAt;|} ticketRec = 
                <record {|int id; int passengerId; int tripId; decimal price; string ticketType; string status; time:Utc createdAt; time:Utc validatedAt?; time:Utc expiresAt;|}>rec;
            return {
                id: ticketRec.id,
                passengerId: ticketRec.passengerId,
                tripId: ticketRec.tripId,
                price: ticketRec.price,
                ticketType: ticketRec.ticketType,
                status: ticketRec.status,
                createdAt: ticketRec.createdAt,
                validatedAt: ticketRec.validatedAt,
                expiresAt: ticketRec.expiresAt
            };
        });
    }
}

// Kafka listener for payment events
public function startPaymentListener() {
    while true {
        // Listen for payment processed events
        var paymentResult = paymentEventsConsumer->poll(1000);
        
        if paymentResult is kafka:ConsumerRecord[] {
            foreach var record in paymentResult {
                string message = check record.value;
                log:printInfo("Received payment event: " + message);
                
                // Process payment success events
                if message.startsWith("PAYMENT_SUCCESS:") {
                    string[] parts = message.split(":");
                    if parts.length() >= 3 {
                        int ticketId = check int:fromString(parts[1]);
                        
                        // Update ticket status to PAID
                        _ = dbClient->execute(`UPDATE tickets SET status='PAID' WHERE id=${ticketId}`);
                        log:printInfo("Ticket " + ticketId.toString() + " status updated to PAID");
                    }
                }
            }
            _ = paymentEventsConsumer->commit();
        }
    }
}
