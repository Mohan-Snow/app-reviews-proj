package serializer

import "encoding/json"

type JsonSerializer struct {
}

func NewJsonSerializer() *JsonSerializer {
	result := &JsonSerializer{}
	return result
}

func (serializer *JsonSerializer) Serialize(object interface{}) ([]byte, error) {
	return json.Marshal(object)
}

func (serializer *JsonSerializer) Deserialize(data []byte, dest interface{}) error {
	return json.Unmarshal(data, dest)
}
