package service

import "app-reviews-proj/calculator/internal"

type addOperation struct{}

func NewAddOperation() internal.AddCalculationService { // тут возвращение копии
	return addOperation{}
}

func (ao addOperation) Calc(a int, b int) int {
	return a + b
}
