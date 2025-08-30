import 'package:fitflex/features/auth/presentation/pages/ActivityLevelPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// ====== FORMATTERS (fora do State!) ======

/// Aceita números decimais com até [decimalRange] casas (vírgula ou ponto).
class DecimalTextInputFormatter extends TextInputFormatter {
  final int decimalRange;
  DecimalTextInputFormatter({this.decimalRange = 2}) : assert(decimalRange > 0);

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final raw = newValue.text;
    if (raw.isEmpty) return newValue;

    // Normaliza vírgula -> ponto só para validação
    final text = raw.replaceAll(',', '.');

    // Só dígitos e no máx. um separador decimal
    if (!RegExp(r'^\d*\.?\d*$').hasMatch(text)) return oldValue;

    // Limita as casas decimais
    if (text.contains('.')) {
      final dec = text.split('.').last;
      if (dec.length > decimalRange) return oldValue;
    }
    return newValue;
  }
}

/// Aceita apenas inteiros.
class IntTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;
    if (!RegExp(r'^\d+$').hasMatch(text)) return oldValue;
    return newValue;
  }
}

/// Normaliza número para envio ao backend: troca vírgula por ponto
/// e remove ponto final solto (ex.: "80." -> "80").
String normalizeNumber(String value) {
  var v = value.trim().replaceAll(',', '.');
  if (v.endsWith('.')) v = v.substring(0, v.length - 1);
  return v;
}

/// ====== WIDGET ======

class UserInfoPage extends StatefulWidget {
  final String userId;
  const UserInfoPage({super.key, required this.userId});

  @override
  State<UserInfoPage> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  final _pesoController = TextEditingController();
  final _alturaController = TextEditingController();
  final _metaPesoController = TextEditingController();
  final _idadeController = TextEditingController();
  String? _sexoSelecionado;

  @override
  void dispose() {
    _pesoController.dispose();
    _alturaController.dispose();
    _metaPesoController.dispose();
    _idadeController.dispose();
    super.dispose();
  }

  Future<void> _saveUserInfo() async {
    final peso = normalizeNumber(_pesoController.text);
    final altura = _alturaController.text.trim(); // inteiro
    final metaPeso = normalizeNumber(_metaPesoController.text);
    final idade = _idadeController.text.trim(); // inteiro
    final sexo = _sexoSelecionado;

    if (peso.isEmpty || altura.isEmpty || metaPeso.isEmpty || idade.isEmpty || sexo == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Preencha todos os campos.")));
      return;
    }

    const String baseUrl = "https://fitflex-deployment.onrender.com";

    try {
      final res = await http.post(
        Uri.parse("$baseUrl/api/user/info"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "userId": widget.userId,
          "peso": peso,
          "altura": altura,
          "metaPeso": metaPeso,
          "idade": idade,
          "sexo": sexo,
        }),
      );

      final data = jsonDecode(res.body);

      if (res.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(data["msg"] ?? "Informações salvas!")));
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ActivityLevelPage(userId: widget.userId)),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(data["msg"] ?? "Erro ao salvar.")));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erro ao conectar ao servidor: $e")));
    }
  }

  InputDecoration _decoration(String hint, IconData icon) => InputDecoration(
    prefixIcon: Icon(icon, color: Colors.grey.shade600),
    hintText: hint,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    enabledBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: Color(0xFFE6E6E6)),
    ),
    focusedBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: Color(0xFF007BFF)),
    ),
    fillColor: Colors.white,
    filled: true,
  );

  Text _label(String text) => Text(
    text,
    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                const Text(
                  "Conte-nos sobre você",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                const SizedBox(height: 32),

                _label("Peso atual"),
                const SizedBox(height: 8),
                TextField(
                  controller: _pesoController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [DecimalTextInputFormatter(decimalRange: 2)],
                  decoration: _decoration("80.00Kg (Obrigatório)", Icons.monitor_weight),
                ),
                const SizedBox(height: 20),

                _label("Altura"),
                const SizedBox(height: 8),
                TextField(
                  controller: _alturaController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [IntTextInputFormatter()],
                  decoration: _decoration("180cm (Obrigatório)", Icons.height),
                ),
                const SizedBox(height: 20),

                _label("Meta de peso"),
                const SizedBox(height: 8),
                TextField(
                  controller: _metaPesoController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [DecimalTextInputFormatter(decimalRange: 2)],
                  decoration: _decoration("75.00Kg", Icons.track_changes),
                ),
                const SizedBox(height: 20),

                _label("Idade"),
                const SizedBox(height: 8),
                TextField(
                  controller: _idadeController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [IntTextInputFormatter()],
                  decoration: _decoration("Obrigatório", Icons.cake),
                ),
                const SizedBox(height: 20),

                _label("Sexo"),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _sexoSelecionado,
                  decoration: _decoration("Obrigatório", Icons.person),
                  items: const [
                    DropdownMenuItem(value: "masculino", child: Text("Masculino")),
                    DropdownMenuItem(value: "feminino", child: Text("Feminino")),
                  ],
                  onChanged: (value) => setState(() => _sexoSelecionado = value),
                ),
                const SizedBox(height: 40),

                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _saveUserInfo,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
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
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Center(
                        child: Text(
                          "Salvar",
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
