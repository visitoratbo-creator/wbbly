import 'package:flutter/material.dart';

class ChatMessage {
  final String author;
  final String text;
  final bool isSystem;
  const ChatMessage({required this.author, required this.text, this.isSystem = false});
}

/// Collapsible, non-intrusive chat window overlaying the 3D scene.
/// Scope selector: Global / Local (3D proximity) / Battle (locked Bo3 duel).
class ChatOverlay extends StatefulWidget {
  final List<ChatMessage> log;
  final void Function(String scope, String text)? onSend;

  const ChatOverlay({super.key, required this.log, this.onSend});

  @override
  State<ChatOverlay> createState() => _ChatOverlayState();
}

class _ChatOverlayState extends State<ChatOverlay> {
  bool _expanded = true;
  String _scope = 'chat:local';
  final _controller = TextEditingController();
  final _scroll = ScrollController();

  static const _scopeLabels = {
    'chat:global': 'Global',
    'chat:local': 'Local',
    'chat:battle': 'Battle',
  };

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      borderRadius: BorderRadius.circular(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header — tap to collapse/expand.
          InkWell(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Row(
                children: [
                  const Icon(Icons.forum, size: 16, color: Colors.white70),
                  const SizedBox(width: 8),
                  const Text('Chat', style: TextStyle(color: Colors.white)),
                  const Spacer(),
                  Icon(
                    _expanded ? Icons.expand_more : Icons.expand_less,
                    color: Colors.white70,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 220),
              child: ListView.builder(
                controller: _scroll,
                itemCount: widget.log.length,
                itemBuilder: (_, i) {
                  final m = widget.log[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    child: Text.rich(
                      TextSpan(children: [
                        TextSpan(
                          text: m.isSystem ? '[SYSTEM] ' : '${m.author}: ',
                          style: TextStyle(
                            color: m.isSystem
                                ? Colors.amberAccent
                                : Colors.lightBlueAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: m.text,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ]),
                      style: const TextStyle(fontSize: 13),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
              child: Row(
                children: [
                  DropdownButton<String>(
                    value: _scope,
                    items: _scopeLabels.entries
                        .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                        .toList(),
                    onChanged: (v) => setState(() => _scope = v!),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    dropdownColor: Colors.black87,
                    underline: const SizedBox.shrink(),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      enabled: widget.onSend != null,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: const InputDecoration(
                        isDense: true,
                        hintText: 'Message…',
                        hintStyle: TextStyle(color: Colors.white38),
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      ),
                      onSubmitted: _send,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, size: 18, color: Colors.white70),
                    onPressed: () => _send(_controller.text),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _send(String text) {
    if (text.trim().isEmpty || widget.onSend == null) return;
    widget.onSend!(_scope, text.trim());
    _controller.clear();
  }
}