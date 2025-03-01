FROM node:10
WORKDIR /app
COPY package.json .
RUN npm install
COPY . .

# Copy the SSL/TLS certificate and private key
COPY ./certs /app/certs

# Expose the HTTPS port
EXPOSE 443

# Copy the startup script
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Set the startup script as the entrypoint
ENTRYPOINT ["/start.sh"]