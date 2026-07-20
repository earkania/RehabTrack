sealed class AppError {
  const AppError();
}

class DatabaseError extends AppError {
  final String message;
  final Object? cause;

  const DatabaseError({required this.message, this.cause});
}

class ValidationError extends AppError {
  final String field;
  final String message;

  const ValidationError({required this.field, required this.message});
}

class NotFoundError extends AppError {
  final String entity;
  final int? id;

  const NotFoundError({required this.entity, this.id});
}
