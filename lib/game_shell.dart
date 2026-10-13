import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart' as vm;
import 'package:wobbly_wizards/network/api_client.dart';
import 'package:wobbly_wizards/network/ws_client.dart';
import 'package:wobbly_wizards/ui/chat_overlay.dart';
import 'package:wobbly_wizards/ui/draft_overlay.dart';
import 'package:wobbly_wizards/ui/login_screen.dart';

class GameShell extends StatefulWidget {
  const GameShell({super.key});
  @override
  State<GameShell> createState() => _GameShellState();
}

class _GameShellState extends State<GameShell> {
  // ---- 3D scene state -----------------------------------------------------
  final Scene _scene = Scene();
  final Map<String, Node> _remotePlayers = {};
  final Map<String, Node> _projectiles = {};
  late PerspectiveCamera _camera;
  Node? _selfNode;
  bool _sceneReady = false;

  // ---- Network state ------------------------------------------------------
  ApiClient? _api;
  GameSocket? _socket;
  StreamSubscription? _netSub;

  // ---- Chat / Draft state -------------------------------------------------
  final List<ChatMessage> _chatLog = [];
  DraftState? _draftState;

  @override
  void initState() {
    super.initState();
    // Geometry/materials need the engine's static resources up first.
    Scene.initializeStaticResources().then((_) => _buildScene());
  }

  Future<void> _buildScene() async {
    // Ground plane.
    _scene.add(Node(
      mesh: Mesh(PlaneGeometry(200, 200), PhysicallyBasedMaterial()),
      position: const vm.Vector3(0, 0, 0),
    ));

    // Player capsule placeholder until GLB pipeline output is present.
    _selfNode = Node(
      mesh: Mesh(CapsuleGeometry(0.4, 1.2), PhysicallyBasedMaterial()),
      position: const vm.Vector3(0, 1, 0),
    );
    _scene.add(_selfNode!);

    // If assets/ contains wobbly_wizard.glb, the build hook compiled it to
    // flutter_scene_generated/ — load by its source path.
    try {
      final wizardModel = await loadScene('assets/models/wobbly_wizard.glb');
      _scene.add(wizardModel);
    } catch (_) {
      // Missing asset is non-fatal; primitives above carry the demo.
    }

    _camera = PerspectiveCamera(position: const vm.Vector3(0, 6, -10));
    if (mounted) setState(() => _sceneReady = true);
  }

  // ------------------------------------------------------------------ auth
  Future<void> _onAuthenticated(ApiClient api, String username) async {
    _api = api;
    _socket = await GameSocket.connect(
      sessionToken: api.sessionToken!,
      username: username,
    );
    _netSub = _socket!.inbound.listen(_onServerFrame);
  }

  void _onServerFrame(Map<String, dynamic> f) {
    switch (f['type'] as String) {
      case 'world_snapshot':
        _applyWorldSnapshot(f);
        break;
      case 'chat':
        setState(() => _chatLog.add(ChatMessage(
              author: f['from'] as String,
              text: f['text'] as String,
              isSystem: f['system'] as bool? ?? false,
            )));
        break;
      case 'draft_offer':
        setState(() => _draftState = DraftState.fromJson(f));
        break;
      case 'draft_closed':
        setState(() => _draftState = null);
        break;
      case 'battle_result':
        break;
    }
  }

  void _applyWorldSnapshot(Map<String, dynamic> snap) {
    final players = snap['players'] as List<dynamic>? ?? const [];
    for (final p in players.cast<Map<String, dynamic>>()) {
      final id = p['id'] as String;
      final pos = vm.Vector3(
        (p['x'] as num).toDouble(),
        (p['y'] as num).toDouble(),
        (p['z'] as num).toDouble(),
      );
      final node = _remotePlayers.putIfAbsent(
        id,
        () => Node(mesh: Mesh(CapsuleGeometry(0.4, 1.2), PhysicallyBasedMaterial())),
      );
      node.position = pos; // interpolated client-side between ticks
    }
    if (mounted) setState(() {});
  }

  // ------------------------------------------------------------------ build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Layer 0: the 3D world.
          if (_sceneReady)
            Positioned.fill(
              child: SceneView(_scene, camera: _camera),
            )
          else
            const Positioned.fill(child: ColoredBox(color: Colors.black)),

          // Layer 1: chat overlay, bottom-left, collapsible.
          Positioned(
            left: 12,
            bottom: 12,
            width: 360,
            child: ChatOverlay(
              log: _chatLog,
              onSend: _socket == null
                  ? null
                  : (scope, text) => _socket!.sendChat(scope, text),
            ),
          ),

          // Layer 2: draft overlay — full screen while a draft is active.
          if (_draftState != null)
            Positioned.fill(
              child: DraftOverlay(
                state: _draftState!,
                onPick: (slot, idx) => _socket?.sendDraftPick(slot, idx),
                onRound1Setup: (bar, fam) =>
                    _socket?.sendRound1Setup(bar, fam),
              ),
            ),

          // Layer 3: login gate until authenticated.
          if (_api == null)
            Positioned.fill(
              child: LoginScreen(onAuthenticated: _onAuthenticated),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _netSub?.cancel();
    _socket?.close();
    super.dispose();
  }
}