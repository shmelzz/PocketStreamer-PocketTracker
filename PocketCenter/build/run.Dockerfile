# Start from a base image, e.g., a Golang image for the build stage
FROM golang:1.21 as builder

# Set the working directory in the container
WORKDIR /app

# Copy the go module files and download dependencies
COPY go.mod .
COPY go.sum .
RUN go mod download

# Copy the source code into the container
COPY . .

# Build your application
RUN go build -o myapp ./cmd

# Start the second stage for running the application
FROM golang:1.21

# Set the working directory in the container
WORKDIR /app

# Copy the binary from the builder stage
COPY --from=builder /app/myapp /app/myapp

# Command to run when starting the container
CMD ["./myapp"]
