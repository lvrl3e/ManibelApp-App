import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'role_selection_screen.dart';
import 'commuter_login_screen.dart';

class CommuterSignUpScreen extends StatefulWidget {
  const CommuterSignUpScreen({super.key});

  @override
  State<CommuterSignUpScreen> createState() =>
      _CommuterSignUpScreenState();
}

class _CommuterSignUpScreenState extends State<CommuterSignUpScreen> {

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _fullNameController =
      TextEditingController();

  final TextEditingController _phoneController =
      TextEditingController(text: '+63');

  final TextEditingController _passwordController =
      TextEditingController();

  final TextEditingController _confirmPasswordController =
      TextEditingController();


  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;

  bool _agreedToTerms = false;
  bool _isLoading = false;


  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }


  void _handleSignUp() async {

    final isFormValid =
        _formKey.currentState?.validate() ?? false;

    if (!isFormValid) return;


    if (!_agreedToTerms) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please agree to the Terms & Conditions to continue',
          ),
          backgroundColor: Colors.black87,
        ),
      );

      return;
    }


    setState(() {
      _isLoading = true;
    });


    await Future.delayed(
      const Duration(seconds: 1),
    );


    if (!mounted) return;


    setState(() {
      _isLoading = false;
    });


    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const CommuterLoginScreen(),
      ),
    );
  }


  InputDecoration _fieldDecoration({
    String? hintText,
    Widget? suffixIcon,
  }) {

    return InputDecoration(

      hintText: hintText,

      hintStyle: const TextStyle(
        color: Colors.black26,
        fontWeight: FontWeight.w700,
      ),

      filled: true,

      fillColor: const Color(0xFFF2F2F2),

      contentPadding:
          const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),

      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),

      suffixIcon: suffixIcon,
    );
  }

    @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.white,

      body: SafeArea(

        child: Center(

          child: SingleChildScrollView(

            padding: const EdgeInsets.symmetric(
              horizontal: 28.0,
              vertical: 24.0,
            ),

            child: Form(

              key: _formKey,

              child: Column(

                mainAxisAlignment:
                    MainAxisAlignment.center,

                crossAxisAlignment:
                    CrossAxisAlignment.center,

                children: [



                  const SizedBox(height: 8),


                  // App Logo
                  RichText(

                    text: const TextSpan(

                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),

                      children: [

                        TextSpan(
                          text: 'Manibel',
                          style: TextStyle(
                            color: AppColors.logoBlue,
                          ),
                        ),

                        TextSpan(
                          text: 'App',
                          style: TextStyle(
                            color: AppColors.logoRed,
                          ),
                        ),

                      ],

                    ),

                  ),


                  const SizedBox(height: 24),



                  // Title
                  const Text(

                    'Sign Up',

                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),

                  ),


                  const SizedBox(height: 4),



                  const Text(

                    'Sign Up as Commuter',

                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.black54,
                    ),

                  ),


                  const SizedBox(height: 24),

                                    // Full Name Input
                  TextFormField(

                    controller: _fullNameController,

                    keyboardType: TextInputType.name,

                    textCapitalization:
                        TextCapitalization.words,

                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),

                    decoration:
                        _fieldDecoration(
                          hintText: 'Full Name',
                        ),

                    validator: (value) {

                      if (value == null ||
                          value.trim().isEmpty) {

                        return 'Please enter your full name';

                      }

                      return null;
                    },

                  ),


                  const SizedBox(height: 16),



                  // Phone Number Input
                  TextFormField(

                    controller: _phoneController,

                    keyboardType: TextInputType.phone,

                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),

                    decoration:
                        _fieldDecoration(
                          hintText: 'Mobile Number',
                        ),

                    validator: (value) {

                      if (value == null ||
                          value.trim().isEmpty) {

                        return 'Please enter your mobile number';

                      }


                      if (value.trim().length < 10) {

                        return 'Please enter a valid mobile number';

                      }


                      return null;

                    },

                  ),


                  const SizedBox(height: 16),




                  // Password Input
                  TextFormField(

                    controller: _passwordController,

                    obscureText: _isPasswordObscured,

                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),


                    decoration:
                        _fieldDecoration(

                          hintText: 'Password',


                          suffixIcon:

                              IconButton(

                                icon: Icon(

                                  _isPasswordObscured

                                      ? Icons.visibility_outlined

                                      : Icons.visibility_off_outlined,

                                  color:
                                      AppColors.logoBlue,

                                ),


                                onPressed: () {

                                  setState(() {

                                    _isPasswordObscured =
                                        !_isPasswordObscured;

                                  });

                                },

                              ),

                        ),



                    validator: (value) {

                      if (value == null ||
                          value.isEmpty) {

                        return 'Please enter a password';

                      }


                      if (value.length < 8) {

                        return 'Password must be at least 8 characters';

                      }


                      return null;

                    },

                  ),



                  const SizedBox(height: 16),




                  // Confirm Password Input
                  TextFormField(

                    controller:
                        _confirmPasswordController,


                    obscureText:
                        _isConfirmPasswordObscured,


                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),


                    decoration:
                        _fieldDecoration(

                          hintText:
                              'Confirm Password',



                          suffixIcon:

                              IconButton(

                                icon: Icon(

                                  _isConfirmPasswordObscured

                                      ? Icons.visibility_outlined

                                      : Icons.visibility_off_outlined,


                                  color:
                                      AppColors.logoBlue,

                                ),



                                onPressed: () {

                                  setState(() {

                                    _isConfirmPasswordObscured =
                                        !_isConfirmPasswordObscured;

                                  });

                                },

                              ),

                        ),



                    validator: (value) {

                      if (value == null ||
                          value.isEmpty) {

                        return 'Please confirm your password';

                      }


                      if (value !=
                          _passwordController.text) {

                        return 'Passwords do not match';

                      }


                      return null;

                    },

                  ),



                  const SizedBox(height: 16),

                                    // Terms & Conditions Checkbox
                  Row(

                    crossAxisAlignment:
                        CrossAxisAlignment.center,

                    children: [

                      SizedBox(

                        width: 24,

                        height: 24,

                        child: Checkbox(

                          value: _agreedToTerms,

                          activeColor:
                              AppColors.logoBlue,


                          shape:
                              RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(4),
                              ),


                          onChanged: (value) {

                            setState(() {

                              _agreedToTerms =
                                  value ?? false;

                            });

                          },

                        ),

                      ),


                      const SizedBox(width: 8),


                      Expanded(

                        child: GestureDetector(

                          onTap: () {

                            setState(() {

                              _agreedToTerms =
                                  !_agreedToTerms;

                            });

                          },


                          child: const Text(

                            'I agree to the Terms & Conditions and Privacy Policy',


                            style: TextStyle(

                              fontSize: 12,

                              fontWeight:
                                  FontWeight.w600,

                              color:
                                  Colors.black54,

                            ),

                          ),

                        ),

                      ),

                    ],

                  ),


                  const SizedBox(height: 24),




                  // Sign Up Button
                  SizedBox(

                    width: double.infinity,

                    height: 52,


                    child: ElevatedButton(

                      onPressed:
                          _isLoading
                              ? null
                              : _handleSignUp,


                      style:
                          ElevatedButton.styleFrom(

                            backgroundColor:
                                const Color(0xFFE5A800),

                            elevation: 0,


                            shape:
                                RoundedRectangleBorder(

                                  borderRadius:
                                      BorderRadius.circular(16),

                                ),

                          ),



                      child:

                          _isLoading

                              ? const SizedBox(

                                  width: 24,

                                  height: 24,

                                  child:
                                      CircularProgressIndicator(

                                    color:
                                        Colors.white,

                                    strokeWidth:
                                        2.5,

                                  ),

                                )

                              : const Text(

                                  'Sign Up',


                                  style: TextStyle(

                                    color:
                                        Colors.black,

                                    fontSize:
                                        16,

                                    fontWeight:
                                        FontWeight.w800,

                                  ),

                                ),

                    ),

                  ),


                  const SizedBox(height: 16),




                  // Already have an account
Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [

    const Text(
      "Already have an account? ",
      style: TextStyle(
        fontSize: 13,
        color: AppColors.textSecondary,
      ),
    ),

    GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                const CommuterLoginScreen(),
          ),
        );
      },

      child: const Text(
        "Log In",
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: AppColors.logoBlue,
        ),
      ),
    ),

  ],
),


const SizedBox(height: 16),


// Back to Welcome Action
GestureDetector(
  onTap: () => Navigator.pop(context),

  child: const Text(
    'Back to Welcome',

    style: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w800,
      color: AppColors.logoBlue,
    ),

  ),

),


                ],

              ),

            ),

          ),

        ),

      ),

    );

  }

}