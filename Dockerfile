# Ballerina runtime image
FROM ballerina/ballerina-runtime:2201.8.0

# Set working directory
WORKDIR /home/ballerina

# Copy the compiled BALX file
COPY target/bin/smart_ticketing_system.jar .

# Expose all service ports
EXPOSE 8080 8081 8082 8083 8084 8085

# Run the application
CMD ["ballerina", "run", "smart_ticketing_system.jar"]
