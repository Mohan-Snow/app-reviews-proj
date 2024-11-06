package internal

import (
	"net/http"

	"app-reviews-proj/common"
)

const AddOperationType common.OperationType = "add"
const DivideOperationType common.OperationType = "divide"
const MultiplicationOperationType common.OperationType = "multiply"
const SubtractionOperationType common.OperationType = "subtract"

type CalculationService interface {
	Calc(a int, b int) int
}

type AddCalculationService interface {
	CalculationService
}

type DivideCalculationService interface {
	CalculationService
}

type MultiplyCalculationService interface {
	CalculationService
}
type SubtractCalculationService interface {
	CalculationService
}

type ICalcManager interface {
	ManageCalculation(operation common.OperationType) CalculationService
}

type ICalculationHandler interface {
	Calculate(writer http.ResponseWriter, request *http.Request)
}
