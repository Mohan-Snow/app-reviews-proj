package main

import (
	"app-reviews-proj/calculator/internal"
	"app-reviews-proj/calculator/internal/service"
	"context"
	"github.com/ErezLevip/fx-medium-example/handlers"
	log "github.com/sirupsen/logrus"
	"github.com/valyala/fasthttp"
	"github.com/valyala/fasthttprouter"
	"go.uber.org/fx"
	"net/http"
)

// добавить handler package (туда добавить хэндлеры (Х4) для каждого типа операции) в internal
// дописать запуск с uber/fx
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
		),
		fx.Invoke(runCalculation),
	)
	app.Run()

	//ctx, cancel := context.WithCancel(context.Background())
	//kill := make(chan os.Signal, 1)
	//signal.Notify(kill)

	//go func() {
	//	<-kill
	//	cancel()
	//}()

	//if err := app.Start(ctx); err != nil {
	//	fmt.Println(err)
	//}

	//jsonSerializer := serializer.NewJsonSerializer()
	//handler.NewHandler()
	//router := chi.NewRouter()
	//router.Post("/calc", Calculate)
	//router.MethodFunc(http.MethodPost, "/calc/add", )

	//err := http.ListenAndServe(":8081", nil)
	//if err != nil {
	//	log.Error(err)
	//}
}

func runCalculation(cm internal.ICalcManager) {
	log.Print(cm.CalculationManager(internal.AddOperationType).Calc(1, 2))
	log.Print(cm.CalculationManager(internal.DivideOperationType).Calc(2, 4))
}

func runHttpServer(lifecycle fx.Lifecycle, molHandler *handlers.MeaningOfLife) {
	lifecycle.Append(fx.Hook{OnStart: func(context.Context) error {
		r := fasthttprouter.New()
		r.Handle(http.MethodGet, "/calc", molHandler.Handle)
		return fasthttp.ListenAndServe("localhost:8080", r.Handler)
	}})
}
