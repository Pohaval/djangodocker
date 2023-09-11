#!/bin/bash
RUN_PORT="8000"

 manage.py migrate --no-input
    cfehome.wsgi:application --bind "0.0.0.0:${RUN_PORT}" --daemon

nginx -g 'daemon off;'