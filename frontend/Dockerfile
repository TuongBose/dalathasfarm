# Base image, even version for production
FROM node:20.19.0-alpine AS builder
# Set the working directory
WORKDIR /app

# Copy the package.json and package-lock.json files
COPY package*.json ./

# Install dependencies using npm
RUN npm install

# Copy the rest of the app's code excluding node_modules
COPY . .

# Build the Angular app in production mode
RUN npm run build --prod --output-path=dist/frontend

# Production-ready image
FROM nginx:alpine

# Copy the built app from the builder stage
COPY --from=builder /app/dist/frontend /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
