/// Ethiopian administrative [Woreda] model (third-level division).
class Woreda {
  /// Creates a [Woreda] linked to a parent [Zone] by [zoneId].
  const Woreda({
    required this.id,
    required this.name,
    required this.zoneId,
    this.nameAm,
    this.metadata = const {},
  });

  /// Stable machine-readable identifier.
  final String id;

  /// Primary display name.
  final String name;

  /// Parent [Zone.id].
  final String zoneId;

  /// Optional localized label when available.
  final String? nameAm;

  /// Extensible metadata for future features.
  final Map<String, Object?> metadata;

  /// Deserializes a [Woreda] from JSON.
  factory Woreda.fromJson(Map<String, dynamic> json) {
    return Woreda(
      id: json['id'] as String,
      name: json['name'] as String,
      zoneId: json['zoneId'] as String,
      nameAm: json['nameAm'] as String?,
      metadata: (json['metadata'] as Map?)?.cast<String, Object?>() ??
          const <String, Object?>{},
    );
  }

  /// Converts this [Woreda] to JSON.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'zoneId': zoneId,
        if (nameAm != null) 'nameAm': nameAm,
        if (metadata.isNotEmpty) 'metadata': metadata,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Woreda && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Woreda($id: $name)';
}
