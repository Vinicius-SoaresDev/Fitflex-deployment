class Validators {
  static String? requiredField(String? v, {String label = 'Campo'}) {
    if (v == null || v.trim().isEmpty) return '$label é obrigatório';
    return null;
  }

  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email é obrigatório';
    final re = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,}$');
    if (!re.hasMatch(v.trim())) return 'Email inválido';
    return null;
  }

  static String? minLength(String? v, int min, {String label = 'Campo'}) {
    if (v == null || v.length < min) {
      return '$label deve ter no mínimo $min caracteres';
    }
    return null;
  }
}
