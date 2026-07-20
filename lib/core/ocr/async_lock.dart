import 'dart:async';

/// Ensures async critical sections run one at a time.
class AsyncLock {
  Future<void> _tail = Future.value();

  Future<T> synchronized<T>(Future<T> Function() action) {
    final completer = Completer<void>();
    final previous = _tail;
    _tail = completer.future;

    return previous.then((_) => action()).whenComplete(completer.complete);
  }
}
