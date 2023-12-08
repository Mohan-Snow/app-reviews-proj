package model

import (
	"app-reviews-proj/calculator/internal"
)

type divideOperation struct {
}

func NewDivideOperation() internal.DivideCalculationService {
	return divideOperation{}
}

func (do divideOperation) Calc(a int, b int) int {
	return a / b
}
