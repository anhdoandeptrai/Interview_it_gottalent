import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfService {
  // Validate PDF file before processing
  Future<Map<String, dynamic>> validatePdfFile(File pdfFile) async {
    Map<String, dynamic> result = {
      'isValid': false,
      'error': null,
      'fileSize': 0,
      'canRead': false,
    };

    try {
      // Check if file exists
      if (!await pdfFile.exists()) {
        result['error'] = 'PDF file does not exist';
        return result;
      }

      // Check file size (max 50MB)
      int fileSize = await pdfFile.length();
      result['fileSize'] = fileSize;

      if (fileSize > 50 * 1024 * 1024) {
        result['error'] = 'PDF file is too large (max 50MB)';
        return result;
      }

      if (fileSize == 0) {
        result['error'] = 'PDF file is empty';
        return result;
      }

      // Try to read the file as PDF
      try {
        final bytes = await pdfFile.readAsBytes();
        final document = PdfDocument(inputBytes: bytes);

        // Check if it has pages
        if (document.pages.count == 0) {
          document.dispose();
          result['error'] = 'PDF file has no pages';
          return result;
        }

        document.dispose();
        result['canRead'] = true;
        result['isValid'] = true;
      } catch (pdfError) {
        result['error'] = 'Invalid PDF format or corrupted file';
        return result;
      }
    } catch (e) {
      result['error'] = 'Error accessing PDF file: $e';
    }

    return result;
  }

  // Extract text from PDF file with enhanced error handling
  // Now runs in separate isolate to prevent UI blocking
  Future<Map<String, dynamic>> extractTextFromPdf(File pdfFile) async {
    Map<String, dynamic> result = {
      'success': false,
      'text': '',
      'error': null,
      'pageCount': 0,
      'wordCount': 0,
    };

    try {
      print('PDF Service: Starting text extraction from ${pdfFile.path}');

      // Validate PDF first
      final validation = await validatePdfFile(pdfFile);
      if (!validation['isValid']) {
        result['error'] = validation['error'];
        print('PDF Service: Validation failed - ${result['error']}');
        return result;
      }

      print(
          'PDF Service: PDF validation passed, file size: ${validation['fileSize']} bytes');

      // Run PDF extraction in separate isolate to prevent blocking UI
      try {
        final bytes = await pdfFile.readAsBytes();
        final fileSize = bytes.length;

        print(
            'PDF Service: File read into memory (${(fileSize / 1024).toStringAsFixed(2)} KB), starting extraction in isolate...');

        // Safety check: If file > 10MB, warn but continue
        if (fileSize > 10 * 1024 * 1024) {
          print(
              'PDF Service: WARNING - Large file detected (${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB), extraction may take longer...');
        }

        // Use compute to run in separate isolate
        final extractedData = await compute(_extractTextInIsolate, bytes);

        print('PDF Service: Extraction completed in isolate');

        if (extractedData['error'] != null) {
          result['error'] = extractedData['error'];
          print('PDF Service: Extraction error - ${result['error']}');
          return result;
        }

        String extractedText = extractedData['text'] ?? '';
        result['pageCount'] = extractedData['pageCount'] ?? 0;

        // Clean and validate extracted text
        extractedText = cleanExtractedText(extractedText);

        if (extractedText.trim().isEmpty) {
          result['error'] = 'No text found in PDF file';
          print('PDF Service: No text content extracted');
          return result;
        }

        result['text'] = extractedText;
        result['wordCount'] = extractedText.split(RegExp(r'\s+')).length;
        result['success'] = true;

        print(
            'PDF Service: Text extraction successful - ${result['wordCount']} words extracted');

        return result;
      } catch (e) {
        print('PDF Service: Error during extraction: $e');
        result['error'] = 'Failed to extract text: $e';
        return result;
      }
    } catch (e) {
      print('PDF Service: Error extracting text from PDF: $e');
      result['error'] = 'Failed to extract text from PDF: $e';
      return result;
    }
  }

  // Static method to run in isolate
  static Map<String, dynamic> _extractTextInIsolate(List<int> bytes) {
    try {
      print('Isolate: Loading PDF document...');
      final PdfDocument document = PdfDocument(inputBytes: bytes);

      print('Isolate: PDF loaded, page count: ${document.pages.count}');

      // Create a text extractor
      final PdfTextExtractor extractor = PdfTextExtractor(document);

      // Extract text from all pages
      print('Isolate: Extracting text...');
      String extractedText = extractor.extractText();

      final result = {
        'text': extractedText,
        'pageCount': document.pages.count,
        'error': null,
      };

      // Dispose the document
      document.dispose();

      print(
          'Isolate: Extraction complete, text length: ${extractedText.length}');

      return result;
    } catch (e) {
      print('Isolate: Error extracting text: $e');
      return {
        'text': null,
        'pageCount': 0,
        'error': 'Extraction error: $e',
      };
    }
  }

  // Extract text from specific pages with validation
  Future<Map<String, dynamic>> extractTextFromPages(
    File pdfFile, {
    int? startPage,
    int? endPage,
  }) async {
    Map<String, dynamic> result = {
      'success': false,
      'text': '',
      'error': null,
      'pagesProcessed': 0,
    };

    try {
      // Validate PDF first
      final validation = await validatePdfFile(pdfFile);
      if (!validation['isValid']) {
        result['error'] = validation['error'];
        return result;
      }

      final bytes = await pdfFile.readAsBytes();
      final PdfDocument document = PdfDocument(inputBytes: bytes);
      final PdfTextExtractor extractor = PdfTextExtractor(document);

      String extractedText = '';
      int totalPages = document.pages.count;

      int start = startPage ?? 0;
      int end = endPage ?? totalPages - 1;

      // Validate page range
      if (start < 0 || start >= totalPages) {
        document.dispose();
        result['error'] =
            'Invalid start page: $start (PDF has $totalPages pages)';
        return result;
      }

      if (end < start || end >= totalPages) {
        end = totalPages - 1;
      }

      for (int i = start; i <= end; i++) {
        try {
          String pageText = extractor.extractText(
            startPageIndex: i,
            endPageIndex: i,
          );
          extractedText += pageText + '\n';
          result['pagesProcessed'] = result['pagesProcessed'] + 1;
        } catch (pageError) {
          print('PDF Service: Error extracting text from page $i: $pageError');
          // Continue with other pages
        }
      }

      document.dispose();

      extractedText = cleanExtractedText(extractedText);

      if (extractedText.trim().isEmpty) {
        result['error'] = 'No text found in specified pages';
        return result;
      }

      result['text'] = extractedText;
      result['success'] = true;

      return result;
    } catch (e) {
      print('PDF Service: Error extracting text from specific pages: $e');
      result['error'] = 'Failed to extract text from pages: $e';
      return result;
    }
  }

  // Get PDF metadata with error handling
  Future<Map<String, dynamic>> getPdfInfo(File pdfFile) async {
    Map<String, dynamic> result = {
      'success': false,
      'info': {},
      'error': null,
    };

    try {
      // Validate PDF first
      final validation = await validatePdfFile(pdfFile);
      if (!validation['isValid']) {
        result['error'] = validation['error'];
        return result;
      }

      final bytes = await pdfFile.readAsBytes();
      final PdfDocument document = PdfDocument(inputBytes: bytes);

      Map<String, dynamic> info = {
        'pageCount': document.pages.count,
        'title': document.documentInformation.title.isEmpty
            ? 'Untitled'
            : document.documentInformation.title,
        'author': document.documentInformation.author.isEmpty
            ? 'Unknown'
            : document.documentInformation.author,
        'subject': document.documentInformation.subject,
        'keywords': document.documentInformation.keywords,
        'creator': document.documentInformation.creator,
        'producer': document.documentInformation.producer,
        'creationDate': document.documentInformation.creationDate.toString(),
        'modificationDate':
            document.documentInformation.modificationDate.toString(),
        'fileSize': validation['fileSize'],
      };

      document.dispose();

      result['info'] = info;
      result['success'] = true;

      return result;
    } catch (e) {
      print('PDF Service: Error getting PDF info: $e');
      result['error'] = 'Failed to get PDF information: $e';
      return result;
    }
  }

  // Clean and format extracted text with better processing
  String cleanExtractedText(String rawText) {
    if (rawText.trim().isEmpty) {
      return '';
    }

    // Remove extra whitespaces and normalize line breaks
    String cleanText = rawText
        .replaceAll(RegExp(r'\r\n|\r'), '\n') // Normalize line endings
        .replaceAll(
            RegExp(r'\n\s*\n\s*\n+'), '\n\n') // Max 2 consecutive newlines
        .replaceAll(RegExp(r'[ \t]+'),
            ' ') // Replace multiple spaces/tabs with single space
        .replaceAll(
            RegExp(r' \n'), '\n') // Remove trailing spaces before newlines
        .replaceAll(
            RegExp(r'\n '), '\n') // Remove leading spaces after newlines
        .trim();

    return cleanText;
  }

  // Check if text content is meaningful
  bool isTextContentMeaningful(String text) {
    if (text.trim().isEmpty) {
      return false;
    }

    // Remove whitespace and count actual characters
    String cleanText = text.replaceAll(RegExp(r'\s+'), '');

    // Should have at least 10 characters
    if (cleanText.length < 10) {
      return false;
    }

    // Should contain some letters (not just numbers/symbols)
    if (!RegExp(r'[a-zA-Z]').hasMatch(cleanText)) {
      return false;
    }

    return true;
  }

  // Split text into sections for better AI processing
  List<String> splitTextIntoSections(String text, {int maxLength = 2000}) {
    List<String> sections = [];

    if (text.length <= maxLength) {
      sections.add(text);
      return sections;
    }

    List<String> paragraphs = text.split('\n');
    String currentSection = '';

    for (String paragraph in paragraphs) {
      if ((currentSection + paragraph).length <= maxLength) {
        currentSection += paragraph + '\n';
      } else {
        if (currentSection.isNotEmpty) {
          sections.add(currentSection.trim());
          currentSection = paragraph + '\n';
        } else {
          // If single paragraph is too long, split by sentences
          List<String> sentences = paragraph.split(RegExp(r'[.!?]+'));
          for (String sentence in sentences) {
            if ((currentSection + sentence).length <= maxLength) {
              currentSection += sentence + '. ';
            } else {
              if (currentSection.isNotEmpty) {
                sections.add(currentSection.trim());
                currentSection = sentence + '. ';
              }
            }
          }
        }
      }
    }

    if (currentSection.isNotEmpty) {
      sections.add(currentSection.trim());
    }

    return sections;
  }
}
