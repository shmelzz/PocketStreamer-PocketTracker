package service

import (
	"archive/zip"
	"fmt"
	"image"
	"image/jpeg"
	"io"
	"os"
	"path/filepath"
	"pocketaction/internal/util"
	"sort"
	"strconv"
	"strings"

	"github.com/nfnt/resize"
	"go.uber.org/zap"
	"gopkg.in/gographics/imagick.v3/imagick"
)

type PdfToImageService struct {
	logger *zap.Logger
}

func NewPdfToImageService(zapLogger *zap.Logger) *PdfToImageService {
	return &PdfToImageService{
		logger: zapLogger,
	}
}

func (p *PdfToImageService) ConvertZipToImageFolder(zipPath string, sessionId string) (string, error) {
	destFolder := fmt.Sprintf("./presentation/%s", sessionId)

	ok, err := util.CreateIfNotExistFolder(destFolder)

	if !ok {
		err := util.RemoveAllContents(destFolder)
		if err != nil {
			return "", err
		}
	}
	if err != nil {
		return "", err
	}
	archive, err := zip.OpenReader(zipPath)
	if err != nil {
		return "", err
	}
	defer archive.Close()

	// Ensure the destination folder exists
	if err := os.MkdirAll(destFolder, os.ModePerm); err != nil {
		return "", err
	}
	// Iterate through each file in the zip archive
	sort.Slice(archive.File, func(i, j int) bool {
		return archive.File[i].FileInfo().Name() < archive.File[j].FileInfo().Name()
	})
	index := 1
	imageExt := ".jpeg"
	for _, f := range archive.File {
		if !strings.HasSuffix(f.FileInfo().Name(), ".jpg") &&
			!strings.HasSuffix(f.FileInfo().Name(), ".jpeg") &&
			!strings.HasSuffix(f.FileInfo().Name(), ".png") {
			continue
		}

		if strings.HasPrefix(f.FileInfo().Name(), "._") || f.FileInfo().IsDir() {
			continue
		}
		imageExt = filepath.Ext(f.FileInfo().Name())
		filePath := filepath.Join(destFolder, strconv.Itoa(index)+imageExt)
		index++
		// Check for ZipSlip vulnerability
		if !strings.HasPrefix(filePath, filepath.Clean(destFolder)+string(os.PathSeparator)) {
			return "", fmt.Errorf("%s: illegal file path", filePath)
		}

		// Create directories if necessary
		if f.FileInfo().IsDir() {
			os.MkdirAll(filePath, os.ModePerm)
			continue
		}

		// Create the file
		dstFile, err := os.OpenFile(filePath, os.O_WRONLY|os.O_CREATE|os.O_TRUNC, f.Mode())
		if err != nil {
			return "", err
		}

		// Copy the file from the zip archive to the destination
		fileInArchive, err := f.Open()
		if err != nil {
			dstFile.Close()
			return "", err
		}

		stretchImage(fileInArchive, dstFile)

		if _, err := io.Copy(dstFile, fileInArchive); err != nil {
			fileInArchive.Close()
			dstFile.Close()
			return "", err
		}

		fileInArchive.Close()
		dstFile.Close()
	}

	return imageExt, nil
}

func stretchImage(input io.ReadCloser, dstFile *os.File) error {
	// Decode the image from the input
	img, _, err := image.Decode(input)
	if err != nil {
		return fmt.Errorf("failed to decode image: %v", err)
	}

	// Calculate the new dimensions
	bounds := img.Bounds()
	newWidth := int(float64(bounds.Dx()) * 1.097)
	newHeight := bounds.Dy()

	resizedImg := resize.Resize(uint(newWidth), uint(newHeight), img, resize.Lanczos3)

	// Create a new image with the new dimensions
	err = jpeg.Encode(dstFile, resizedImg, nil)
	if err != nil {
		return fmt.Errorf("failed to encode image: %v", err)
	}

	return nil
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
	err = util.RemoveAllContents("./presentation")
	if err != nil {
		return "", err
	}
	_, err = util.CreateIfNotExistFolder(folderPath)
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
