package main

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"net/http"
	"os"
	"os/signal"
	"syscall"

	_ "github.com/lib/pq"
	"github.com/pressly/goose"

	"github.com/go-chi/chi/v5"
	log "github.com/sirupsen/logrus"
	"go.uber.org/fx"

	"app-reviews-proj/internal"
	"app-reviews-proj/internal/handler"
	"app-reviews-proj/internal/model"
	"app-reviews-proj/internal/service"
)

// /cmd
// Не стоит располагать в этой директории большие объёмы кода.
// Если вы предполагаете дальнейшее использование кода в других проектах, вам стоит хранить его в директории /pkg в корне проекта.
// Если же код не должен быть переиспользован где-то еще - ему самое место в директории /internal в корне проекта.

// Самой распространённой практикой является использование маленькой main функции,
// которая импортирует и вызывает весь необходимый код из директорий /internal и /pkg, но не из других.

func main() {
	//ao := service.NewAddOperation()
	//do := service.NewDivideOperation()
	//mo := service.NewMultiplyOperation()
	//so := service.NewSubtractOperation())
	//cm := service.NewCalculationManager(ao, do)

	ctx, cancel := context.WithCancel(context.Background())

	// Получаем значения переменных окружения
	dbHost := os.Getenv("DB_HOST")
	dbPort := os.Getenv("DB_PORT")
	dbUser := os.Getenv("DB_USER")
	dbPassword := os.Getenv("DB_PASSWORD")
	dbName := os.Getenv("DB_NAME")

	// Если переменные окружения не заданы, выводим сообщение об ошибке
	if dbHost == "" || dbPort == "" || dbUser == "" || dbPassword == "" || dbName == "" {
		log.Fatal("Missing environment variables")
	}

	fmt.Printf("Connecting to database %s at %s:%s as user %s with password %s\n", dbName, dbHost, dbPort, dbUser, dbPassword)

	connString := fmt.Sprintf("host=%s port=%s user=%s password=%s dbname=%s sslmode=disable",
		dbHost, dbPort, dbUser, dbPassword, dbName)

	db, err := sql.Open("postgres", connString)
	if err != nil {
		log.Println("Database initializing error")
		log.Fatal(err)
	}
	defer db.Close()
	err = db.Ping()
	if err != nil {
		log.Println("Database ping error")
		log.Fatal(err)
	}

	if err := goose.Up(db, "./db-migration"); err != nil {
		log.Fatalf("migration failed; %v", err)
	}

	kill := make(chan os.Signal, 1)
	signal.Notify(kill)

	go func() {
		<-kill
		cancel()
	}()

	app := fx.New(
		fx.Provide(model.NewAddOperation),
		fx.Provide(model.NewDivideOperation),
		fx.Provide(model.NewMultiplyOperation),
		fx.Provide(model.NewSubtractOperation),
		fx.Provide(service.NewCalculationManager),
		fx.Provide(handler.NewHandler),
		fx.Provide(chi.NewRouter),
		fx.Invoke(startHttpServer),
		//fx.Invoke(runHttpServer),
	)
	app.Run()
	if err := app.Start(ctx); err != nil {
		fmt.Println(err)
	}

	shutdown := make(chan os.Signal, 1)
	signal.Notify(shutdown, os.Interrupt, syscall.SIGTERM)
	defer signal.Stop(shutdown)

	<-shutdown

	fmt.Println("Server stopped gracefully")
}

func startHttpServer(
	lc fx.Lifecycle,
	calcHandler internal.ICalculationHandler,
	router *chi.Mux,
) {
	router.MethodFunc(http.MethodPost, "/calc", calcHandler.Calculate)

	server := http.Server{
		Addr:    "localhost:8080",
		Handler: router,
	}
	fmt.Println("Try to start server...")
	lc.Append(fx.Hook{
		OnStart: func(ctx context.Context) error {
			go func() {
				fmt.Printf("Running server on port:%s", server.Addr)
				err := server.ListenAndServe()
				if err != nil && !errors.Is(err, http.ErrServerClosed) {
					fmt.Println(err)
				}
			}()
			return nil
		},
		OnStop: func(ctx context.Context) error {
			return server.Shutdown(ctx)
		},
	})
}

// alternative http-server runner
func runHttpServer(
	lc fx.Lifecycle,
	calcHandler internal.ICalculationHandler,
	router *chi.Mux,
) {
	router.MethodFunc(http.MethodPost, "/calc", calcHandler.Calculate)

	server := http.Server{
		Addr:    "localhost:8080",
		Handler: router,
	}
	fmt.Println("Try to start server...")

	go func() {
		fmt.Printf("Running server on port:%s", server.Addr)
		err := server.ListenAndServe()
		if err != nil && !errors.Is(err, http.ErrServerClosed) {
			fmt.Println(err)
		}
	}()

	lc.Append(fx.Hook{
		OnStop: func(ctx context.Context) error {
			return server.Shutdown(ctx)
		},
	})
}
