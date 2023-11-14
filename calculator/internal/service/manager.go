package service

import "app-reviews-proj/calculator/internal"

type calcManager struct {
	add    internal.CalculationService // убираем логику инициализации
	divide internal.CalculationService
}

func NewCalculationManager(add internal.AddCalculationService, divide internal.DivideCalculationService) internal.ICalcManager {
	return calcManager{
		add:    add,
		divide: divide,
	}
}

func (c calcManager) CalculationManager(operation internal.OperationType) internal.CalculationService {
	switch operation {
	case internal.AddOperationType:
		return c.add
	case internal.DivideOperationType:
		return c.divide
	case internal.MultiplicationOperationType:
		fallthrough
	case internal.SubtractionOperationType:
		fallthrough
	default:
		panic("Not Implemented!!")
	}
}
