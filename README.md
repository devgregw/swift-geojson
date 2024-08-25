# swift-geojson ![Build status](https://github.com/devgregw/swift-geojson/actions/workflows/swift.yml/badge.svg)

`swift-geojson` is a simplisitic and cross-platform GeoJSON implementation in pure Swift and is largely based on [RFC 7946](https://datatracker.ietf.org/doc/html/rfc7946).

## Motifivation

`swift-geojson` is used in my repo [SPCApp](https://github.com/devgregw/SPCApp) to parse GeoJSON data from the National Weather Service. While MapKit provides [MKGeoJSONDecoder](https://developer.apple.com/documentation/mapkit/mkgeojsondecoder), it is unavailable on watchOS. My implementation is intended to provide a more Swifty syntax such as enums with associated values.

## Limitations

- `Feature` properties are currently coerced to strings.
- `bbox` and `crs` are currently not parsed.
- Foreign members as [defined in the RFC](https://datatracker.ietf.org/doc/html/rfc7946#section-6.1) are not currently parsed.

## Installation

Add `swift-geojson` with Swift Package Manager as you would any other package and import `GeoJSON`.

## Usage

Create an instance of `GeoJSONDecoder` and call `decode(_:from:)` with your GeoJSON `Data`. Since `GeoJSONDecoder` is a subclass of `JSONDecoder`, the existing `decode` functions still exist and are usable; however, the GeoJSON models provided in this package expect to be decoded by a `GeoJSONDecoder`. To simplify the call site, a `GeoJSONDecoder` contains an overload `decode(_:from:)` where the type argument is defaulted to `GeoJSONObject.self`. In practice, this function is called like `try GeoJSONDecoder().decode(from: myData)`. The decoder will return a case of `GeoJSONObject` corresponding to the top-level JSON object in the provided data. If the top-level type is a geometry object such as `Point` or `LineString`, the decoder will return `GeoJSONObject.geometry` with the the relevant geometry model provided in the associated value. `GeoJSONObject` contains two computed helper variables: `features` and `geometries`. `features` returns the provided array of features when `self` is `.featureCollection`. When `self` is `.feature`, `features` will return a single-element array containing the provided feature. Likewise, `geometries` works the same for the `.geometryCollection` and `.geometry` cases.
