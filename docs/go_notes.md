## uber/fx

```go
// NewHTTPServer builds an HTTP server that will begin serving requests
// when the Fx application starts.
func NewHTTPServer(lc fx.Lifecycle) *http.Server {
    srv := &http.Server{Addr: ":8080"}
    return srv
}
```

This isn't enough, though - we need to tell Fx how to start the HTTP server. That's what the additional fx.Lifecycle argument is for. 
Add a lifecycle hook to the application with the fx.Lifecycle object. This tells Fx how to start and stop the HTTP server.

```go
func NewHTTPServer(lc fx.Lifecycle) *http.Server {
    srv := &http.Server{Addr: ":8080"}
    lc.Append(fx.Hook{
        OnStart: func(ctx context.Context) error {
            ln, err := net.Listen("tcp", srv.Addr)
            if err != nil {
                return err
            }
            fmt.Println("Starting HTTP server at", srv.Addr)
            go srv.Serve(ln)
                return nil
	    },
        OnStop: func(ctx context.Context) error {
            return srv.Shutdown(ctx)
        },
    })
	return srv
}
```

Provide this to your Fx application above with fx.Provide.

```go
func main() {
  fx.New(
    fx.Provide(NewHTTPServer),
  ).Run()
}
```


```go
// main.go
package main

import (
	"context"
	"fmt"
	"net/http"

	"go.uber.org/fx"
	"github.com/go-chi/chi"
)

// App is the main application struct that holds all the dependencies.
type App struct {
	fx.In

	Router *chi.Mux
	Server *http.Server
}

// HelloService is a simple service that provides a greeting.
type HelloService struct{}

func (hs *HelloService) Greet() string {
	return "Hello, World!"
}

// NewHelloHandler creates an HTTP handler that uses the HelloService.
func NewHelloHandler(hs *HelloService) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprint(w, hs.Greet())
	}
}

func main() {
	// Create an Fx application.
	app := fx.New(
		fx.Provide(chi.NewRouter),
		fx.Provide(func() *http.Server {
			return &http.Server{
				Addr:    ":8080",
				Handler: chi.NewRouter(),
			}
		}),
		fx.Provide(func(r *chi.Mux, handler http.Handler) *chi.Mux {
			r.Get("/", handler.ServeHTTP)
			return r
		}),
		fx.Provide(NewHelloHandler),
		fx.Provide(func(h http.Handler) http.Handler {
			return chi.WithBasePath(h, "/api")
		}),
		fx.Provide(func() *HelloService {
			return &HelloService{}
		}),
		fx.Invoke(func(app App) {
			fmt.Println("Server is running on :8080")
			if err := app.Server.ListenAndServe(); err != http.ErrServerClosed {
				fmt.Println("Error:", err)
			}
		}),
	)

	// Run the application.
	if err := app.Start(context.Background()); err != nil {
		fmt.Println("Error:", err)
	}

	// Shutdown the application gracefully.
	defer app.Stop(context.Background())
}
```

```go
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
	"net"
	"net/http"
	"os"
	"os/signal"
	"syscall"
)

func main() {
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
		fx.Provide(service.NewCalculationManager),
		fx.Provide(handler.NewHandler),
		fx.Provide(chi.NewRouter), // Provide chi.NewRouter
		fx.Provide(NewHTTPServer),
		fx.Provide(NewServeMux),
		fx.Invoke(runHttpServerTest), // Invoke runHttpServerTest
	)
	
	if err := app.Start(ctx); err != nil {
		fmt.Println(err)
	}

	shutdown := make(chan os.Signal, 1)
	signal.Notify(shutdown, os.Interrupt, syscall.SIGTERM)
	defer signal.Stop(shutdown)

	<-shutdown

	fmt.Println("Server stopped gracefully")
}

func runHttpServerTest(
	lc fx.Lifecycle,
	cm internal.ICalcManager,
	calcHandler internal.ICalculationHandler,
	router *chi.Mux,
) {
	router.MethodFunc(http.MethodPost, "/calc", calcHandler.Calculate)

	server := http.Server{
		Addr:    "localhost:8081",
		Handler: router,
	}
	fmt.Println("Try to start server...")

	go func() {
		fmt.Printf("Server started working on port:%s", "8081")
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

```