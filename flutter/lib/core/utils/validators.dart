abstract final class Validators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Введите email';
    final re = RegExp(r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$');
    if (!re.hasMatch(value)) return 'Неверный формат email';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.length < 8) return 'Минимум 8 символов';
    return null;
  }

  static String? username(String? value) {
    if (value == null || value.isEmpty) return 'Введите имя пользователя';
    if (value.length < 3) return 'Минимум 3 символа';
    if (value.length > 50) return 'Максимум 50 символов';
    return null;
  }
}
