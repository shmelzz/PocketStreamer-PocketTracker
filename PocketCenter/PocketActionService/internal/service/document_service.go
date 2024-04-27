package service

import (
	"fmt"
	"pocketaction/internal/model"
	"pocketaction/internal/repository"

	"go.uber.org/zap"
)

type DocumentService struct {
	documentRepository *repository.AppwriteDocumentRepsitory
	pdfToImageService  *PdfToImageService
	logger             *zap.Logger
}

func NewDocumentService(
	documentRepository *repository.AppwriteDocumentRepsitory,
	pdfPdfToImageService *PdfToImageService,
	zapLogger *zap.Logger,
) *DocumentService {
	return &DocumentService{
		documentRepository: documentRepository,
		pdfToImageService:  pdfPdfToImageService,
		logger:             zapLogger,
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
	zipPath, err := d.documentRepository.GetZip()
	if err != nil {
		return "", err
	}
	fmt.Println(zipPath)
	imageExtension, err := d.pdfToImageService.ConvertZipToImageFolder(zipPath, sessionId)
	if err != nil {
		return "", err
	}
	return imageExtension, nil
}
