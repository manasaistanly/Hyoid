abstract class Failure {
  final String message;
  Failure(this.message);
}

class ServerFailure extends Failure {
  ServerFailure(super.message);
}

class AuthFailure extends Failure {
  AuthFailure(super.message);
}

class NetworkFailure extends Failure {
  NetworkFailure() : super('No internet connection. Please try again.');
}

class UnknownFailure extends Failure {
  UnknownFailure([super.message = 'An unexpected error occurred.']);
}
