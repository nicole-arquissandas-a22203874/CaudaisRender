#!/bin/bash
# start.sh

# Start NGINX in background
nginx

# Start Gunicorn normally
gunicorn --bind 127.0.0.1:3000 --timeout=86400 Project_django.wsgi:application
