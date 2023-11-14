package handler

import (
	"app-reviews-proj/calculator/common"
	"fmt"
)

type Handler struct {
	calcService CalculationService
}

type CalculationService interface {
	Calculate(nums string, operator string) int
}

func NewHandler(cs CalculationService) *Handler {
	return &Handler{
		calcService: cs,
	}
}

func (h *Handler) Calculate(entry *common.Entry) int {
	h.calcService.Calculate(entry.Values, entry.Operator)
	fmt.Println(entry)
	return 0
}
