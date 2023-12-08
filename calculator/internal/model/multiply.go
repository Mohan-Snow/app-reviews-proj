package model

import "app-reviews-proj/calculator/internal"

type multiplyOperation struct {
}

func NewMultiplyOperation() internal.MultiplyCalculationService {
	return multiplyOperation{}
}

func (mo multiplyOperation) Calc(a int, b int) int {
	return a * b
}
