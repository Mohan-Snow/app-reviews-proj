# Используем официальный образ Go 1.22.1 для сборки
FROM golang:1.22.1-alpine as builder

# Устанавливаем утилиту goose
RUN go install github.com/pressly/goose/cmd/goose@latest

# Устанавливаем рабочую директорию
WORKDIR /app

# Копируем go.mod и go.sum
COPY go.mod go.sum ./

# Обновляем зависимости
RUN go mod tidy

# Копируем исходный код в контейнер
COPY . .

# Копируем директорию с миграциями в контейнер
COPY ./db-migration /db-migration

# Собираем бинарный файл
RUN GOOS=linux GOARCH=amd64 go build -o /bin/app cmd/app/*.go

# Используем минимальный образ Alpine для финального контейнера
FROM alpine:latest

# Устанавливаем необходимые библиотеки для работы с Go приложением
RUN apk --no-cache add ca-certificates

# Копируем собранный бинарный файл из стадии сборки
COPY --from=builder /bin/app /bin/app

# Копируем утилиту goose из стадии сборки
COPY --from=builder /go/bin/goose /go/bin/goose

# Добавляем /go/bin в PATH, чтобы утилита goose была доступна
ENV PATH=$PATH:/go/bin

# Копируем директорию с миграциями в контейнер
COPY --from=builder /db-migration /db-migration

# Открываем порт
EXPOSE 8080

# Указываем команду для запуска приложения
CMD ["/bin/app"]
