/// نتيجة التحقق من صحة البيانات.
class ValidationResult {
  const ValidationResult._({required this.valid, this.field, this.message});

  const ValidationResult.valid() : this._(valid: true);

  const ValidationResult.invalid({required String field, required String message})
      : this._(valid: false, field: field, message: message);

  final bool valid;
  final String? field;
  final String? message;

  bool get isValid => valid;
  bool get isInvalid => !valid;

  @override
  String toString() => valid
      ? 'ValidationResult.valid()'
      : 'ValidationResult.invalid($field: $message)';
}
