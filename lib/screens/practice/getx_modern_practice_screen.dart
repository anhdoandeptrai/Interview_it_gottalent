import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import '../../viewmodels/practice_viewmodel.dart';
import '../../controllers/practice_controller.dart';
// import '../../widgets/behavior_badge_widget.dart'; // TẮT
// import '../../models/behavior_result.dart'; // TẮT

class ModernPracticeScreen extends StatefulWidget {
  const ModernPracticeScreen({super.key});

  @override
  State<ModernPracticeScreen> createState() => _ModernPracticeScreenState();
}

class _ModernPracticeScreenState extends State<ModernPracticeScreen> {
  // bool _showBehaviorHistory = false; // TẮT

  @override
  void initState() {
    super.initState();
    // Start session and camera when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final practiceController = Get.find<PracticeController>();
      await practiceController.startSession();
    });
  }

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
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildProgressBar(viewModel),
                    const SizedBox(height: 16),
                    _buildQuestionCard(viewModel),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.4,
                      child: _buildCameraPreview(viewModel),
                    ),
                    const SizedBox(height: 16),
                    _buildControlButtons(viewModel),
                    const SizedBox(height: 12),
                    _buildInstructionText(viewModel),
                    const SizedBox(height: 16),
                  ],
                ),
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
    final session = viewModel.currentSession;
    final questionNumber = viewModel.currentQuestionIndex + 1;
    final totalQuestions = session?.questions.length ?? 0;

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$questionNumber/$totalQuestions',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
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
    final practiceController = Get.find<PracticeController>();
    final cameraController = practiceController.cameraController;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.05),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Camera preview (real or placeholder)
            cameraController != null && cameraController.value.isInitialized
                ? SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: cameraController.value.previewSize!.height,
                        height: cameraController.value.previewSize!.width,
                        child: CameraPreview(cameraController),
                      ),
                    ),
                  )
                : Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.black26,
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: Colors.white54,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Đang khởi động camera...',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

            // TẮT AI BEHAVIOR DETECTION ĐỂ TRÁNH CRASH
            // // AI Behavior Badge
            // StreamBuilder<BehaviorResult>(
            //   stream: practiceController.cameraService?.behaviorStream,
            //   builder: (context, snapshot) {
            //     return BehaviorBadgeWidget(
            //       behavior: snapshot.data,
            //       isLoading: !practiceController.cameraService!.isInitialized,
            //       isEnabled: true,
            //       onToggle: () {
            //         // Toggle behavior detection
            //         setState(() {
            //           practiceController.cameraService?.setBehaviorDetection(
            //               practiceController.cameraService?.behaviorDetector
            //                       .isInitialized !=
            //                   true);
            //         });
            //       },
            //     );
            //   },
            // ),

            // // Behavior History Panel (bottom right)
            // if (_showBehaviorHistory)
            //   Positioned(
            //     bottom: 16,
            //     right: 16,
            //     left: 16,
            //     child: BehaviorHistoryPanel(
            //       behaviors: practiceController
            //               .cameraService?.behaviorDetector.behaviorHistory ??
            //           [],
            //       statistics:
            //           practiceController.cameraService?.behaviorStatistics,
            //     ),
            //   ),

            // // Toggle History Button
            // Positioned(
            //   bottom: 16,
            //   right: 16,
            //   child: IconButton(
            //     onPressed: () {
            //       setState(() {
            //         _showBehaviorHistory = !_showBehaviorHistory;
            //       });
            //     },
            //     icon: Container(
            //       padding: const EdgeInsets.all(8),
            //       decoration: BoxDecoration(
            //         color: Colors.black.withOpacity(0.6),
            //         borderRadius: BorderRadius.circular(8),
            //       ),
            //       child: Icon(
            //         _showBehaviorHistory ? Icons.close : Icons.analytics,
            //         color: Colors.white,
            //       ),
            //     ),
            //   ),
            // ),

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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
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
                  .withOpacity(0.5),
              blurRadius: viewModel.isRecording ? 30 : 20,
              spreadRadius: viewModel.isRecording ? 5 : 0,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Pulse effect when recording
            if (viewModel.isRecording)
              TweenAnimationBuilder(
                key: ValueKey(viewModel.isRecording),
                tween: Tween<double>(begin: 0.8, end: 1.2),
                duration: const Duration(milliseconds: 800),
                onEnd: () {
                  if (viewModel.isRecording && mounted) {
                    setState(() {}); // Rebuild to restart animation
                  }
                },
                builder: (context, double value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.red.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                    ),
                  );
                },
              ),
            // Icon
            Icon(
              viewModel.isRecording ? Icons.stop_rounded : Icons.mic,
              color: Colors.white,
              size: 32,
            ),
          ],
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
    String instruction;
    IconData icon;
    Color iconColor;

    if (viewModel.isRecording) {
      instruction = '🎤 Đang ghi âm... Nói câu trả lời của bạn';
      icon = Icons.mic;
      iconColor = Colors.red;
    } else if (viewModel.currentQuestion.isNotEmpty) {
      instruction = 'Nhấn nút ghi âm để bắt đầu trả lời câu hỏi';
      icon = Icons.info_outline;
      iconColor = Colors.white.withOpacity(0.7);
    } else {
      instruction = 'Đang tải câu hỏi...';
      icon = Icons.hourglass_empty;
      iconColor = Colors.white.withOpacity(0.7);
    }

    return Obx(() => Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: viewModel.isRecording
                ? Colors.red.withOpacity(0.1)
                : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: viewModel.isRecording
                ? Border.all(color: Colors.red.withOpacity(0.3))
                : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  instruction,
                  style: TextStyle(
                    color: viewModel.isRecording
                        ? Colors.red.shade300
                        : Colors.white.withOpacity(0.7),
                    fontSize: 14,
                    fontWeight: viewModel.isRecording
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  void _previousQuestion(PracticeViewModel viewModel) {
    final practiceController = Get.find<PracticeController>();
    if (practiceController.currentQuestionIndex > 0) {
      practiceController.moveToQuestion(
        practiceController.currentQuestionIndex - 1,
      );
    }
  }

  void _nextQuestion(PracticeViewModel viewModel) {
    final practiceController = Get.find<PracticeController>();
    final session = practiceController.currentSession;
    if (session != null &&
        practiceController.currentQuestionIndex <
            session.questions.length - 1) {
      practiceController.moveToQuestion(
        practiceController.currentQuestionIndex + 1,
      );
    }
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
