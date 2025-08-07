enum QueueMode {
  /// Match starting and court assignment are done manually.
  manual,

  /// The match starting is done manually and the courts are assigned
  /// automatically. The first available court is chosen.
  autoCourtAssignment,

  /// The matches are automatically started as soon as a court becomes available
  /// and the players had their minimum rest time.
  ///
  /// The matches are ordered in a round robin from all competitions running
  /// in parallel.
  auto,
}
