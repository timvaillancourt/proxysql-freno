FROM golang:1.14-alpine

COPY main.go /go/src/github.com/timvaillancourt/proxysql-testbed/main.go
COPY go.mod /go/src/github.com/timvaillancourt/proxysql-testbed/go.mod
COPY go.sum /go/src/github.com/timvaillancourt/proxysql-testbed/go.sum

WORKDIR /go/src/github.com/timvaillancourt/proxysql-testbed
RUN go build -o /app main.go

ENTRYPOINT ["/app"]
