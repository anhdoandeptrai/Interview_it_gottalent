import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../viewmodels/practice_viewmodel.dart';

class ModernPracticeScreen extends StatelessWidget {
  const ModernPracticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PracticeViewModel>(
      builder: (viewModel) {
        return Scaffold(
          backgroundColor: const Color(0xFF0F0F23),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            title: const Text(
              'Luyện tập',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: false,
            actions: [
              IconButton(
                onPressed: () => _showExitDialog(viewModel),
                icon: const Icon(Icons.close, color: Colors.white),
              ),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildProgressBar(viewModel),
                  const SizedBox(height: 20),
                  _buildQuestionCard(viewModel),
                  const SizedBox(height: 20),
                  Expanded(
                    child: _buildCameraPreview(viewModel),
                  ),
                  const SizedBox(height: 20),
                  _buildControlButtons(viewModel),
                  const SizedBox(height: 20),
                  _buildInstructionText(viewModel),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressBar(PracticeViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Câu hỏi ${viewModel.currentQuestionIndex + 1}/${viewModel.currentSession?.questions.length ?? 0}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${(viewModel.sessionProgress * 100).toInt()}%',
                style: const TextStyle(
                  color: Color(0xFF10B981),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: viewModel.sessionProgress,
            backgroundColor: Colors.white.withOpacity(0.1),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(PracticeViewModel viewModel) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF667EEA).withOpacity(0.2),
            const Color(0xFF764BA2).withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF667EEA).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF667EEA),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.quiz,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Câu hỏi',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            viewModel.currentQuestion.isNotEmpty
                ? viewModel.currentQuestion
                : 'Đang tải câu hỏi...',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraPreview(PracticeViewModel viewModel) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.05),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Camera preview placeholder
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black26,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.videocam_outlined,
                      size: 64,
                      color: Colors.white54,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Camera Preview',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Recording indicator
            Obx(() => viewModel.isRecording
                ? Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.fiber_manual_record,
                            size: 12,
                            color: Colors.white,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'REC',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButtons(PracticeViewModel viewModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Previous question button
        if (viewModel.currentQuestionIndex > 0)
          _buildControlButton(
            icon: Icons.skip_previous,
            onPressed: () => _previousQuestion(viewModel),
            color: Colors.white.withOpacity(0.3),
          ),

        if (viewModel.currentQuestionIndex > 0) const SizedBox(width: 20),

        // Main record button
        Obx(() => _buildRecordButton(viewModel)),

        const SizedBox(width: 20),

        // Next question button
        if (viewModel.currentQuestionIndex <
            (viewModel.currentSession?.questions.length ?? 0) - 1)
          _buildControlButton(
            icon: Icons.skip_next,
            onPressed: () => _nextQuestion(viewModel),
            color: Colors.white.withOpacity(0.3),
          ),
      ],
    );
  }

  Widget _buildRecordButton(PracticeViewModel viewModel) {
    return GestureDetector(
      onTap: viewModel.isBusy
          ? null
          : () {
              if (viewModel.isRecording) {
                viewModel.stopAnswer();
              } else {
                viewModel.startAnswer();
              }
            },
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: viewModel.isRecording
              ? const LinearGradient(
                  colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                )
              : const LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF059669)],
                ),
          boxShadow: [
            BoxShadow(
              color: (viewModel.isRecording
                      ? const Color(0xFFEF4444)
                      : const Color(0xFF10B981))
                  .withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Icon(
          viewModel.isRecording ? Icons.stop : Icons.mic,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildInstructionText(PracticeViewModel viewModel) {
    return Obx(() => Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.white.withOpacity(0.7),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  viewModel.currentInstruction.isNotEmpty
                      ? viewModel.currentInstruction
                      : 'Nhấn nút ghi âm để bắt đầu trả lời câu hỏi',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  void _previousQuestion(PracticeViewModel viewModel) {
    // Implementation for going to previous question
  }

  void _nextQuestion(PracticeViewModel viewModel) {
    // Implementation for going to next question
  }

  void _showExitDialog(PracticeViewModel viewModel) {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text(
          'Thoát luyện tập?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Bạn có chắc chắn muốn thoát? Tiến trình hiện tại sẽ bị mất.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              viewModel.navigateToHome();
            },
            child: const Text(
              'Thoát',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
