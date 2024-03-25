package service

import (
	"fmt"
	"pocketaction/internal/util"

	"gopkg.in/gographics/imagick.v3/imagick"
)

type PdfToImageService struct {
}

func NewPdfToImageService() *PdfToImageService {
	return &PdfToImageService{}
}

func (p *PdfToImageService) ConvertPdfToImageFolder(pdfPath string) (string, error) {
	imagick.Initialize()
	defer imagick.Terminate()

	mw := imagick.NewMagickWand()
	defer mw.Destroy()

	err := mw.ReadImage(pdfPath)
	if err != nil {
		return "", err
	}
	folderPath := "./presentation/1"
	// err = util.RemoveAllContents("./presentation")
	// if err != nil {
	// 	return "", err
	// }
	err = util.CreateFolder(folderPath)
	if err != nil {
		return "", err
	}
	numPages := mw.GetNumberImages()
	for i := 0; i < int(numPages); i++ {
		mw.SetIteratorIndex(i) // Set the page index
		mw.SetImageFormat("jpg")
		outputPath := fmt.Sprintf("%s/%d.jpg", folderPath, i+1)
		err := mw.WriteImage(outputPath)
		if err != nil {
			return "", err
		}
	}

	return folderPath, nil
}
