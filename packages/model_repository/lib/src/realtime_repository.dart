abstract class RealtimeRepository<M> {
  Stream<M> get messageStream;
}
