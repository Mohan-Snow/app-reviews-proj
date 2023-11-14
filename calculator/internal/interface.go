package internal

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
	CalculationManager(operation OperationType) CalculationService
}
