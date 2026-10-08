class DomainEvent {
  DomainEvent({required this.code, required this.entityType, required this.entityId, this.companyId, this.actorId, this.actorName, this.payload = const {}, DateTime? occurredAt}) : occurredAt = occurredAt ?? DateTime.now().toUtc();
  final String code;
  final String entityType;
  final String entityId;
  final String? companyId;
  final String? actorId;
  final String? actorName;
  final Map<String, dynamic> payload;
  final DateTime occurredAt;
  @override
  String toString() => 'DomainEvent($code: $entityType/$entityId)';
}
