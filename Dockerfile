# Build Stage
FROM node:16.17.0-alpine as builder

WORKDIR /app

# Copy package.json and yarn.lock
COPY ./package.json .
COPY ./yarn.lock .

# Install dependencies
RUN yarn install

# Copy the application code
COPY . .

# Set build arguments and environment variables
ARG TMDB_V3_API_KEY
ENV VITE_APP_TMDB_V3_API_KEY=${TMDB_V3_API_KEY}
ENV VITE_APP_API_ENDPOINT_URL="https://api.themoviedb.org/3"

# Build the application
RUN yarn build

# Final Stage
FROM nginx:stable-alpine

WORKDIR /usr/share/nginx/html

# Remove existing files in the Nginx HTML directory
RUN rm -rf ./*

# Copy the built application from the builder stage
COPY --from=builder /app/dist .

# Expose port 80
EXPOSE 80

# Set entrypoint command
ENTRYPOINT ["nginx", "-g", "daemon off;"]
