# Start from a base image, e.g., a Golang image for the build stage
FROM golang:1.21 as builder

# Set the working directory in the container
WORKDIR /app

# Install ImageMagick deps
RUN apt-get -q -y install libjpeg-dev libpng-dev libtiff-dev \
    libgif-dev libx11-dev --no-install-recommends

# Copy the go module files and download dependencies
COPY go.mod .
COPY go.sum .
RUN go mod download

# Copy the source code into the container
COPY . .

# Build your application
ENV CGO_ENABLED=0
RUN go build -o myapp ./cmd

FROM alpine:latest

WORKDIR /app

ENV IMAGEMAGICK_VERSION=6.9.10-11

RUN cd && \
    wget https://github.com/ImageMagick/ImageMagick6/archive/${IMAGEMAGICK_VERSION}.tar.gz && \
    tar xvzf ${IMAGEMAGICK_VERSION}.tar.gz && \
    cd ImageMagick* && \
    ./configure \
    --without-magick-plus-plus \
    --without-perl \
    --disable-openmp \
    --with-gvc=no \
    --disable-docs && \
    make -j$(nproc) && make install && \
    ldconfig /usr/local/lib
# Copy the binary from the builder stage
COPY --from=builder /app/myapp /app/myapp

# Command to run when starting the container
CMD ["./myapp"]
