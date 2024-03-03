# Start from a base image, e.g., a Golang image
FROM golang:1.21

WORKDIR /app

COPY go.mod .
COPY go.sum .

RUN go mod download

# Copy the source code into the container
COPY . /app

# Set the working directory


# Build your application
RUN go build -o myapp ./cmd