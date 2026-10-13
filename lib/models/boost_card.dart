/// A Round/Loadout-style card chosen before each Bo3 round.
/// Each card targets exactly one of three scopes: a specific spell,
/// the active familiar, or the player's raw stats.
enum CardScope { spellEffect, familiarBoost, statChange }

class BoostCard {
  final String id;            // 'card_pyro_fervor_01'
  final String name;          // 'Pyro Fervor'
  final String description;   // shown in draft UI
  final CardScope scope;
  final Map<String, dynamic> payload;
  // payload examples:
  //  spellEffect:  { 'spell': 'firebolt', 'effect': 'burn', 'magnitude': 0.3 }
  //  familiarBoost: { 'stat': 'attack', 'delta': 0.25 }
  //  statChange:   { 'stat': 'cooldown', 'delta': 0.15 }

  const BoostCard({
    required this.id,
    required this.name,
    required this.description,
    required this.scope,
    required this.payload,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'desc': description,
        'scope': scope.name,
        'payload': payload,
      };

  factory BoostCard.fromJson(Map<String, dynamic> j) => BoostCard(
        id: j['id'] as String,
        name: j['name'] as String,
        description: j['desc'] as String,
        scope: CardScope.values.firstWhere((s) => s.name == j['scope']),
        payload: j['payload'] as Map<String, dynamic>,
      );
}