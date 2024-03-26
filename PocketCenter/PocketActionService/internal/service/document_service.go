package service

import (
	"fmt"
	"pocketaction/internal/model"
	"pocketaction/internal/repository"
)

type DocumentService struct {
	documentRepository *repository.AppwriteDocumentRepsitory
	pdfToImageService  *PdfToImageService
}

func NewDocumentService(
	documentRepository *repository.AppwriteDocumentRepsitory,
	pdfPdfToImageService *PdfToImageService,
) *DocumentService {
	return &DocumentService{
		documentRepository: documentRepository,
		pdfToImageService:  pdfPdfToImageService,
	}
}

func (d *DocumentService) GetActionDocument() (model.PocketActionDocument, error) {
	actions, err := d.documentRepository.GetPocketActionDocument()
	return model.PocketActionDocument{
		Actions: actions,
	}, err
}

func (d *DocumentService) GetPresentationPdfPath() (string, error) {
	pdf, err := d.documentRepository.GetPdf()
	if err != nil {
		return "", err
	}
	_, err = d.pdfToImageService.ConvertPdfToImageFolder(pdf)
	if err != nil {
		return "", err
	}
	return pdf, nil
}

func (d *DocumentService) GetPresentationZipPath(sessionId string) (string, error) {
	pdf, err := d.documentRepository.GetZip()
	if err != nil {
		return "", err
	}
	fmt.Println(pdf)
	_, err = d.pdfToImageService.ConvertZipToImageFolder(pdf, sessionId)
	if err != nil {
		return "", err
	}
	return pdf, nil
}
