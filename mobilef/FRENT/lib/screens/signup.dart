import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frent/services/auth_service.dart';
import './login.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _motDePasseController = TextEditingController();
  final TextEditingController _confirmationMdpController = TextEditingController();

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _telephoneController.dispose();
    _emailController.dispose();
    _motDePasseController.dispose();
    _confirmationMdpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF41B1A2)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Créer un compte",
          style: TextStyle(
            color: Color(0xFF333333),
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding:  EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),
                  
                  // Logo ou illustration
                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFF41B1A2).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_add_alt_1_rounded,
                      size: 50,
                      color: Color(0xFF41B1A2),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Texte d'introduction
                  const Text(
                    "Créez votre compte et commencez à utiliser notre service",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF666666),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Champs du formulaire dans une carte
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // Nom et prénom sur la même ligne
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  _nomController,
                                  "Nom",
                                  false,
                                  prefixIcon: Icons.person_outline,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildTextField(
                                  _prenomController,
                                  "Prénom",
                                  false,
                                  prefixIcon: Icons.person_outline,
                                ),
                              ),
                            ],
                          ),
                          
                          _buildTextField(
                            _telephoneController,
                            "Téléphone",
                            true,
                            prefixIcon: Icons.phone_outlined,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(8),
                            ],
                          ),
                          
                          _buildTextField(
                            _emailController,
                            "Email",
                            false,
                            isEmail: true,
                            prefixIcon: Icons.email_outlined,
                          ),
                          
                          _buildTextField(
                            _motDePasseController,
                            "Mot de passe",
                            false,
                            isPassword: true,
                            prefixIcon: Icons.lock_outline,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                            obscureText: !_isPasswordVisible,
                          ),
                          
                          _buildTextField(
                            _confirmationMdpController,
                            "Confirmer le mot de passe",
                            false,
                            isPassword: true,
                            confirmPassword: true,
                            prefixIcon: Icons.lock_outline,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                                });
                              },
                            ),
                            obscureText: !_isConfirmPasswordVisible,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  
                  
                  const SizedBox(height: 20),
                  
                  // Bouton d'inscription
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                signupUser(
                                  _nomController.text,
                                  _prenomController.text,
                                  _telephoneController.text,
                                  _emailController.text,
                                  _motDePasseController.text,
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF41B1A2),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        disabledBackgroundColor: const Color(0xFF41B1A2).withOpacity(0.6),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              "S'inscrire",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Lien vers la page de connexion
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Vous avez déjà un compte ? ",
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF666666),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => LoginScreen()),
                          );
                        },
                        child: const Text(
                          "Se connecter",
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF41B1A2),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String labelText,
    bool isPhoneNumber, {
    bool isEmail = false,
    bool isPassword = false,
    bool confirmPassword = false,
    IconData? prefixIcon,
    Widget? suffixIcon,
    bool obscureText = false,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: const TextStyle(
            color: Color(0xFF666666),
            fontSize: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF41B1A2), width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, color: Colors.grey.shade600, size: 20)
              : null,
          suffixIcon: suffixIcon,
        ),
        keyboardType: isPhoneNumber
            ? TextInputType.phone
            : (isEmail ? TextInputType.emailAddress : TextInputType.text),
        textInputAction: TextInputAction.next,
        obscureText: obscureText,
        enableSuggestions: !isPassword,
        autocorrect: !isPassword,
        inputFormatters: inputFormatters,
        validator: (value) {
          if (value == null || value.isEmpty) return "Ce champ est requis";
          if (isPhoneNumber && !RegExp(r'^[0-9]{8}$').hasMatch(value)) {
            return "Numéro de téléphone invalide (8 chiffres)";
          }
          if (isEmail && !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
            return "Format d'email invalide";
          }
          if (isPassword && value.length < 6) {
            return "Le mot de passe doit contenir au moins 6 caractères";
          }
          if (confirmPassword && value != _motDePasseController.text) {
            return "Les mots de passe ne correspondent pas";
          }
          return null;
        },
      ),
    );
  }

  Future<void> signupUser(String nom, String prenom, String telephone, String email, String motDePasse) async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await AuthService.signup(nom, prenom, telephone, email, motDePasse);

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 201) {
        // Inscription réussie
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Inscription réussie !'),
            backgroundColor: Color(0xFF41B1A2),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
        
        // Redirection vers la page de connexion
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) =>  LoginScreen()),
          );
        });
      } else {
        // Erreur d'inscription
        final responseBody = json.decode(response.body);
        String errorMessage = responseBody['message'] ?? 'Une erreur est survenue lors de l\'inscription.';
        
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red),
                const SizedBox(width: 8),
                const Text('Erreur d\'inscription'),
              ],
            ),
            content: Text(errorMessage),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            actions: [
              TextButton(
                child: const Text('OK', style: TextStyle(color: Color(0xFF41B1A2))),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.signal_wifi_connected_no_internet_4_outlined, color: Colors.red),
              const SizedBox(width: 8),
              const Text('Erreur de connexion'),
            ],
          ),
          content: Text('Impossible de se connecter au serveur. Veuillez vérifier votre connexion internet et réessayer.\n\nDétails: $e'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              child: const Text('OK', style: TextStyle(color: Color(0xFF41B1A2))),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
  }
}