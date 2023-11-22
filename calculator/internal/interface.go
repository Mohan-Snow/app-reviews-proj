package internal

import (
	"net/http"
)

type OperationType string

const AddOperationType OperationType = "add"
const DivideOperationType OperationType = "divide"
const MultiplicationOperationType OperationType = "multiply"
const SubtractionOperationType OperationType = "subtract"

type CalculationService interface {
	Calc(a int, b int) int
}

type AddCalculationService interface {
	CalculationService
}

type DivideCalculationService interface {
	CalculationService
}

type ICalcManager interface {
	ManageCalculation(operation OperationType) CalculationService
}

type ICalculationHandler interface {
	Calculate(writer http.ResponseWriter, request *http.Request)
}
