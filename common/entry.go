package common

type Entry struct {
	Values   []int
	Operator OperationType // common не должен зависить от internal
}
