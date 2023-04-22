FROM python:3.11-alpine3.17
LABEL maintainer="josemasri"

ENV PYTHONUNBUFFERED 1

RUN apk add --no-cache \
    build-base \
    postgresql-dev \
    postgresql-client \
    musl-dev \
    bash \
    && rm -rf /var/cache/apk/*

COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app

WORKDIR /app
EXPOSE 8000

ARG DEV=false

RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ "$DEV" = "true" ]; then \
        /py/bin/pip install -r /tmp/requirements.dev.txt; \
    fi && \
    rm -rf /tmp/requirements.txt && \
    adduser \
        --disabled-password \
        --no-create-home \
        "django-user"

ENV PATH="/py/bin:$PATH"

# Copy wait-for-it.sh to a executable path
COPY ./wait-for-it.sh /usr/local/bin/wait-for-it.sh

USER django-user
