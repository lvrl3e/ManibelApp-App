import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'commuter_verified_screen.dart';

class CommuterFaceVerificationScreen extends StatefulWidget {
  const CommuterFaceVerificationScreen({super.key, required this.idType});

  final String idType;

  @override
  State<CommuterFaceVerificationScreen> createState() => _CommuterFaceVerificationScreenState();
}

class _CommuterFaceVerificationScreenState extends State<CommuterFaceVerificationScreen> {
  bool _isCaptured = false;
  bool _isProcessing = false; // covers both the capture and confirm requests
  String? _error;

  Future<void> _handleCapture() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
      _error = null;
    });

    try {
      // TODO: replace with the real camera capture call.
      await Future<void>.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;
      setState(() {
        _isCaptured = true;
        _isProcessing = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _error = 'Could not capture your photo. Please try again.';
      });
    }
  }

  void _handleRetake() {
    if (_isProcessing) return; // don't allow retake mid-request
    setState(() {
      _isCaptured = false;
      _error = null;
    });
  }

  Future<void> _handleConfirm() async {
    if (_isProcessing) return;

    // --- Validation ---------------------------------------------------
    if (!_isCaptured) {
      setState(() => _error = 'Please capture a photo first');
      return;
    }

    setState(() {
      _isProcessing = true;
      _error = null;
    });

    try {
      // TODO: replace with the real face-match verification call.
      await Future<void>.delayed(const Duration(milliseconds: 1000));
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => CommuterVerifiedScreen(idType: widget.idType),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _error = 'We could not verify your face. Please retake and try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F6F8),
        elevation: 0,
        foregroundColor: Colors.black87,
        title: const Text(
          'Face Verification',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.black),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            children: [
              Text(
                _isCaptured
                    ? 'Review your photo before confirming'
                    : 'Position your face within the frame and hold still',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black54),
              ),
              const SizedBox(height: 28),
              Expanded(
                child: Center(
                  child: _FaceFrame(isCaptured: _isCaptured, isProcessing: _isProcessing && !_isCaptured),
                ),
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFE23F3F)),
                  ),
                ),
              if (!_isCaptured)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _handleCapture,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.logoBlue,
                      disabledBackgroundColor: AppColors.logoBlue.withOpacity(0.6),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _isProcessing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                          )
                        : const Text(
                            'Capture',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white),
                          ),
                  ),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isProcessing ? null : _handleRetake,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.logoBlue),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text(
                          'Retake',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.logoBlue),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isProcessing ? null : _handleConfirm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.logoBlue,
                          disabledBackgroundColor: AppColors.logoBlue.withOpacity(0.6),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: _isProcessing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                              )
                            : const Text(
                                'Confirm',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white),
                              ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FaceFrame extends StatelessWidget {
  const _FaceFrame({required this.isCaptured, required this.isProcessing});

  final bool isCaptured;
  final bool isProcessing;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 240,
          height: 300,
          decoration: BoxDecoration(
            color: isCaptured ? const Color(0xFFEAF1FE) : const Color(0xFFECEDEF),
            borderRadius: BorderRadius.circular(140),
            border: Border.all(
              color: isCaptured ? const Color(0xFF2E9E6D) : AppColors.logoBlue,
              width: 3,
            ),
          ),
          child: Icon(
            isCaptured ? Icons.check_circle_rounded : Icons.face_retouching_natural_rounded,
            size: 72,
            color: isCaptured ? const Color(0xFF2E9E6D) : Colors.black26,
          ),
        ),
        if (isProcessing)
          const CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.logoBlue),
      ],
    );
  }
}