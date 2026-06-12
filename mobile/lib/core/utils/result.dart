/// Discriminated union for operation outcomes.
/// Avoids throwing exceptions for expected failure paths (network errors,
/// validation failures). Use [AsyncValue] from Riverpod for UI state;
/// use [Result] in repositories and use-cases.
sealed class Result<T> {
  const Result();

  bool get isOk => this is Ok<T>;
  bool get isErr => this is Err<T>;

  T get value => (this as Ok<T>).data;
  Object get error => (this as Err<T>).failure;

  R when<R>({
    required R Function(T data) ok,
    required R Function(Object failure) err,
  }) =>
      switch (this) {
        Ok(:final data) => ok(data),
        Err(:final failure) => err(failure),
      };

  Result<U> map<U>(U Function(T data) transform) => switch (this) {
        Ok(:final data) => Ok(transform(data)),
        Err(:final failure) => Err(failure),
      };
}

final class Ok<T> extends Result<T> {
  const Ok(this.data);
  final T data;
}

final class Err<T> extends Result<T> {
  const Err(this.failure);
  final Object failure;
}
