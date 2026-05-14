/// Stub implementation for platforms without `dart:io` file access.
///
/// The [pathUnderLib] argument is included only for error messaging parity
/// with the IO implementation.
Future<String> readPackageDatasetFile(String pathUnderLib) async {
  throw UnsupportedError(
    'readPackageDatasetFile("$pathUnderLib") is not supported on this '
    'platform. Use EthiopiaRegionsData.fromJsonStrings(...) with JSON loaded '
    'from assets or a remote source.',
  );
}
