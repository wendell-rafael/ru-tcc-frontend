import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../domain/controllers/register_controller.dart';
import '../screens/home_screen.dart';

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
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    final registerController = Provider.of<RegisterController>(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.white, // Mantém o fundo branco mesmo ao rolar
          statusBarIconBrightness: Brightness.dark, // Ícones pretos na barra de status
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
                  _buildText('Criar uma Conta', 28, FontWeight.bold),
                  _buildText('Preencha seus dados para se cadastrar', 16, FontWeight.normal),
                  SizedBox(height: 24),
                  _buildInputField('Nome', _nameController, nextFocus: _focusEmail),
                  _buildInputField('Email', _emailController, focusNode: _focusEmail, nextFocus: _focusPassword),
                  _buildPasswordField('Senha', _passwordController, focusNode: _focusPassword, nextFocus: _focusConfirmPassword, isConfirm: false),
                  _buildPasswordField('Confirme a Senha', _confirmPasswordController, focusNode: _focusConfirmPassword, nextFocus: _focusDropdown, isConfirm: true),
                  SizedBox(height: 16),
                  _buildDropdown(),
                  SizedBox(height: 32), // Ajuste de espaçamento
                  registerController.isLoading
                      ? CircularProgressIndicator()
                      : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFE65100),
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
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
                            // Redireciona automaticamente para HomeScreen ao concluir cadastro
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => HomeScreen()),
                            );
                          }
                        }
                      },
                      child: Text(
                        'Cadastrar',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(height: 24), // Espaço extra abaixo do botão
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildText(String text, double size, FontWeight weight) {
    return Text(
      text,
      style: TextStyle(fontSize: size, fontWeight: weight, color: Colors.black),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, {FocusNode? focusNode, FocusNode? nextFocus}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        textInputAction: nextFocus != null ? TextInputAction.next : TextInputAction.done,
        onFieldSubmitted: (value) {
          if (nextFocus != null) {
            FocusScope.of(context).requestFocus(nextFocus);
          }
        },
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.black),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.black, width: 2),
          ),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Por favor, insira $label.';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller, {required bool isConfirm, FocusNode? focusNode, FocusNode? nextFocus}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        textInputAction: nextFocus != null ? TextInputAction.next : TextInputAction.done,
        onFieldSubmitted: (value) {
          if (nextFocus != null) {
            FocusScope.of(context).requestFocus(nextFocus);
          }
        },
        obscureText: isConfirm ? _obscureConfirmPassword : _obscurePassword,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.black),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.black, width: 2),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              isConfirm
                  ? (_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off)
                  : (_obscurePassword ? Icons.visibility : Icons.visibility_off),
              color: Colors.black,
            ),
            onPressed: () {
              setState(() {
                if (isConfirm) {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                } else {
                  _obscurePassword = !_obscurePassword;
                }
              });
            },
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor, insira sua senha.';
          }
          if (!isConfirm && value.length < 8) {
            return 'A senha deve ter no mínimo 8 caracteres.';
          }
          if (isConfirm && value != _passwordController.text) {
            return 'As senhas não coincidem.';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
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
    );
  }
}
