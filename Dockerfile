FROM python:3.10-alpine

RUN addgroup -g 1001 app \
    && adduser -u 1001 -S -D -G app -s /usr/sbin/nologin app

ENV LANG C.UTF-8

WORKDIR /app

# install syncserver dependencies
COPY ./requirements.txt /app/requirements.txt

# install the base set of libraries if they're not present.
## `gcc musl-dev libffi-dev` are needed for building (not running) cffi in arm64 only
## until cffi provides a prebuilt wheel for musl-arm64.
## cffi is required by cryptography which is required by PyFxA
RUN apk --no-cache update \
    && apk --no-cache add bash dumb-init gcc musl-dev libffi-dev \
    && pip install --upgrade pip \
    && pip install --upgrade --no-cache-dir -r requirements.txt \
    && apk --no-cache del gcc musl-dev libffi-dev

COPY . /app

# run as non priviledged user
USER app

# run the server by default
ENTRYPOINT ["/usr/bin/dumb-init", "/app/docker-entrypoint.sh"]
CMD ["server"]
