FROM golang:alpine as builder


RUN apk add --no-cache git=~2.26.2

RUN mkdir /app
WORKDIR /app

# ENV GO111MODULE=on
ARG app_env
ARG app_port


ENV APP_ENV $app_env
ENV APP_PORT $app_port

COPY assets /app/assets
COPY main.go /app
COPY go.mod   /app


RUN go mod download
RUN go get
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o web-app-$app_env


# Run container
FROM alpine:3.12.0
ARG app_env
ARG app_port

ENV APP_ENV $app_env
ENV APP_PORT $app_port

RUN apk --no-cache add ca-certificates=~20191127

RUN mkdir /app
WORKDIR /app
COPY assets /app/assets

COPY --from=builder /app/web-app-$app_env .
COPY --from=builder /app/assets .


RUN ln -s /app/web-app-$app_env /app/docker_entrypoint.sh

CMD ["/app/docker_entrypoint.sh"]

EXPOSE $app_port
