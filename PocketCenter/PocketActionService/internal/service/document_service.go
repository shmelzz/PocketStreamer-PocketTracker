package service

import (
	"pocketaction/internal/model"
	"pocketaction/internal/repository"
)

type DocumentService struct {
	documentRepository *repository.AppwriteDocumentRepsitory
}

func NewDocumentService(documentRepository *repository.AppwriteDocumentRepsitory) *DocumentService {
	return &DocumentService{
		documentRepository: documentRepository,
	}
}

func (d *DocumentService) GetActionDocument() (model.PocketActionDocument, error) {
	actions, err := d.documentRepository.GetPocketActionDocument()
	return model.PocketActionDocument{
		Actions: actions,
	}, err
}
