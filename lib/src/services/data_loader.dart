import 'package:ethiopia_regions_data/src/services/data_loader_stub.dart'
    if (dart.library.io) 'package:ethiopia_regions_data/src/services/data_loader_io.dart'
    as impl;

/// Reads a UTF-8 JSON file shipped under `lib/` in this package.
///
/// The [pathUnderLib] must be relative to this package's `lib/` directory,
/// for example `src/data/regions.json`.
Future<String> readPackageDatasetFile(String pathUnderLib) {
  return impl.readPackageDatasetFile(pathUnderLib);
}
