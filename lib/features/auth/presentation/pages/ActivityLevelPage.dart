import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ActivityLevelPage extends StatefulWidget {
  final String userId;

  const ActivityLevelPage({super.key, required this.userId});

  @override
  _ActivityLevelPageState createState() => _ActivityLevelPageState();
}

class _ActivityLevelPageState extends State<ActivityLevelPage> {
  String? _selectedLevel;

  final List<Map<String, String>> _levels = [
    {
      "title": "Baixo",
      "value": "baixo",
      "desc": "Não pratico atividade física e passo a maior parte do dia sentado",
      "emoji": "😴",
    },
    {
      "title": "Médio",
      "value": "medio",
      "desc": "Trabalho em pé ou pratico exercícios físicos 2x na semana",
      "emoji": "🏃",
    },
    {
      "title": "Alto",
      "value": "alto",
      "desc": "Trabalho exige muito esforço físico ou/e treino mais de 4x na semana",
      "emoji": "💪",
    },
  ];

  Future<void> _saveActivityLevel() async {
    if (_selectedLevel == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Selecione um nível de atividade.")));
      return;
    }

    const String baseUrl = "https://fitflex-deployment.onrender.com";

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/user/info"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"userId": widget.userId, "atividade": _selectedLevel}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Dados salvos com sucesso!")));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Erro ao salvar: ${response.body}")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro de conexão: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const Text(
              "Calculando taxa basal",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Roboto'),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              "Selecione qual enquadra no seu perfil",
              style: TextStyle(fontSize: 14, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _levels.length,
                itemBuilder: (context, index) {
                  final item = _levels[index];
                  final isSelected = _selectedLevel == item["title"];

                  return Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.85,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: RadioListTile<String>(
                        value: item["value"]!,
                        groupValue: _selectedLevel,
                        onChanged: (value) {
                          setState(() {
                            _selectedLevel = value;
                          });
                        },
                        activeColor: Colors.green,
                        title: Row(
                          children: [
                            Text(item["emoji"]!, style: const TextStyle(fontSize: 20)),
                            const SizedBox(width: 10),
                            Text(
                              item["title"]!,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Text(
                            item["desc"]!,
                            style: const TextStyle(fontSize: 13, color: Colors.black87),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: _saveActivityLevel,
                child: const Text(
                  "Finalizar configuração",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
