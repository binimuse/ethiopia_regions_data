/// Ethiopian [City] model for major urban centers and chartered cities.
class City {
  /// Creates a [City] associated with a [Region] via [regionId].
  const City({
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

  /// Associated [Region.id] (chartered cities may map to their own region).
  final String regionId;

  /// Optional localized label when available.
  final String? nameAm;

  /// Extensible metadata (population tier, coordinates, and so on).
  final Map<String, Object?> metadata;

  /// Deserializes a [City] from JSON.
  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'] as String,
      name: json['name'] as String,
      regionId: json['regionId'] as String,
      nameAm: json['nameAm'] as String?,
      metadata: (json['metadata'] as Map?)?.cast<String, Object?>() ??
          const <String, Object?>{},
    );
  }

  /// Converts this [City] to JSON.
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
      other is City && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'City($id: $name)';
}
