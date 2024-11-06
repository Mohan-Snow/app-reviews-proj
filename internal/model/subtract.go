package model

import (
	"app-reviews-proj/internal"
)

type subtractOperation struct{}

func NewSubtractOperation() internal.SubtractCalculationService {
	return subtractOperation{}
}

func (so subtractOperation) Calc(a int, b int) int {
	return a / b
}
