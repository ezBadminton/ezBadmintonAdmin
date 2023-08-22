enum CourtNumberingType {
  /// Number all courts of all gyms consecutively
  /// while sorting the gyms by name alphabetically
  global,

  /// Number all courts of the gym consecutively
  gymOnly,
}

enum CourtCountingType {
  /// Skip unused court slots when counting courts
  skipUnused,

  /// Count unused court slots when counting courts
  countAll,
}
