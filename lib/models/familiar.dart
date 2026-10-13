import 'stats.dart';

/// A purified monster that fights alongside the player, Pokémon-style.
class Familiar {
  final String speciesId;   // 'ember_pup', 'tide_toad', ...
  final String nickname;
  final int purityLevel;    // 1..5, raised by purification ritual count
  final CoreStats stats;
  final bool isActive;      // the one currently carried

  const Familiar({
    required this.speciesId,
    required this.nickname,
    required this.purityLevel,
    required this.stats,
    this.isActive = false,
  });

  Map<String, dynamic> toJson() => {
        'species_id': speciesId,
        'nickname': nickname,
        'purity': purityLevel,
        'stats': {
          'hp': stats.maxHealth,
          'def': stats.defense,
          'atk': stats.attack,
          'cd': stats.cooldown,
        },
        'active': isActive,
      };

  factory Familiar.fromJson(Map<String, dynamic> j) => Familiar(
        speciesId: j['species_id'] as String,
        nickname: j['nickname'] as String? ?? 'Unnamed',
        purityLevel: (j['purity'] as num?)?.toInt() ?? 1,
        stats: CoreStats(
          maxHealth: (j['stats']['hp'] as num).toInt(),
          defense: (j['stats']['def'] as num).toDouble(),
          attack: (j['stats']['atk'] as num).toDouble(),
          cooldown: (j['stats']['cd'] as num).toDouble(),
        ),
        isActive: j['active'] as bool? ?? false,
      );
}