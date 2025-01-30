# Dockerfile for Frontend (React with Nginx) - Created using Vite

# Use Node.js for the build stage
FROM node:20 as build

ARG VITE_API_IP
ENV VITE_API_IP=${VITE_API_IP}

# Debugging: Print the value to the build log
RUN echo "VITE_API_IP is set to: $VITE_API_IP"  

# Set the working directory
WORKDIR /app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application code
COPY . .


# Build the application (Vite project)
RUN npm run build

# Use Nginx to serve the static files
FROM nginx:alpine

# Copy the Vite build output to replace the default Nginx contents
COPY --from=build /app/dist /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Command to run Nginx
CMD ["nginx", "-g", "daemon off;"]
