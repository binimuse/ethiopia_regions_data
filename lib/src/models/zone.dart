/// Ethiopian administrative [Zone] model (second-level division).
class Zone {
  /// Creates a [Zone] linked to a parent [Region] by [regionId].
  const Zone({
    required this.id,
    required this.name,
    required this.regionId,
    this.nameAm,
    this.metadata = const {},
  });

  /// Stable machine-readable identifier.
  final String id;

  /// Primary display name.
  final String name;

  /// Parent [Region.id].
  final String regionId;

  /// Optional localized label when available.
  final String? nameAm;

  /// Extensible metadata for future features (kebeles, search, geo).
  final Map<String, Object?> metadata;

  /// Deserializes a [Zone] from JSON.
  factory Zone.fromJson(Map<String, dynamic> json) {
    return Zone(
      id: json['id'] as String,
      name: json['name'] as String,
      regionId: json['regionId'] as String,
      nameAm: json['nameAm'] as String?,
      metadata: (json['metadata'] as Map?)?.cast<String, Object?>() ??
          const <String, Object?>{},
    );
  }

  /// Converts this [Zone] to JSON.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'regionId': regionId,
        if (nameAm != null) 'nameAm': nameAm,
        if (metadata.isNotEmpty) 'metadata': metadata,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Zone && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Zone($id: $name)';
}
