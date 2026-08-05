import 'package:flutter/material.dart';

// Relative import accessing core constants
import '../../../core/constants/app_colors.dart';

class DriverDashboardScreen extends StatefulWidget {
  final String driverName;
  final String driverId;
  final int todayTrips;
  final double earningsToday;

  const DriverDashboardScreen({
    super.key,
    this.driverName = 'Juan Dela Cruz',
    this.driverId = 'MB-2024-0001',
    this.todayTrips = 12,
    this.earningsToday = 1250.0,
  });

  @override
  State<DriverDashboardScreen> createState() => _DriverDashboardScreenState();
}

class _DriverDashboardScreenState extends State<DriverDashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isOnline = false;

  // Opens the full-screen interactive route preview
  void _openFullMapRoute() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildExpandedMapModal(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF9FAFB),
      
      // Settings Drawer (Triggered by top-left 3-line icon)
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: AppColors.logoBlue),
              accountName: Text(
                widget.driverName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              accountEmail: Text('Driver ID: ${widget.driverId}'),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40, color: AppColors.logoBlue),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to Settings Screen
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.errorRed),
              title: const Text('Logout', style: TextStyle(color: AppColors.errorRed)),
              onTap: () {
                Navigator.pop(context);
                Navigator.pop(context); // Return to login
              },
            ),
          ],
        ),
      ),

      // Floating Action Button - Start Trip
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        height: 70,
        width: 70,
        margin: const EdgeInsets.only(bottom: 10),
        child: FloatingActionButton(
          onPressed: () {
            // TODO: Start Trip logic
          },
          backgroundColor: Colors.white,
          elevation: 4,
          shape: const CircleBorder(
            side: BorderSide(color: Color(0xFFE5E7EB), width: 1.5),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.directions_bus, color: AppColors.logoBlue, size: 28),
              SizedBox(height: 2),
              Text(
                'Start Trip',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Header Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu, size: 28, color: AppColors.textPrimary),
                    onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                  ),
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Sans-Serif',
                      ),
                      children: [
                        TextSpan(text: 'Manibel', style: TextStyle(color: AppColors.logoBlue)),
                        TextSpan(text: 'App', style: TextStyle(color: AppColors.logoRed)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_none_outlined, size: 28, color: AppColors.textPrimary),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Driver Profile Header Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 28,
                      backgroundColor: Color(0xFFE5E7EB),
                      child: Icon(Icons.person, size: 36, color: AppColors.textSecondary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Good morning,',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                          Text(
                            widget.driverName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Driver ID: ${widget.driverId}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.logoBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Online/Offline Status Switch
                    InkWell(
                      onTap: () {
                        setState(() {
                          _isOnline = !_isOnline;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _isOnline ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _isOnline ? Colors.green : AppColors.errorRed,
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 4,
                              backgroundColor: _isOnline ? Colors.green : AppColors.errorRed,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _isOnline ? 'Online' : 'Offline',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: _isOnline ? Colors.green.shade800 : AppColors.errorRed,
                              ),
                            ),
                            const Icon(Icons.keyboard_arrow_down, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Map Preview Section (Pasig - Quiapo Route)
              GestureDetector(
                onTap: _openFullMapRoute,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Live Location Tracking',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Row(
                              children: const [
                                CircleAvatar(radius: 4, backgroundColor: Colors.green),
                                SizedBox(width: 4),
                                Text(
                                  'Live',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      // Map Graphic Container
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                        child: Container(
                          height: 180,
                          width: double.infinity,
                          color: const Color(0xFFE5E7EB),
                          child: Stack(
                            children: [
                              // Grid/Road Simulation Graphic
                              Positioned.fill(
                                child: CustomPaint(
                                  painter: MapRoutePainter(),
                                ),
                              ),
                              // Route Indicator Tag
                              Positioned(
                                top: 10,
                                left: 10,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'Route: Pasig - Quiapo',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ),
                              // Expand Map Hint Overlay
                              Positioned(
                                bottom: 10,
                                right: 10,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.logoBlue,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.zoom_out_map, size: 14, color: Colors.white),
                                      SizedBox(width: 4),
                                      Text(
                                        'Tap to Expand',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Dynamic 2-Card Stats Row (Today's Trips & Earnings)
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.directions_bus_filled,
                      iconBg: const Color(0xFFDBEAFE),
                      iconColor: AppColors.logoBlue,
                      title: "Today's Trips",
                      value: '${widget.todayTrips}',
                      subtitle: 'Trips',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.account_balance_wallet,
                      iconBg: const Color(0xFFFEF3C7),
                      iconColor: const Color(0xFFD97706),
                      title: 'Earnings',
                      value: '₱${widget.earningsToday.toStringAsFixed(0)}',
                      subtitle: 'Today',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Operations Dashboard Link Card
              _buildNavigationCard(
                icon: Icons.local_gas_station,
                iconBg: const Color(0xFFDCFCE7),
                iconColor: Colors.green.shade700,
                title: 'Daily Operations Dashboard',
                subtitle: 'Check if your revenue is higher than your gas expense',
                onTap: () {},
              ),
              const SizedBox(height: 12),

              // Live Trip Map Link Card
              _buildNavigationCard(
                icon: Icons.pin_drop,
                iconBg: const Color(0xFFE0F2FE),
                iconColor: AppColors.logoBlue,
                title: 'Live Trip Map',
                subtitle: 'Enables real-time GPS tracking of vehicles along route',
                onTap: _openFullMapRoute,
              ),
              const SizedBox(height: 80), // Padding space for floating action button
            ],
          ),
        ),
      ),
    );
  }

  // Stat Card Widget Builder
  Widget _buildStatCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Navigation Option Builder
  Widget _buildNavigationCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 26),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.logoBlue),
          ],
        ),
      ),
    );
  }

  // Expanded Pasig - Quiapo Route Map Modal with Waiting Passengers
  Widget _buildExpandedMapModal(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pasig - Quiapo Route Map',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Live Waiting Passengers along route',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Interactive Map Simulation Area
          Expanded(
            child: Stack(
              children: [
                // Background Base Map
                Container(
                  color: const Color(0xFFE5E7EB),
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: MapRoutePainter(),
                  ),
                ),

                // Passenger Waiting Clusters on Route
                _buildPassengerMarker(top: 120, left: 80, count: 5, stopName: 'Pasig Palengke'),
                _buildPassengerMarker(top: 240, left: 180, count: 8, stopName: 'Shaw Blvd / EDSA'),
                _buildPassengerMarker(top: 360, left: 120, count: 3, stopName: 'Stop & Shop'),
                _buildPassengerMarker(top: 480, left: 240, count: 12, stopName: 'Quiapo Church'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Passenger Waiting Circle Marker Widget
  Widget _buildPassengerMarker({
    required double top,
    required double left,
    required int count,
    required String stopName,
  }) {
    return Positioned(
      top: top,
      left: left,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              stopName,
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 4),
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.logoRed,
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.splashBackground,
              child: Text(
                '$count',
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter to render simulated roads and routes on map
class MapRoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke;

    final routePaint = Paint()
      ..color = AppColors.logoBlue.withOpacity(0.8)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(40, 40);
    path.quadraticBezierTo(size.width * 0.8, size.height * 0.3, size.width * 0.3, size.height * 0.6);
    path.lineTo(size.width * 0.7, size.height * 0.9);

    canvas.drawPath(path, roadPaint);
    canvas.drawPath(path, routePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}