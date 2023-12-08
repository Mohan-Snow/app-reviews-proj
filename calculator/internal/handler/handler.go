package handler

import (
	"app-reviews-proj/calculator/common"
	"app-reviews-proj/calculator/internal"
	"app-reviews-proj/calculator/internal/serilizer"
	"encoding/json"
	"fmt"
	log "github.com/sirupsen/logrus"
	"io/ioutil"
	"net/http"
)

type Handler struct {
	calcManager internal.ICalcManager
}

type CalculationService interface {
	Calculate(nums string, operator string) int
}

func NewHandler(calcManager internal.ICalcManager) internal.ICalculationHandler {
	return &Handler{
		calcManager: calcManager,
	}
}

func (h *Handler) Calculate(writer http.ResponseWriter, request *http.Request) {
	fmt.Println("Calculate...")
	jsonSerializer := serializer.NewJsonSerializer()
	body, err := ioutil.ReadAll(request.Body)
	if err != nil {
		log.Error(err)
		writer.WriteHeader(500)
		_, err := writer.Write([]byte("Internal error"))
		if err != nil {
			log.Error(err)
		}
		return
	}

	var entry = &common.Entry{}
	err = jsonSerializer.Deserialize(body, entry)
	if err != nil {
		log.Error(err)
		writer.WriteHeader(500)
		_, err := writer.Write([]byte("Internal error"))
		if err != nil {
			log.Error(err)
		}
		return
	}
	log.Info(string(body))
	val := h.calcManager.ManageCalculation(entry.Operator).Calc(entry.Values[0], entry.Values[1])
	writeResponse(writer, http.StatusOK, val)
}

func writeResponse(writer http.ResponseWriter, code int, v interface{}) {
	body, _ := json.Marshal(v)
	writer.WriteHeader(code)
	_, err := writer.Write(body)
	if err != nil {
		fmt.Print(err)
	}
}
