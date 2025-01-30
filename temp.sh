# Create a temporary container from the built image
docker create --name temp-container markbosire/simple-mern-frontend:latest

# Copy the built files to your local machine
docker cp temp-container:/usr/share/nginx/html ./temp-html

# Open the built JS files and search for the IP
grep -r "VITE_API_IP" ./temp-html

# Cleanup
docker rm temp-container
rm -rf ./temp-html
