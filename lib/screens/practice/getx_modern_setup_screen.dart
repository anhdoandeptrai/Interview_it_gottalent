import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'dart:io';
import '../../models/practice_session.dart';
import '../../viewmodels/practice_viewmodel.dart';

class ModernSetupScreen extends StatelessWidget {
  final PracticeMode mode;

  const ModernSetupScreen({super.key, required this.mode});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PracticeViewModel>(
      init: PracticeViewModel(),
      builder: (viewModel) {
        // Set the mode in viewModel
        WidgetsBinding.instance.addPostFrameCallback((_) {
          viewModel.setSelectedMode(mode);
        });

        return Scaffold(
          backgroundColor: const Color(0xFF0F0F23),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Get.back(),
            ),
            title: Text(
              viewModel.modeTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildModeHeader(viewModel),
                  const SizedBox(height: 32),
                  _buildFileSelection(viewModel),
                  const SizedBox(height: 24),
                  _buildInstructions(viewModel),
                  const SizedBox(height: 32),
                  _buildStartButton(viewModel),
                  const SizedBox(height: 16),
                  Obx(() => viewModel.hasError
                      ? _buildErrorMessage(viewModel.errorMessage)
                      : const SizedBox.shrink()),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildModeHeader(PracticeViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF667EEA).withOpacity(0.1),
            const Color(0xFF764BA2).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF667EEA).withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF667EEA),
                  const Color(0xFF764BA2),
                ],
              ),
            ),
            child: Icon(
              _getModeIcon(viewModel.selectedMode),
              size: 32,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            viewModel.modeTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            viewModel.modeTitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFileSelection(PracticeViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Chọn tài liệu PDF',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Obx(() => Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: viewModel.selectedFile != null
                      ? const Color(0xFF10B981)
                      : Colors.white.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: viewModel.selectedFile != null
                  ? _buildSelectedFile(viewModel)
                  : _buildFilePickerButton(viewModel),
            )),
      ],
    );
  }

  Widget _buildSelectedFile(PracticeViewModel viewModel) {
    final fileName = viewModel.selectedFile!.path.split('/').last;
    final fileSize = _formatFileSize(viewModel.selectedFile!.lengthSync());

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.picture_as_pdf,
            color: Color(0xFF10B981),
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fileName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                fileSize,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => viewModel.setSelectedFile(null),
          icon: const Icon(
            Icons.close,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildFilePickerButton(PracticeViewModel viewModel) {
    return InkWell(
      onTap: () => _pickFile(viewModel),
      child: Column(
        children: [
          Icon(
            Icons.cloud_upload_outlined,
            size: 48,
            color: Colors.white.withOpacity(0.6),
          ),
          const SizedBox(height: 16),
          Text(
            'Nhấn để chọn file PDF',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hỗ trợ file PDF dưới 10MB',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions(PracticeViewModel viewModel) {
    final instructions = viewModel.selectedMode == PracticeMode.interview
        ? [
            'Tải lên CV hoặc mô tả công việc',
            'AI sẽ tạo câu hỏi phỏng vấn phù hợp',
            'Luyện tập trả lời với camera và micro',
            'Nhận phân tích chi tiết và góp ý',
          ]
        : [
            'Tải lên slide hoặc tài liệu thuyết trình',
            'AI sẽ tạo câu hỏi về nội dung',
            'Thực hành thuyết trình với camera',
            'Cải thiện kỹ năng giao tiếp và tự tin',
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hướng dẫn sử dụng',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...instructions.asMap().entries.map((entry) {
          final index = entry.key;
          final instruction = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: const Color(0xFF667EEA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    instruction,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildStartButton(PracticeViewModel viewModel) {
    return Obx(() {
      final isProcessing = viewModel.isBusy || viewModel.isPdfProcessing;
      final isDisabled = isProcessing || viewModel.selectedFile == null;

      return Column(
        children: [
          // Progress indicator khi đang xử lý
          if (isProcessing) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF667EEA).withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: viewModel.processingProgress,
                      backgroundColor: Colors.white.withOpacity(0.1),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF667EEA),
                      ),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Processing step text
                  Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          viewModel.processingStep,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Extra info when generating questions
                  if (viewModel.isGeneratingQuestions) ...[
                    const SizedBox(height: 8),
                    Text(
                      '🤖 AI đang phân tích nội dung và tạo câu hỏi phù hợp...',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Start button
          SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: isDisabled ? null : () => viewModel.startPractice(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.withOpacity(0.3),
                disabledForegroundColor: Colors.white.withOpacity(0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: isProcessing
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Đang xử lý...',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.play_arrow_rounded, size: 24),
                        SizedBox(width: 8),
                        Text(
                          'Bắt đầu luyện tập',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildErrorMessage(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.red.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red.shade300,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.red.shade300,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickFile(PracticeViewModel viewModel) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        viewModel.setSelectedFile(file);
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể chọn file: $e');
    }
  }

  IconData _getModeIcon(PracticeMode mode) {
    switch (mode) {
      case PracticeMode.interview:
        return Icons.work_rounded;
      case PracticeMode.presentation:
        return Icons.present_to_all_rounded;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
}
