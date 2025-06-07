import 'dart:async';
import 'dart:convert';

import 'package:model_repository/src/realtime_repository.dart';
import 'package:pocketbase/pocketbase.dart';

class PocketbaseRealtimeRepository<M> extends RealtimeRepository<M> {
  PocketbaseRealtimeRepository({
    required this.pocketBase,
    required this.topic,
    required M Function(Map<String, dynamic>) constructor,
  })  : _controller = StreamController.broadcast(),
        _constructor = constructor {
    pocketBase.realtime.subscribe(topic, _handleMessage);
  }

  final PocketBase pocketBase;
  final String topic;
  final M Function(Map<String, dynamic>) _constructor;

  final StreamController<M> _controller;
  @override
  Stream<M> get messageStream => _controller.stream;

  void _handleMessage(Jsonable message) {
    Map<String, dynamic> messageJson = message.toJson();
    String payloadJsonString = messageJson["data"];
    Map<String, dynamic> payloadJson =
        jsonDecode(payloadJsonString) as Map<String, dynamic>;
    M realtimeMessage = _constructor(payloadJson);

    _controller.add(realtimeMessage);
  }
}
