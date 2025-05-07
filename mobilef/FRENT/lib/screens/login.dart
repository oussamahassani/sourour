import 'package:flutter/material.dart';
import 'DashboardScreen.dart';
import 'signup.dart';
import '../services/login_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool _obscurePassword = true;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _motDePasseController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFF8F9FA),
                Color(0xFFE9ECEF),
              ],
            ),
          ),
          child: Padding(
            padding:  EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Logo et titre
                      Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          color: Color(0xFF41B1A2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.lock_outlined,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      SizedBox(height: 24),
                      Text(
                        "Bienvenue",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF212529),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Connectez-vous pour continuer",
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF6C757D),
                        ),
                      ),
                      SizedBox(height: 40),
                      
                      // Champs de formulaire
                      _buildTextField(
                        controller: _emailController,
                        labelText: "Adresse e-mail",
                        prefixIcon: Icons.email_outlined,
                        isEmail: true,
                      ),
                      SizedBox(height: 16),
                      _buildTextField(
                        controller: _motDePasseController,
                        labelText: "Mot de passe",
                        prefixIcon: Icons.lock_outline,
                        isPassword: true,
                      ),
                      
                      // Option mot de passe oublié
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // Naviguer vers la page de récupération de mot de passe
                          },
                          child: Text(
                            "Mot de passe oublié ?",
                            style: TextStyle(
                              color: Color(0xFF41B1A2),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 24),
                      
                      // Bouton de connexion
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  if (_formKey.currentState!.validate()) {
                                    loginUser(_emailController.text, _motDePasseController.text);
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF41B1A2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: isLoading
                              ? SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.0,
                                  ),
                                )
                              : Text(
                                  "SE CONNECTER",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      
                      SizedBox(height: 24),
                      
                      // Option pour s'inscrire
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Vous n'avez pas de compte ? ",
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF6C757D),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => SignupScreen()),
                              );
                            },
                            child: Text(
                              "S'inscrire",
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF41B1A2),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
    bool isEmail = false,
    bool isPassword = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? _obscurePassword : false,
      enableSuggestions: !isPassword,
      autocorrect: !isPassword,
      keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
      style: TextStyle(
        fontSize: 16,
        color: Color(0xFF212529),
      ),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
          color: Color(0xFF6C757D),
          fontSize: 16,
        ),
        prefixIcon: Icon(
          prefixIcon,
          color: Color(0xFF6C757D),
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Color(0xFF6C757D),
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Color(0xFFE9ECEF),
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Color(0xFF41B1A2),
            width: 2.0,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.red.shade300,
            width: 1.0,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.red.shade300,
            width: 2.0,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
      validator: (value) {
        if (value!.isEmpty) return "Ce champ est requis";
        if (isEmail && !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return "Adresse e-mail invalide";
        }
        if (isPassword && value.length < 6) return "Le mot de passe doit contenir au moins 6 caractères";
        return null;
      },
    );
  }

  Future<void> loginUser(String email, String motDePasse) async {
    setState(() => isLoading = true);

    try {
      final response = await LoginService.login(email, motDePasse);

      setState(() => isLoading = false);

      if (response['success']) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DashboardScreen()),
        );
      } else {
        _showErrorDialog(response['message'] ?? 'Une erreur est survenue.');
      }
    } catch (e) {
      setState(() => isLoading = false);
      _showErrorDialog('Erreur de connexion: ${e.toString()}');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          'Erreur',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF212529),
          ),
        ),
        content: Text(
          message,
          style: TextStyle(color: Color(0xFF6C757D)),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            child: Text(
              'OK',
              style: TextStyle(
                color: Color(0xFF41B1A2),
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}