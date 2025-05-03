import 'package:flutter/gestures.dart'; // Required for TapGestureRecognizer
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For jsonEncode and jsonDecode

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // --- State Variables ---
  final _formKey = GlobalKey<FormState>();

  // --- Class-Level Color Constants ---
  static const Color darkBackgroundColor = Color.fromRGBO(25, 25, 25, 0.98);
  static const Color formBackgroundColor = Colors.white;
  static const Color primaryOrangeColor = Color(0xFFF56600); // Adjust as needed
  static const Color greyTextColor = Colors.grey;
  static const Color darkTextColor = Color(0xFF333333);
  static const Color lightTextColor = Colors.white70;
  static const Color toggleButtonBg = Color(0xFFF0F0F0);

  // --- Animation and Visibility State ---
  bool _isFormVisible = true; // Start visible
  static const Duration _slideDuration = Duration(milliseconds: 350);

  // --- Controllers and Form State Variables ---
  final _firstNameController = TextEditingController();
  final _emailController = TextEditingController(); // Using email
  final _phoneNumberController = TextEditingController();
  final _passwordController = TextEditingController();

  String _selectedUserType = 'merchant';
  String? _selectedCompanyLocation;
  String? _selectedIndustry;
  bool _acceptedPrivacyPolicy = false;

  bool _isLoading = false;
  String? _errorMessage;

  // Example data for dropdowns - Replace with your actual data
  final List<String> _companyLocations = ['United States', 'Canada', 'France', 'Germany', 'United Kingdom', 'Other'];
  final List<String> _industries = ['Technology', 'Finance', 'Healthcare', 'Retail', 'Education', 'Other'];

  // --- Dispose Controllers ---
  @override
  void dispose() {
    _firstNameController.dispose();
    _emailController.dispose(); // Dispose correct controller
    _phoneNumberController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- Validation Logic ---
  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) { return '$fieldName is required'; }
    return null;
  }
   String? _validateDropdown(String? value, String fieldName) {
    if (value == null) { return 'Please select $fieldName'; }
    return null;
  }
  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) { return 'Email is required'; }
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(value)) { return 'Please enter a valid email format'; }
    return null;
  }
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) { return 'Password is required'; }
    if (value.length < 6) { return 'Password must be at least 6 characters long'; }
    return null;
  }

  // --- Registration Logic (_register) ---
  Future<void> _register() async {
    setState(() { _errorMessage = null; });

    if (_formKey.currentState!.validate()) {
      setState(() { _isLoading = true; });

      // Collect data including the correct email controller
      final dataToSend = {
        'userType': _selectedUserType,
        'firstName': _firstNameController.text,
        'companyLocation': _selectedCompanyLocation,
        'email': _emailController.text, // Using 'email' key
        'industry': _selectedIndustry,
        'phoneNumber': _phoneNumberController.text,
        'password': _passwordController.text,
        'acceptedPrivacyPolicy': _acceptedPrivacyPolicy,
      };

      // --> IMPORTANT: Replace with your actual backend URL <--
      const String apiUrl = 'http://localhost:3000/api/auth/register';

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
          body: jsonEncode(dataToSend),
        );

        dynamic responseBody;
        try { responseBody = jsonDecode(response.body); }
        catch (e) {
          print("Error decoding JSON: $e | Response: ${response.body}");
          responseBody = {'message': 'Invalid response from server (Status: ${response.statusCode})'};
        }

        if (response.statusCode == 201) {
          final successMsg = responseBody['message'] ?? 'Registration successful!';
          setState(() {
            _isLoading = false;
            // Reset form fields and state
             _formKey.currentState?.reset();
            _firstNameController.clear();
            _emailController.clear();
            _phoneNumberController.clear();
            _passwordController.clear();
            _selectedCompanyLocation = null;
            _selectedIndustry = null;
            _acceptedPrivacyPolicy = false;
            _selectedUserType = 'merchant';
            // Optionally close the panel after success
            // _isFormVisible = false;
          });

          if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(content: Text(successMsg), backgroundColor: Colors.green, duration: const Duration(seconds: 3)),
            );
          }
        } else { // Handle backend errors (4xx, 5xx)
          setState(() {
            _errorMessage = responseBody['message'] ?? 'An error occurred: Status ${response.statusCode}';
            _isLoading = false;
          });
        }
      } catch (e) { // Handle network errors
        print('Registration Error: $e');
        if (mounted) {
          setState(() {
            _errorMessage = 'Could not connect to the server. Please try again.';
            _isLoading = false;
          });
        }
      }
    } else { // Form validation failed
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fix the errors in the form'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // --- Build Method (UI Structure with Animation) ---
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final formWidth = screenWidth * 0.4; // Define panel width

    return Scaffold(
      backgroundColor: darkBackgroundColor, // Base background is dark
      body: Stack(
        children: [
          // --- Layer 1: Dark Background (Always visible) ---
Container(
            width: double.infinity, // Assure qu'il prend toute la largeur
            height: double.infinity, // Assure qu'il prend toute la hauteur
            color: darkBackgroundColor, // Couleur de fond principale
            // Ajouter du Padding général pour le contenu
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 40.0), // Ajuste le padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Aligner logo, titre, sous-titre à gauche
                children: [
                  // --- Logo ---
                  // --> Assure-toi que le chemin est correct <--
                  Image.asset(
                    'assets/images/logo.png',
                    height: 35,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.business, color: Colors.white, size: 35),
                  ),
                  const SizedBox(height: 80), // Espace après le logo

                  // --- Titre ---
                  const Text(
                    'Manage your Money\nAnywhere',
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.3,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 20),

                  // --- Sous-titre ---
                  const Text(
                    'View all the analytics and grow your business\nfrom anywhere!',
                    style: TextStyle(
                      fontSize: 16,
                      color: lightTextColor, // Utilise la constante définie plus haut
                      height: 1.5,
                      fontFamily: 'Inter',
                    ),
                  ),

                  // --- Spacer pour pousser les boîtes vers le centre vertical ---
                  const Spacer(),

Center(
                    child: Row(
                      // Répartit l'espace horizontal équitablement autour des boîtes
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      // Limite la largeur totale que la Row peut prendre si nécessaire
                      // mainAxisSize: MainAxisSize.min, // Décommente si elles se collent trop

                      children: [
                        // Plus besoin de Center autour de chaque boîte ici
                        _buildInfoBox(
                          "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                        ),
                        // On peut ajouter un SizedBox horizontal si spaceEvenly ne convient pas
                        // const SizedBox(width: 20),
                        _buildInfoBox(
                          "Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.",
                        ),
                        // const SizedBox(width: 20),
                        _buildInfoBox(
                          "Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.",
                        ),
                      ],
                    ),
                  ), // Fin du Center pour la Row

                  // --- Spacer pour centrer verticalement les boîtes ---
                  const Spacer(),

                ], // Fin des children de la Column principale du fond
              ), // Fin du Padding
            ), // Fin du Container de fond
          ), // Fin de la Couche 1

          // --- Layer 2: Sliding Form Panel ---
          AnimatedPositioned(
            duration: _slideDuration,
            curve: Curves.easeInOut,
            top: 0,
            bottom: 0,
            width: formWidth,
            // Animate the 'right' property based on visibility state
            right: _isFormVisible ? 0 : -formWidth, // Slides off-screen to the right

            child: Container(
              decoration: BoxDecoration(
                color: formBackgroundColor,
                borderRadius: const BorderRadius.only(
                     topLeft: Radius.circular(25.0),
                     bottomLeft: Radius.circular(25.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 30,
                    offset: const Offset(-10, 0),
                  ),
                ],
              ),
              // Use a nested Stack to position the close button above the form
              child: Stack(
                children: [
                  // Form content needs padding, especially at the top for the close button
                  Padding(
                    padding: const EdgeInsets.only(top: 50.0), // Space for close button
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(35.0, 20.0, 35.0, 40.0), // Left, Top, Right, Bottom padding
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // --- Form Title ---
                            const Text(
                              'Create an account',
                              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: darkTextColor, fontFamily: 'Inter'),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 35),

                            // --- Form Elements (using helper methods) ---
                            _buildUserTypeToggle(),
                            const SizedBox(height: 25),
                            _buildTextFormField(_firstNameController, 'First Name', validator: (v) => _validateRequired(v, 'First Name')),
                            const SizedBox(height: 18),
                            _buildDropdownFormField(hint: 'Where is your company based?', value: _selectedCompanyLocation, items: _companyLocations, onChanged: (v) => setState(() => _selectedCompanyLocation = v), validator: (v) => _validateDropdown(v, 'location')),
                            const SizedBox(height: 18),
                            _buildTextFormField(_emailController, 'Email', keyboardType: TextInputType.emailAddress, validator: _validateEmail), // Correct controller and label
                            const SizedBox(height: 18),
                            _buildDropdownFormField(hint: 'Please select an Industry', value: _selectedIndustry, items: _industries, onChanged: (v) => setState(() => _selectedIndustry = v), validator: (v) => _validateDropdown(v, 'industry')),
                            const SizedBox(height: 18),
                            _buildTextFormField(_phoneNumberController, 'Phone number', keyboardType: TextInputType.phone, validator: (v) => _validateRequired(v, 'Phone number')),
                            const SizedBox(height: 18),
                            _buildTextFormField(_passwordController, 'Password', obscureText: true, validator: _validatePassword),
                            const SizedBox(height: 25),
                            _buildPrivacyPolicyCheckbox(),
                            const SizedBox(height: 25),

                            // --- Error Message Display ---
                            if (_errorMessage != null) Padding(padding: const EdgeInsets.only(bottom: 15.0), child: Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600, fontFamily: 'Inter', fontSize: 13), textAlign: TextAlign.center)),

                            // --- Submit Button ---
                            ElevatedButton(
                              onPressed: _isLoading ? null : _register,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryOrangeColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
                                elevation: 3
                              ),
                              child: _isLoading
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 3, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                                : const Text('Create an Account'),
                            ),
                            const SizedBox(height: 30),

                            // --- Login Link ---
                            _buildLoginLink(greyTextColor, primaryOrangeColor),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // --- Close Button (Positioned within the form panel's Stack) ---
                  Positioned(
                    top: 15,
                    right: 15,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: greyTextColor),
                      iconSize: 28,
                      tooltip: 'Close form',
                      onPressed: () {
                        // Set visibility state to false, triggering the animation
                        setState(() { _isFormVisible = false; });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (!_isFormVisible)
            Positioned(
              top: 20, // Espace depuis le haut
              right: 25, // Espace depuis la droite
              child: TextButton( // Ou ElevatedButton si tu préfères un fond
                onPressed: () {
                  // Remet _isFormVisible à true pour faire glisser le panneau
                  setState(() {
                    _isFormVisible = true;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryOrangeColor, // Couleur orange (depuis les constantes de classe)
                  foregroundColor: Colors.white,      // Texte blanc
                  // Ajuster le padding pour un bouton de coin (un peu moins haut)
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0), 
                  ),
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                  elevation: 3, // Légère ombre
                ),
                child: const Text('Create Account'),
              ),
            ),

        ],
      ),
    );
  }


  // --- Helper Widgets ---
  // (These remain unchanged from the previous corrected version,
  // they now correctly access the class-level color constants)

    Widget _buildInfoBox(String text) {
    // Style pour le texte à l'intérieur des boîtes
    const infoTextStyle = TextStyle(
      color: Colors.white, // Texte blanc
      fontSize: 14,
      height: 1.6, // Espacement des lignes
      fontFamily: 'Inter',
    );

    return Container(
      padding: const EdgeInsets.all(25.0), // Padding intérieur
      constraints: const BoxConstraints(maxWidth: 350), // Largeur max pour éviter qu'elles soient trop larges
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35), // Fond noir semi-transparent
        borderRadius: BorderRadius.circular(15.0), // Coins arrondis
      ),
      child: Text(
        text,
        style: infoTextStyle,
        textAlign: TextAlign.center, // Centrer le texte dans la boîte
      ),
    );
  }

  Widget _buildTextFormField(TextEditingController controller, String label, {bool obscureText = false, TextInputType? keyboardType, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller, obscureText: obscureText, keyboardType: keyboardType, validator: validator,
      style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: darkTextColor),
      decoration: InputDecoration(
        hintText: label, hintStyle: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: Colors.grey),
        filled: true, fillColor: const Color(0xFFF9F9F9),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: primaryOrangeColor.withOpacity(0.5), width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 15.0),
      ), textInputAction: TextInputAction.next,
    );
  }

  Widget _buildDropdownFormField({required String hint, required String? value, required List<String> items, required void Function(String?)? onChanged, required String? Function(String?)? validator}) {
    return DropdownButtonFormField<String>(
      value: value, items: items.map((String item) => DropdownMenuItem<String>(value: item, child: Text(item, style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: darkTextColor)))).toList(),
      onChanged: onChanged, validator: validator,
      style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: darkTextColor),
      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
      decoration: InputDecoration(
          hintText: hint, hintStyle: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: Colors.grey),
          filled: true, fillColor: const Color(0xFFF9F9F9),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: primaryOrangeColor.withOpacity(0.5), width: 1.5)),
          contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 15.0),
      ), isExpanded: true,
    );
  }

  Widget _buildUserTypeToggle() {
    return Container(
       padding: const EdgeInsets.all(4),
       decoration: BoxDecoration(color: toggleButtonBg, borderRadius: BorderRadius.circular(12.0)),
       child: Row(children: [_buildToggleButton('Merchant', 'merchant'), const SizedBox(width: 4), _buildToggleButton('Agent', 'agent')]),
    );
  }

  Widget _buildToggleButton(String text, String value) {
      bool isSelected = _selectedUserType == value;
      return Expanded(child: ElevatedButton(
          onPressed: () => setState(() => _selectedUserType = value),
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected ? Colors.black : Colors.transparent, foregroundColor: isSelected ? Colors.white : darkTextColor,
            elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            padding: const EdgeInsets.symmetric(vertical: 14), shadowColor: Colors.transparent,
          ),
          child: Text(text, style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 14)),
      ));
  }

  Widget _buildPrivacyPolicyCheckbox() {
    return FormField<bool>(
       key: ValueKey('privacyCheckbox$_acceptedPrivacyPolicy'), initialValue: _acceptedPrivacyPolicy,
       validator: (value) => (value == false) ? 'You must accept the privacy policy' : null,
       builder: (FormFieldState<bool> state) {
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            InkWell(onTap: () => setState(() { _acceptedPrivacyPolicy = !_acceptedPrivacyPolicy; state.didChange(_acceptedPrivacyPolicy); }),
              child: Row(children: [
                SizedBox(height: 20, width: 20, child: Checkbox(
                    value: _acceptedPrivacyPolicy, onChanged: (v) => setState(() { _acceptedPrivacyPolicy = v ?? false; state.didChange(_acceptedPrivacyPolicy); }),
                    activeColor: primaryOrangeColor, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, visualDensity: VisualDensity.compact,
                    side: BorderSide(color: state.hasError ? Colors.red : Colors.grey.shade400, width: 1.5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                )),
                const SizedBox(width: 8),
                Expanded(child: Text('I accept the Privacy Policy', style: TextStyle(fontSize: 13, fontFamily: 'Inter', color: state.hasError ? Colors.red : darkTextColor.withOpacity(0.8)))),
              ]),
            ),
            if (state.hasError) Padding(padding: const EdgeInsets.only(top: 6.0), child: Text(state.errorText!, style: const TextStyle(color: Colors.red, fontSize: 12, fontFamily: 'Inter'))),
          ]);
       },
    );
  }

  Widget _buildLoginLink(Color normalColor, Color linkColor) {
    return Text.rich(
      TextSpan(text: 'Already have an account? ', style: TextStyle(color: normalColor, fontSize: 14, fontFamily: 'Inter'),
        children: <TextSpan>[TextSpan(text: 'Log in', style: TextStyle(color: linkColor, fontWeight: FontWeight.w600, fontFamily: 'Inter', fontSize: 14),
            recognizer: TapGestureRecognizer()..onTap = () { print('Log in link tapped!'); /* TODO: Navigate */ },
        )],
      ), textAlign: TextAlign.center,
    );
  }
} // End of _RegisterScreenState class