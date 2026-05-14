import 'dart:io';
import 'dart:isolate';

/// Reads a UTF-8 file from this package using `dart:io`.
///
/// The [pathUnderLib] is relative to the package `lib/` directory.
Future<String> readPackageDatasetFile(String pathUnderLib) async {
  final uri = Uri.parse('package:ethiopia_regions_data/$pathUnderLib');
  final resolved = await Isolate.resolvePackageUri(uri);
  if (resolved == null) {
    throw StateError('Could not resolve package URI: $uri');
  }
  return File.fromUri(resolved).readAsString();
}
