/// Ethiopian administrative [Region] model.
///
/// Designed for forward compatibility: optional localized names and an
/// extensible [metadata] map for future fields (for example geolocation).
class Region {
  /// Creates a [Region] with required identifiers and optional metadata.
  const Region({
    required this.id,
    required this.name,
    this.nameAm,
    this.metadata = const {},
  });

  /// Stable machine-readable identifier (for example `oromia`).
  final String id;

  /// Primary display name (typically English or Latin script).
  final String name;

  /// Optional Amharic or other localized label when available.
  final String? nameAm;

  /// Arbitrary key-value metadata (for example `latitude`, `searchTokens`).
  final Map<String, Object?> metadata;

  /// Deserializes a [Region] from JSON produced by this package's datasets.
  factory Region.fromJson(Map<String, dynamic> json) {
    return Region(
      id: json['id'] as String,
      name: json['name'] as String,
      nameAm: json['nameAm'] as String?,
      metadata: (json['metadata'] as Map?)?.cast<String, Object?>() ??
          const <String, Object?>{},
    );
  }

  /// Converts this [Region] to JSON suitable for persistence or debugging.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        if (nameAm != null) 'nameAm': nameAm,
        if (metadata.isNotEmpty) 'metadata': metadata,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Region && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Region($id: $name)';
}
