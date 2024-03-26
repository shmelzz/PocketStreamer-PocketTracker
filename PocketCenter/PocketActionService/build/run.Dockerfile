# Start from a base image, e.g., a Golang image for the build stage
FROM golang:1.21-alpine as builder


RUN apk add --no-cache build-base imagemagick-dev imagemagick imagemagick-pdf imagemagick-jpeg

# Set the working directory in the container
WORKDIR /app

# Copy the go module files and download dependencies
COPY go.mod .
COPY go.sum .
RUN go mod download

# Copy the source code into the container
COPY . .

# Build your application
ENV CGO_ENABLED=1
ENV CGO_CFLAGS_ALLOW=-Xpreprocessor
RUN go build -o myapp ./cmd

FROM alpine:latest
RUN apk add --no-cache tzdata ca-certificates imagemagick-dev imagemagick imagemagick-pdf imagemagick-jpeg

WORKDIR /app

# Copy the binary from the builder stage
COPY --from=builder /app/myapp /app/myapp

# Command to run when starting the container
CMD ["./myapp"]
