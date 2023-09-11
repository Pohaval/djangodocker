FROM python:3.8-slim-buster
RUN apt-get update && apt-get install -y nginx postgresql postgresql-contrib
COPY ./nginx.conf /etc/nginx/sites-enabled/mysite.local.conf
RUN ln -sf /dev/stdout /var/log/nginx/access.log && ln -sf /dev/stderr /var/log/nginx/error.log
COPY . /app
WORKDIR /app
VOLUME /app
RUN pip install -r requirements.txt
EXPOSE 80
EXPOSE 8000
CMD service postgresql start && \
    sleep 3 && \
    su - postgres -c "psql -c 'CREATE DATABASE mydb;'" && \
    su - postgres -c "psql -c 'CREATE USER admin WITH PASSWORD '\''admin'\'';'" && \
    su - postgres -c "psql -c 'ALTER DATABASE mydb OWNER TO admin;'" && \
    sleep 3 && \
    python manage.py migrate && \
    DJANGO_SUPERUSER_PASSWORD=admin python manage.py createsuperuser --noinput --username USERNAME --email test@test.te && \
    sleep 3 && \
    gunicorn cfehome.wsgi:application --bind "0.0.0.0:8000" --daemon && \
    nginx -g 'daemon off;'
