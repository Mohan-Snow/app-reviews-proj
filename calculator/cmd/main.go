package main

import (
	"app-reviews-proj/calculator/handler"
	"app-reviews-proj/calculator/internal"
	"app-reviews-proj/calculator/internal/service"
	"context"
	"errors"
	"fmt"
	"github.com/go-chi/chi/v5"
	"go.uber.org/fx"
	"net/http"
	"os"
	"os/signal"
	"syscall"
)

// добавить конфиг в файл conf с конфгурациями
// подключить линтер, поправить ошибки

func main() {
	//ao := service.NewAddOperation()
	//do := service.NewDivideOperation()
	//mo := service.NewMultiplyOperation()
	//so := service.NewSubtractOperation())
	//cm := service.NewCalculationManager(ao, do)

	ctx, cancel := context.WithCancel(context.Background())
	kill := make(chan os.Signal, 1)
	signal.Notify(kill)

	go func() {
		<-kill
		cancel()
	}()

	app := fx.New(
		fx.Provide(service.NewAddOperation),
		fx.Provide(service.NewDivideOperation),
		fx.Provide(service.NewMultiplyOperation),
		fx.Provide(service.NewSubtractOperation),
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
