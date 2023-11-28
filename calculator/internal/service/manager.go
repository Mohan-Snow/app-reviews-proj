package service

import "app-reviews-proj/calculator/internal"

type calcManager struct {
	add      internal.CalculationService // убираем логику инициализации
	divide   internal.CalculationService
	multiply internal.CalculationService
	subtract internal.CalculationService
}

func NewCalculationManager(
	add internal.AddCalculationService,
	divide internal.DivideCalculationService,
	multiply internal.MultiplyCalculationService,
	subtract internal.SubtractCalculationService,
) internal.ICalcManager {
	return calcManager{
		add:      add,
		divide:   divide,
		multiply: multiply,
		subtract: subtract,
	}
}

func (c calcManager) ManageCalculation(operation internal.OperationType) internal.CalculationService {
	switch operation {
	case internal.AddOperationType:
		return c.add
	case internal.DivideOperationType:
		return c.divide
	case internal.MultiplicationOperationType:
		return c.multiply
	case internal.SubtractionOperationType:
		return c.subtract
	default:
		panic("Not Implemented!!")
	}
}
