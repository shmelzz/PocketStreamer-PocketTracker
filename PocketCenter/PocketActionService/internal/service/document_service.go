package service

import (
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

func (d *DocumentService) GetPresentationPath() (string, error) {
	pdf, err := d.documentRepository.GetPdfs()
	d.pdfToImageService.ConvertPdfToImageFolder(pdf)
	if err != nil {
		return "", nil
	}
	return pdf, nil
}
