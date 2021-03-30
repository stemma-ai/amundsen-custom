FROM python:3.7-slim

ENV LANG="en_US.utf8" \
    AMUNDSEN_SERVICE_NAME="search" \
    # use sock
    GUNICORN_BIND="0.0.0.0:5001" \
    GUNICORN_TIMEOUT=60 \
    GUNICORN_WORKERS=2 \
    FLASK_DEBUG=0 \
    FLASK_ENV=production

ENV GUNICORN_CMD_ARGS="--bind=${GUNICORN_BIND} --timeout=${GUNICORN_TIMEOUT} --workers=${GUNICORN_WORKERS} --access-logfile - -"

# Copy only what's necessary for the install first
COPY upstream /usr/local/amundsen/search/upstream
COPY requirements.txt /usr/local/amundsen/search/
WORKDIR /usr/local/amundsen/search/

# Install the local copy of upstream
RUN pip install upstream/ && \
    # Install the custom requirements
    pip install -r requirements.txt

# Copy the other commonly edited files
COPY configs configs/
COPY wsgi.py .

EXPOSE 5001

CMD ["gunicorn", "wsgi:app"," --timeout 1800", "--preload"]
