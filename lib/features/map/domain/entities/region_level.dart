/// How wide the zone named in the map header is. Coarser levels are what a
/// future per-region leaderboard will group posts by.
enum RegionLevel {
  city,

  /// First administrative division: a canton in Switzerland, a région in
  /// France, a state in the US.
  region,
  country;

  /// Level matching the map zoom: the further out, the wider the zone.
  static RegionLevel fromZoom(double zoom) {
    if (zoom >= 12) return city;
    if (zoom >= 8) return region;
    return country;
  }
}
