package util

import (
	"fmt"
	"os"
	"reflect"
	"strconv"
)

func CreateIfExistFolder(folderName string) error {
	if _, err := os.Stat(folderName); os.IsNotExist(err) {
		err := os.Mkdir(folderName, os.ModePerm)
		return err
	}
	return fmt.Errorf("Folder exist")
}

func RemoveAllContents(folderPath string) error {
	// Use os.RemoveAll to delete all contents of the folder.
	err := os.RemoveAll(folderPath)
	if err != nil {
		return fmt.Errorf("failed to remove all contents of %s: %w", folderPath, err)
	}
	return CreateIfExistFolder(folderPath)
}

// ToString changes arg to string
func ToString(arg interface{}) string {
	var tmp = reflect.Indirect(reflect.ValueOf(arg)).Interface()
	switch v := tmp.(type) {
	case int:
		return strconv.Itoa(v)
	case int8:
		return strconv.FormatInt(int64(v), 10)
	case int16:
		return strconv.FormatInt(int64(v), 10)
	case int32:
		return strconv.FormatInt(int64(v), 10)
	case int64:
		return strconv.FormatInt(v, 10)
	case string:
		return v
	case float32:
		return strconv.FormatFloat(float64(v), 'f', -1, 32)
	case float64:
		return strconv.FormatFloat(v, 'f', -1, 64)
	case fmt.Stringer:
		return v.String()
	case reflect.Value:
		return ToString(v.Interface())
	default:
		return ""
	}
}
