import ballerina/http;
import ballerina/log;

// Ticketing service on port 8082
service /tickets on new http:Listener(8082) {
    
    // Request a new ticket
    resource function post request(int passengerId, int routeId) returns json {
        sql:ExecutionResult result = dbClient->execute(`
            INSERT INTO tickets (passengerId, routeId, status) 
            VALUES (${passengerId}, ${routeId}, 'CREATED')
        `);
        
        string ticketId = result.lastInsertId.toString();
        sendToKafka("ticket.requests", "TICKET_REQUEST:" + ticketId);
        
        return {
            id: ticketId,
            passengerId: passengerId,
            routeId: routeId,
            status: "CREATED"
        };
    }
    
    // Validate a ticket
    resource function post validate/[int id]() returns json {
        dbClient->execute(`UPDATE tickets SET status='VALIDATED' WHERE id=${id}`);
        sendToKafka("ticket.validations", "TICKET_VALIDATED:" + id.toString());
        return {message: "Ticket " + id.toString() + " validated"};
    }
}
