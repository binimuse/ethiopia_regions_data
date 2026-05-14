# Changelog

## 0.2.0

* Expanded **zones** and **woredas** JSON for **Oromia**, **Amhara**, **Afar**,
  **Tigray**, and related merge tooling (`tool/merge_*.dart` plus TSV sources).
* **Sheger** and **Bishoftu** (Oromia): zone `metadata.subCityPicker`, woreda
  `metadata.subCity`, and API helpers `EthiopiaRegionsData.zoneUsesSubCityPicker`,
  `getSubCities`, and `getWoredas(..., subCity:)`.
* **Tigray** Eastawi: numeric tabia column stored in ids only; woreda display
  names omit the leading code.
* Maintainer refactor: shared `slugForId` in `tool/merge_common.dart`; removed
  redundant `oromia_part*.tsv` split files.

## 0.1.1

* Document that `EthiopiaRegionsData.load` is for the Dart VM only; Flutter
  apps should use `EthiopiaRegionsData.fromJsonStrings` with `rootBundle`.
* Example app now loads JSON via assets on all platforms (fixes Android/iOS
  crash from `Isolate.resolvePackageUri`).

## 0.1.0

* Initial release with `Region`, `Zone`, `Woreda`, and `City` models.
* JSON-backed sample datasets and `EthiopiaRegionsData` repository API.
* Platform-aware loading via `dart:io` where available, with in-memory
  injection for Flutter Web and tests.
