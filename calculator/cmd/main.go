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
	"time"
)

// добавить handler package (туда добавить хэндлеры (Х4) для каждого типа операции) в internal
// добавить конфиг в файл conf с конфгурациями
// подключить линтер, поправить ошибки

func main() {
	//ao := service.NewAddOperation()
	//do := service.NewDivideOperation()
	//cm := service.NewCalculationManager(ao, do)

	app := fx.New(
		fx.Provide(
			service.NewAddOperation,
			service.NewDivideOperation,
			service.NewCalculationManager,
			handler.NewHandler,
			chi.NewRouter,
		),
		//fx.Invoke(runCalculation),
	)
	app.Run()

	//ch := internal.ICalculationHandler
	var ch internal.ICalculationHandler
	//router := *chi.Mux
	var router *chi.Mux

	router.Route("/", func(subRouter chi.Router) {
		subRouter.MethodFunc(http.MethodPost, "/calc", ch.Calculate)
	})

	server := http.Server{
		Addr:    "localhost:8081",
		Handler: router,
	}
	fmt.Println("Try to start server...")

	shutdown := make(chan os.Signal, 1)
	signal.Notify(shutdown, os.Interrupt, syscall.SIGTERM)
	defer signal.Stop(shutdown)

	go func() {
		fmt.Printf("Server started working on port:%s", "8081")
		err := server.ListenAndServe()
		if err != nil && !errors.Is(err, http.ErrServerClosed) {
			fmt.Println(err)
		}
	}()

	<-shutdown

	fmt.Println("Shutdown signal received")

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Minute)
	defer func() {
		cancel()
	}()

	if err := app.Start(ctx); err != nil {
		fmt.Println(err)
	}

	if err := server.Shutdown(ctx); err != nil {
		fmt.Println(err)
	}
	fmt.Println("Server stopped gracefully")
}

//func runCalculation(cm internal.ICalcManager, ch internal.ICalculationHandler, router *chi.Mux) {
//	log.Print(cm.ManageCalculation(internal.AddOperationType).Calc(1, 2))
//	log.Print(cm.ManageCalculation(internal.DivideOperationType).Calc(2, 4))
//	router.MethodFunc(http.MethodPost, "/calc", ch.Calculate)
//}
