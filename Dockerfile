# Use the official Golang image to create a build artifact.
# This is known as a multi-stage build.
FROM golang:1.24 AS builder

# Set the Current Working Directory inside the container
WORKDIR /app

# Copy go mod file
COPY go.mod ./

# Download all dependencies. Dependencies will be cached if the go.mod file is not changed
RUN go mod download

# Copy the source code from the current directory to the Working Directory inside the container
COPY . .

# Build the Go app
RUN CGO_ENABLED=0 GOOS=linux go build -v -o server .

# Start a new stage from scratch for a smaller image
FROM alpine:latest

# Set the Current Working Directory inside the container
WORKDIR /root/

# Copy the Pre-built binary file from the previous stage
COPY --from=builder /app/server .

# Expose port 8080 to the outside world
EXPOSE 8080

# Command to run the executable
CMD ["./server"]
