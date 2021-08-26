# This Dockerfile is essentially a tweaked version of
# https://github.com/amundsen-io/amundsen/blob/frontend-3.12.0/Dockerfile.frontend.public 
FROM node:12-slim as node-stage
WORKDIR /app/amundsen_application/static

COPY amundsen/frontend/amundsen_application/static/package.json /app/amundsen_application/static/package.json
COPY amundsen/frontend/amundsen_application/static/package-lock.json /app/amundsen_application/static/package-lock.json
RUN npm install

COPY amundsen/frontend/amundsen_application/static /app/amundsen_application/static
# copy config-custom.ts, we modified it to enable table lineage, indexing users and dashboards
COPY frontend/static /app/amundsen_application/static
RUN npm run build

FROM python:3.7-slim as base
WORKDIR /app
RUN pip3 install gunicorn

COPY --from=node-stage /app /app
COPY amundsen/frontend /app
COPY amundsen/requirements-dev.txt /app/requirements-dev.txt
COPY amundsen/requirements-common.txt /app/requirements-common.txt
RUN pip3 install -e .

# copy and install any custom requirments we might have
COPY frontend/requirements.txt /app/requirements-custom.txt
RUN pip3 install -r requirements-custom.txt

# we would also need to copy frontend/wsgi.py, frontend/configs/__init__.py and frontend/configs/config.py into
# /app/amundsen_applications/ if we were to make any custom change to them.

CMD [ "python3",  "amundsen_application/wsgi.py" ]

FROM base as oidc-release

RUN pip3 install -e .[oidc]
ENV FRONTEND_SVC_CONFIG_MODULE_CLASS amundsen_application.oidc_config.OidcConfig
ENV APP_WRAPPER flaskoidc
ENV APP_WRAPPER_CLASS FlaskOIDC
ENV FLASK_OIDC_WHITELISTED_ENDPOINTS status,healthcheck,health
ENV SQLALCHEMY_DATABASE_URI sqlite:///sessions.db

# You will need to set these environment variables in order to use the oidc image
# FLASK_OIDC_CONFIG_URL - url endpoint for your oidc provider config
# FLASK_OIDC_PROVIDER_NAME - oidc provider name
# FLASK_OIDC_CLIENT_ID - oidc client id
# FLASK_OIDC_CLIENT_SECRET - oidc client secret

FROM base as release
