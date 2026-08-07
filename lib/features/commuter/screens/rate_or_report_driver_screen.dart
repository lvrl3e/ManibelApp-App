import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/constants/app_colors.dart';
import 'rate_trip_screen.dart';
import 'report_issue_trip.dart';

class RecentDriverTrip {
  final String id;
  final String plateNumber;
  final String route;
  final String? photoUrl;

  const RecentDriverTrip({
    required this.id,
    required this.plateNumber,
    required this.route,
    this.photoUrl,
  });

  String get vehicleLabel => plateNumber;
}

class RateOrReportDriverScreen extends StatefulWidget {
  const RateOrReportDriverScreen({super.key});

  @override
  State<RateOrReportDriverScreen> createState() =>
      _RateOrReportDriverScreenState();
}

class _RateOrReportDriverScreenState
    extends State<RateOrReportDriverScreen> {

  final List<RecentDriverTrip> _recentTrips = const [
    RecentDriverTrip(
      id: 'NCR-4821',
      plateNumber: 'NCR-4821',
      route: 'Pasig - Quiapo',
    ),
    RecentDriverTrip(
      id: 'NCR-1195',
      plateNumber: 'NCR-1195',
      route: 'Pasig - Quiapo',
    ),
    RecentDriverTrip(
      id: 'NCR-7742',
      plateNumber: 'NCR-7742',
      route: 'Quiapo - Pasig',
    ),
  ];

  final TextEditingController _plateController = TextEditingController();

  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  RecentDriverTrip? _selectedTrip;
  String? _tripError;
  String? _cameraError;
  String? _lastScanned;

  static const Color _green = Color(0xFF2E9E4F);

  @override
  void dispose() {
    _plateController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  void _handleDetection(BarcodeCapture capture) {
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final rawValue = barcodes.first.rawValue?.trim() ?? '';
    if (rawValue.isEmpty || rawValue == _lastScanned) return;

    _lastScanned = rawValue;
    _matchAndSelect(rawValue);
  }

  String _cameraErrorMessage(MobileScannerException error) {
    switch (error.errorCode) {
      case MobileScannerErrorCode.permissionDenied:
        return 'Camera permission is required to scan.\nEnable it in your device settings.';
      default:
        return 'Could not start the camera.';
    }
  }

  void _handleManualEntry() {
    final value = _plateController.text.trim();
    if (value.isEmpty) {
      setState(() => _tripError = "Please enter a plate number.");
      return;
    }
    _matchAndSelect(value);
  }

  void _matchAndSelect(String raw) {
    final normalized = raw.trim().toUpperCase();

    if (normalized.isEmpty) {
      setState(() => _tripError = "That didn't contain a valid vehicle ID.");
      return;
    }

    final match = _recentTrips.where(
      (trip) => trip.plateNumber.toUpperCase() == normalized || trip.id.toUpperCase() == normalized,
    );

    if (match.isEmpty) {
      setState(() {
        _selectedTrip = null;
        _tripError = "This vehicle isn't in your recent trips, so we can't match it.";
      });
      return;
    }

    setState(() {
      _selectedTrip = match.first;
      _tripError = null;
    });

    FocusScope.of(context).unfocus();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: _green,
        content: Text('Matched ${match.first.vehicleLabel} • ${match.first.route}'),
      ),
    );
  }

  bool _validateSelection() {
    if (_selectedTrip == null) {
      setState(() {
        _tripError = "Please scan a QR code or enter a plate number first.";
      });
      return false;
    }

    return true;
  }

  void _goToRate() {
    if (!_validateSelection()) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RateTripScreen(trip: _selectedTrip!),
      ),
    );
  }

  void _goToReport() {
    if (!_validateSelection()) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReportIssueTrip(trip: _selectedTrip!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        title: const Text(
          "Rate or Report Driver",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ---- How it works banner ----
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFE7F5EA),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.qr_code_scanner_rounded,
                        color: Color(0xFF1BB3B3),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "How it works?",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: _green,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            "Scan the QR code inside the jeepney to rate or report the driver.",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ---- QR scan viewfinder (live camera) ----
              Center(
                child: SizedBox(
                  width: 260,
                  height: 260,
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: SizedBox(
                          width: 260,
                          height: 260,
                          child: _cameraError != null
                              ? _CameraErrorBox(
                                  message: _cameraError!,
                                  onRetry: () => setState(() => _cameraError = null),
                                )
                              : MobileScanner(
                                  controller: _scannerController,
                                  onDetect: _handleDetection,
                                  errorBuilder: (context, error) {
                                    WidgetsBinding.instance.addPostFrameCallback((_) {
                                      if (mounted) {
                                        setState(() => _cameraError = _cameraErrorMessage(error));
                                      }
                                    });
                                    return const SizedBox.shrink();
                                  },
                                ),
                        ),
                      ),
                      ..._buildCorners(),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                "Couldn't scan the QR code on time?",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                "Enter the driver's plate number manually.",
                style: TextStyle(
                  fontSize: 12.5,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 12),

              TextField(
                controller: _plateController,
                textCapitalization: TextCapitalization.characters,
                onSubmitted: (_) => _handleManualEntry(),
                decoration: InputDecoration(
                  hintText: "e.g. ABC-1234",
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.logoBlue),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _handleManualEntry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "ENTER",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),

              if (_selectedTrip != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: _green, size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Selected ${_selectedTrip!.vehicleLabel} • ${_selectedTrip!.route}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _green),
                        ),
                      ),
                    ],
                  ),
                ),

              if (_tripError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    _tripError!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),

              const SizedBox(height: 28),

              const Text(
                "What can you do?",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 14),

              _ActionCard(
                icon: Icons.star_rounded,
                iconColor: const Color(0xFFE5A800),
                title: "Rate The Driver",
                subtitle: "After your trip, you can rate the driver.",
                onTap: _goToRate,
              ),

              const SizedBox(height: 14),

              _ActionCard(
                icon: Icons.shield_rounded,
                iconColor: AppColors.logoBlue,
                title: "Report an Issue",
                subtitle: "Need to report something? Scan and submit a report.",
                onTap: _goToReport,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildCorners() {
    const double len = 34;
    const double thick = 5;
    const Color color = AppColors.logoBlue;

    Widget corner({
      required Alignment alignment,
      required bool top,
      required bool left,
    }) {
      return Align(
        alignment: alignment,
        child: SizedBox(
          width: len,
          height: len,
          child: Stack(
            children: [
              Positioned(
                top: top ? 0 : null,
                bottom: top ? null : 0,
                left: 0,
                right: 0,
                child: Container(height: thick, color: color),
              ),
              Positioned(
                left: left ? 0 : null,
                right: left ? null : 0,
                top: 0,
                bottom: 0,
                child: Container(width: thick, color: color),
              ),
            ],
          ),
        ),
      );
    }

    return [
      corner(alignment: Alignment.topLeft, top: true, left: true),
      corner(alignment: Alignment.topRight, top: true, left: false),
      corner(alignment: Alignment.bottomLeft, top: false, left: true),
      corner(alignment: Alignment.bottomRight, top: false, left: false),
    ];
  }
}

class _CameraErrorBox extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _CameraErrorBox({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.videocam_off_rounded, color: Colors.white54, size: 32),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Colors.white70),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onRetry,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white54),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Try Again', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEDEDED)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: iconColor,
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: _RateOrReportDriverScreenState._green,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}