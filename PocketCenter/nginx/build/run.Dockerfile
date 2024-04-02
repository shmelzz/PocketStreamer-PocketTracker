# Use the official NGINX image as a base
FROM nginx:latest

# Remove the default NGINX configuration file
RUN rm /etc/nginx/conf.d/default.conf

ARG NGINX_CONF_PATH
# Copy the custom nginx.conf file from your host to the container
COPY ${NGINX_CONF_PATH} /etc/nginx/nginx.conf