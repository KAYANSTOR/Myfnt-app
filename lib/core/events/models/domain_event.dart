class DomainEvent {
  const DomainEvent({required this.code, required this.entityType, required this.entityId, this.companyId, this.actorId, this.actorName, this.payload = const {}, DateTime? occurredAt}) : _occurredAt = occurredAt;
  final String code;
  final String entityType;
  final String entityId;
  final String? companyId;
  final String? actorId;
  final String? actorName;
  final Map<String, dynamic> payload;
  final DateTime? _occurredAt;
  DateTime get occurredAt => _occurredAt ?? DateTime.now().toUtc();
  @override
  String toString() => 'DomainEvent($code: $entityType/$entityId)';
}
