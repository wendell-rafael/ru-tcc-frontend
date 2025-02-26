import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../domain/controllers/register_controller.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_password_field.dart';
import '../../widgets/custom_text_field.dart';
import '../user/home_screen.dart';


class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _focusEmail = FocusNode();
  final _focusPassword = FocusNode();
  final _focusConfirmPassword = FocusNode();
  final _focusDropdown = FocusNode();

  String _selectedDietaryRestriction = "Nenhuma";

  @override
  Widget build(BuildContext context) {
    final registerController = Provider.of<RegisterController>(context);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.white,
            statusBarIconBrightness: Brightness.dark,
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Center(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: kToolbarHeight + 20),
                    Image.asset('assets/images/logo.png', height: 120),
                    SizedBox(height: 16),
                    Text(
                      'Criar uma Conta',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Preencha seus dados para se cadastrar',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    SizedBox(height: 24),
                    CustomTextField(
                      label: 'Nome',
                      controller: _nameController,
                      nextFocus: _focusEmail,
                    ),
                    CustomTextField(
                      label: 'Email',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      focusNode: _focusEmail,
                      nextFocus: _focusPassword,
                    ),
                    CustomPasswordField(
                      label: 'Senha',
                      controller: _passwordController,
                      focusNode: _focusPassword,
                      nextFocus: _focusConfirmPassword,
                      isConfirm: false,
                    ),
                    CustomPasswordField(
                      label: 'Confirme a Senha',
                      controller: _confirmPasswordController,
                      focusNode: _focusConfirmPassword,
                      nextFocus: _focusDropdown,
                      isConfirm: true,
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedDietaryRestriction,
                      focusNode: _focusDropdown,
                      decoration: InputDecoration(
                        labelText: 'Restrição Alimentar',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      items: ['Nenhuma', 'Vegetariano', 'Vegano']
                          .map((option) => DropdownMenuItem(value: option, child: Text(option)))
                          .toList(),
                      onChanged: (newValue) => setState(() => _selectedDietaryRestriction = newValue!),
                    ),
                    SizedBox(height: 32),
                    registerController.isLoading
                        ? CircularProgressIndicator()
                        : CustomButton(
                      label: 'Cadastrar',
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          String? errorMessage = await registerController.registerUser(
                            name: _nameController.text.trim(),
                            email: _emailController.text.trim(),
                            password: _passwordController.text.trim(),
                            confirmPassword: _confirmPasswordController.text.trim(),
                            dietaryRestriction: _selectedDietaryRestriction,
                          );
                          if (errorMessage != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(errorMessage)),
                            );
                          } else {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => HomeScreen()),
                            );
                          }
                        }
                      },
                    ),
                    SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
