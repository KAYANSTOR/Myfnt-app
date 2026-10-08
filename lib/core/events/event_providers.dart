import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'event_registry.dart';
import 'models/domain_event.dart';

final eventRegistryProvider = Provider<EventRegistry>((ref) { final registry = EventRegistry(); ref.onDispose(registry.dispose); return registry; });
final domainEventsProvider = StreamProvider<DomainEvent>((ref) => ref.watch(eventRegistryProvider).stream);
