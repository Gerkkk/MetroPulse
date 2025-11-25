FROM golang:1.23

WORKDIR /app

COPY . .

WORKDIR /app/generator
RUN go mod download
RUN go build -o gotype ./cmd

CMD ["./gotype"]