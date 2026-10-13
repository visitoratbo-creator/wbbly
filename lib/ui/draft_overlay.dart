import 'package:flutter/material.dart';
import '../models/boost_card.dart';

/// Server-authoritative draft state. The client only renders what
/// the Node.js DraftDistributor has offered.
class DraftState {
  final int round;                 // 1, 2, or 3
  final List<List<BoostCard>> slots; // 3 slots, each with 3 options
  final bool needsRound1Setup;     // true only on Round 1
  final List<String> availableSpells;
  final List<Map<String, dynamic>> availableFamiliars;
  final int timerMs;

  const DraftState({
    required this.round,
    required this.slots,
    required this.needsRound1Setup,
    required this.availableSpells,
    required this.availableFamiliars,
    required this.timerMs,
  });

  factory DraftState.fromJson(Map<String, dynamic> j) => DraftState(
        round: j['round'] as int,
        slots: (j['slots'] as List)
            .map((s) => (s as List)
                .map((c) => BoostCard.fromJson(c as Map<String, dynamic>))
                .toList())
            .toList(),
        needsRound1Setup: j['r1_setup'] as bool? ?? false,
        availableSpells:
            (j['spells'] as List? ?? const []).cast<String>(),
        availableFamiliars:
            (j['familiars'] as List? ?? const []).cast<Map<String, dynamic>>(),
        timerMs: j['timer'] as int? ?? 30000,
      );
}

/// Full-screen draft overlay stacked on top of the flutter_scene widget.
class DraftOverlay extends StatefulWidget {
  final DraftState state;
  final void Function(int slot, int cardIndex) onPick;
  final void Function(List<String> spellBar, String familiarId) onRound1Setup;

  const DraftOverlay({
    super.key,
    required this.state,
    required this.onPick,
    required this.onRound1Setup,
  });

  @override
  State<DraftOverlay> createState() => _DraftOverlayState();
}

class _DraftOverlayState extends State<DraftOverlay> {
  final List<int?> _picks = [null, null, null];
  final List<String?> _spellBar = List.filled(6, null);
  String? _familiarId;

  bool get _allPicked => _picks.every((p) => p != null);
  bool get _barComplete => _spellBar.every((s) => s != null);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            'Round ${widget.state.round} — Draft Your Boost Cards',
            style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int s = 0; s < 3; s++) ..._slotColumn(s),
              ],
            ),
          ),
          if (widget.state.needsRound1Setup) ...[
            const Divider(color: Colors.white24, height: 32),
            _round1SetupPanel(),
          ],
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _allPicked && (!widget.state.needsRound1Setup || _barComplete)
                ? _submit
                : null,
            child: const Text('Lock In'),
          ),
        ],
      ),
    );
  }

  List<Widget> _slotColumn(int slot) {
    return [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          children: [
            Text('Slot ${slot + 1}',
                style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            for (int c = 0; c < 3; c++)
              _cardTile(slot, c, widget.state.slots[slot][c]),
          ],
        ),
      ),
    ];
  }

  Widget _cardTile(int slot, int index, BoostCard card) {
    final selected = _picks[slot] == index;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: () => setState(() => _picks[slot] = index),
        child: Container(
          width: 220,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: selected ? Colors.deepPurple : Colors.grey.shade900,
            border: Border.all(
              color: selected ? Colors.amber : Colors.white24,
              width: selected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(card.name,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(card.description,
                  style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _round1SetupPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Configure Spell Bar (6 slots)',
            style: TextStyle(color: Colors.white, fontSize: 16)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (int i = 0; i < 6; i++)
              DropdownButton<String>(
                value: _spellBar[i],
                hint: Text('Slot ${i + 1}'),
                items: widget.state.availableSpells
                    .map((s) => DropdownMenuItem(
                          value: s,
                          child: Text(s.replaceAll('_', ' ')),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _spellBar[i] = v),
                dropdownColor: Colors.black87,
                style: const TextStyle(color: Colors.white),
              ),
          ],
        ),
        const SizedBox(height: 16),
        const Text('Choose Active Familiar',
            style: TextStyle(color: Colors.white, fontSize: 16)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final f in widget.state.availableFamiliars)
              ChoiceChip(
                label: Text(f['nickname'] as String? ?? f['species_id'] as String),
                selected: _familiarId == f['species_id'],
                onSelected: (_) =>
                    setState(() => _familiarId = f['species_id'] as String),
              ),
          ],
        ),
      ],
    );
  }

  void _submit() {
    for (int s = 0; s < 3; s++) {
      widget.onPick(s, _picks[s]!);
    }
    if (widget.state.needsRound1Setup && _barComplete && _familiarId != null) {
      widget.onRound1Setup(_spellBar.cast<String>(), _familiarId!);
    }
  }
}