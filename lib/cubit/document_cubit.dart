// lib/cubit/document_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pfa/Repositories/document_repo.dart';
import 'dart:typed_data';
import 'package:flutter/material.dart';

// --- Document States ---
abstract class DocumentState {}

class DocumentInitial extends DocumentState {}

class DocumentLoading extends DocumentState {}

class DocumentSuccess extends DocumentState {
  final String message;
  final String? url;
  DocumentSuccess(this.message, {this.url});
}

class DocumentError extends DocumentState {
  final String message;
  DocumentError(this.message);
}

// NEW STATES FOR URL FETCHING
class DocumentUrlLoading extends DocumentState {}

class DocumentUrlLoaded extends DocumentState {
  final String url;
  DocumentUrlLoaded(this.url);
}

class DocumentUrlError extends DocumentState {
  final String message;
  DocumentUrlError(this.message);
}

// --- Document Cubit ---
class DocumentCubit extends Cubit<DocumentState> {
  final DocumentRepository _documentRepository;

  DocumentCubit(this._documentRepository) : super(DocumentInitial());

  Future<void> savePdfDocumentToBackend({
    required int stageId,
    required Uint8List pdfBytes,
    required String pdfType,
    required String filename,
  }) async {
    emit(DocumentLoading());
    try {
      await _documentRepository.savePdfDocumentToBackend(
        stageId: stageId,
        pdfBytes: pdfBytes,
        pdfType: pdfType,
        filename: filename,
      );
      debugPrint(
        'DocumentCubit: savePdfDocumentToBackend - PDF save successful.',
      );
      emit(DocumentSuccess('Document saved successfully!'));
    } catch (e) {
      debugPrint(
        'DocumentCubit: savePdfDocumentToBackend - Error: ${e.toString()}',
      );
      emit(DocumentError('Failed to save document: ${e.toString()}'));
    }
  }

  // NEW METHOD: Fetch Document URL
  Future<void> fetchAndDisplayDocumentUrl({
    required int stageId,
    required String pdfType,
  }) async {
    emit(DocumentUrlLoading());
    try {
      final String url = await _documentRepository.fetchDocumentUrl(
        stageId: stageId,
        pdfType: pdfType,
      );
      debugPrint(
        'DocumentCubit: fetchAndDisplayDocumentUrl - URL fetched: $url',
      );
      emit(DocumentUrlLoaded(url));
    } catch (e) {
      debugPrint(
        'DocumentCubit: fetchAndDisplayDocumentUrl - Error fetching URL: ${e.toString()}',
      );
      emit(DocumentUrlError('Failed to fetch document URL: ${e.toString()}'));
    }
  }
}
