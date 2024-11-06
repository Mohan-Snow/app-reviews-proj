# Используем официальный образ Go 1.22.1 для сборки
FROM golang:1.22.1-alpine as builder

# Устанавливаем рабочую директорию
WORKDIR /app

# Копируем go.mod и go.sum для кеширования зависимостей
COPY go.mod go.sum ./

# Скачиваем зависимости
RUN go mod tidy

# Копируем исходный код в контейнер
COPY . .

# Собираем бинарный файл
RUN GOOS=linux GOARCH=amd64 go build -o /bin/app cmd/app/*.go

# Используем минимальный образ Alpine для финального контейнера
FROM alpine:latest

# Устанавливаем необходимые библиотеки для работы с Go приложением
RUN apk --no-cache add ca-certificates

# Копируем собранный бинарный файл из стадии сборки
COPY --from=builder /bin/app /bin/app

# Открываем порт (например, 8080 для веб-сервиса)
EXPOSE 8080

# Указываем команду для запуска приложения
CMD ["/bin/app"]
