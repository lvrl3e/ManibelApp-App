import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'rate_or_report_driver_screen.dart';

class RateTripScreen extends StatefulWidget {
  final RecentDriverTrip trip;

  const RateTripScreen({
    super.key,
    required this.trip,
  });

  @override
  State<RateTripScreen> createState() => _RateTripScreenState();
}

class _RateTripScreenState extends State<RateTripScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _commentController =
      TextEditingController();

  int _rating = 0;

  bool _loading = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please give a rating."),
        ),
      );
      return;
    }

    setState(() {
      _loading = true;
    });

    await Future.delayed(
      const Duration(seconds: 1),
    );

    if (!mounted) return;

    setState(() {
      _loading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.green,
        content: Text("Rating submitted successfully!"),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF5F6F8),
        foregroundColor: Colors.black,
        title: const Text(
          "Rate Driver",
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),

          child: Form(
            key: _formKey,

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                SizedBox(
                  width: double.infinity,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        const Text(
                          "Trip Details",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // TODO(BACKEND):
                        // Replace these local values with data fetched from the backend.
                        // Example:
                        // Driver Name -> trip.driverName
                        // Plate Number -> trip.plateNumber
                        // Route -> trip.route
                        // Trip Date -> trip.tripDate

                        const Text("Driver: Juan Dela Cruz"),

                        Text("Plate No.: ${widget.trip.plateNumber}"),

                        Text("Route: ${widget.trip.route}"),

                        const Text("Trip Date: August 7, 2026"),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Rate Trip",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      5,
                      (index) {
                        final value = index + 1;

                        return IconButton(
                          iconSize: 42,
                          splashRadius: 24,
                          onPressed: () {
                            setState(() {
                              _rating = value;
                            });
                          },
                          icon: Icon(
                            value <= _rating
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color: Colors.amber,
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Comment (Optional)",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                TextFormField(
                  controller: _commentController,
                  minLines: 4,
                  maxLines: 6,
                  decoration: InputDecoration(
                    hintText:
                        "Tell us about your experience...",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(15),
                    ),
                  ),
                ),

                const SizedBox(height: 35),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed:
                        _loading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          AppColors.logoBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(15),
                      ),
                    ),

                    child: _loading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            "Submit Rating",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}