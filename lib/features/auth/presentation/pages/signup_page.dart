import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fitflex/features/auth/presentation/pages/UserInfo_page.dart';
import 'package:fitflex/features/auth/presentation/pages/signin_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  Future<void> _signup() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    print("=== INICIANDO SIGNUP ===");
    print("Nome: $name | Email: $email | Senha: ${password.length} caracteres");

    if (name.length < 3) {
      print("Validação falhou: nome pequeno");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("O nome deve ter pelo menos 3 caracteres.")));
      return;
    }
    if (!email.contains("@")) {
      print("Validação falhou: email inválido");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Digite um email válido.")));
      return;
    }
    if (password.length < 8) {
      print("Validação falhou: senha curta");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("A senha deve ter pelo menos 8 caracteres.")));
      return;
    }

    const String baseUrl = "https://fitflex-deployment.onrender.com/api";

    try {
      print("Enviando requisição para servidor...");
      final res = await http.post(
        Uri.parse("$baseUrl/auth/signup"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"name": name, "email": email, "password": password}),
      );

      print("Resposta bruta [${res.statusCode}]: ${res.body}");

      final data = jsonDecode(res.body);

      if (res.statusCode == 200 || res.statusCode == 201) {
        String? userId = data["userId"]?.toString();

        if (userId == null || userId.isEmpty) {
          userId = data["user"]?["id"]?.toString();
        }

        if (userId == null || userId.isEmpty) {
          print("ERRO: userId não encontrado na resposta");
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Erro: userId não recebido do servidor.")));
          return;
        }

        print("UserId recebido: $userId");

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(data["msg"] ?? "Conta criada com sucesso!")));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => UserInfoPage(userId: userId!)),
        );
      } else {
        print("Erro no servidor [${res.statusCode}] => ${data}");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(data["msg"] ?? "Erro ao cadastrar.")));
      }
    } catch (e, s) {
      print("EXCEÇÃO AO FAZER REQUISIÇÃO: $e");
      print("STACKTRACE: $s");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Erro ao conectar ao servidor.")));
    }
  }

  Widget buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    bool obscure = false,
    TextEditingController? controller,
    VoidCallback? toggleVisibility,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: Colors.grey[700]),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      obscure ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: toggleVisibility,
                  )
                : null,
            filled: true,
            fillColor: const Color(0xFFF5F5F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                const Text(
                  "Criar conta",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Comece sua jornada fitness hoje",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Colors.black54),
                ),
                const SizedBox(height: 28),

                // Nome
                buildTextField(
                  label: "Nome completo",
                  hint: "Ex.: João Pereira Silva",
                  icon: Icons.person,
                  controller: _nameController,
                ),
                const SizedBox(height: 18),

                // Email
                buildTextField(
                  label: "Email",
                  hint: "Ex.: joaosilva@gmail.com",
                  icon: Icons.email,
                  controller: _emailController,
                ),
                const SizedBox(height: 18),

                // Senha
                buildTextField(
                  label: "Senha",
                  hint: "Digite sua senha",
                  icon: Icons.lock,
                  controller: _passwordController,
                  obscure: _obscurePassword,
                  toggleVisibility: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  isPassword: true,
                ),
                const SizedBox(height: 28),

                // Botão cadastrar
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _signup,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: EdgeInsets.zero,
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF007BFF), Color(0xFF0056D2)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          "Cadastrar",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Rodapé
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Já tem uma conta? "),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const SigninPage()),
                        );
                      },
                      child: const Text(
                        "Fazer login",
                        style: TextStyle(color: Color(0xFF007BFF), fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
