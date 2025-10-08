# Use the official NGINX image as a base
FROM nginx:latest

# Expose port 80 to access the web server
EXPOSE 80

# Start NGINX when the container runs
CMD ["nginx", "-g", "daemon off;"]
