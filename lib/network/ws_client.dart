import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Persistent WSS link to the authoritative gameplay server.
/// Endpoint: wss://gdvapi.alwaysdata.net/WobblyWizards/
class GameSocket {
  static const _url = 'wss://gdvapi.alwaysdata.net/WobblyWizards/';

  final WebSocketChannel _channel;
  final StreamController<Map<String, dynamic>> _inbound =
      StreamController.broadcast();
  final StreamController<void> _onDone = StreamController.broadcast();

  GameSocket._(this._channel) {
    _channel.stream
        .map((raw) {
          if (raw is String) return jsonDecode(raw);
          if (raw is List<int>) return jsonDecode(utf8.decode(raw));
          throw const FormatException('Non-text frame');
        })
        .where((d) => d is Map<String, dynamic>)
        .cast<Map<String, dynamic>>()
        // FIX 4: onDone requires a zero-argument `void Function()`.
        // StreamController<void>.add still needs one argument, so pass null.
        .listen(_inbound.add, onDone: () => _onDone.add(null));
  }

  static Future<GameSocket> connect({
    required String sessionToken,
    required String username,
  }) async {
    final ws = WebSocketChannel.connect(Uri.parse(_url));
    await ws.ready;
    final socket = GameSocket._(ws);
    // Handshake frame — server cross-validates token before admitting us.
    socket.send({
      'type': 'hello',
      'token': sessionToken,
      'username': username,
      'client_tick_hz': 20,
    });
    return socket;
  }

  Stream<Map<String, dynamic>> get inbound => _inbound.stream;
  Stream<void> get closed => _onDone.stream;

  void send(Map<String, dynamic> frame) =>
      _channel.sink.add(jsonEncode(frame));

  void sendInput(double x, double y, double z, double vx, double vy, double vz) =>
      send({'type': 'input', 'x': x, 'y': y, 'z': z, 'vx': vx, 'vy': vy, 'vz': vz});

  void sendChat(String scope, String text) => send({
        'type': 'chat',
        'scope': scope, // 'chat:global' | 'chat:local' | 'chat:battle'
        'text': text,
      });

  void sendDraftPick(int slot, int cardIndex) => send({
        'type': 'draft_pick',
        'slot': slot,
        'card_index': cardIndex,
      });

  void sendRound1Setup(List<String> spellBar, String familiarId) => send({
        'type': 'round1_setup',
        'spell_bar': spellBar,
        'familiar': familiarId,
      });

  Future<void> close() async {
    await _channel.sink.close();
    await _inbound.close();
    await _onDone.close();
  }
}