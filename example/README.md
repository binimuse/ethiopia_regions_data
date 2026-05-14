# ethiopia_regions_data example

Small Flutter app demonstrating cascading **region**, **zone**, and **woreda**
dropdowns using the `ethiopia_regions_data` package.

Run from this directory:

```bash
flutter run
```

JSON is always loaded through `rootBundle` and `EthiopiaRegionsData.fromJsonStrings`
(see `pubspec.yaml` assets). `EthiopiaRegionsData.load()` is not used because it
does not work in Flutter on Android/iOS.
