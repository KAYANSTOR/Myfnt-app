import 'dart:async';
import 'models/domain_event.dart';

class EventRegistry {
  final _controller = StreamController<DomainEvent>.broadcast();
  Stream<DomainEvent> get stream => _controller.stream;
  void emit(DomainEvent event) { if (!_controller.isClosed) _controller.add(event); }
  Stream<DomainEvent> onEntityType(String entityType) => stream.where((event) => event.entityType == entityType);
  Stream<DomainEvent> onCode(String code) => stream.where((event) => event.code == code);
  Stream<DomainEvent> onPrefix(String prefix) => stream.where((event) => event.code.startsWith(prefix));
  Future<void> dispose() => _controller.close();
}
