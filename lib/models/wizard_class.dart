import 'stats.dart';
import 'magic_discipline.dart';

/// Distinct wizard classes with vastly different baseline stat allocations.
enum WizardClass {
  pyromancer(
    'Pyromancer',
    CoreStats(maxHealth: 90, defense: 0.8, attack: 1.35, cooldown: 1.0),
    MagicDiscipline.volatile,
    ['firebolt', 'flame_column', 'magma_wave', 'ember_shield'],
  ),
  chronomancer(
    'Chronomancer',
    CoreStats(maxHealth: 110, defense: 1.0, attack: 0.85, cooldown: 1.4),
    MagicDiscipline.chrono,
    ['time_snare', 'haste_field', 'rewind_step', 'stasis_bomb'],
  ),
  geomancer(
    'Geomancer',
    CoreStats(maxHealth: 150, defense: 1.6, attack: 0.9, cooldown: 0.85),
    MagicDiscipline.kinetic,
    ['stone_wall', 'quake_slam', 'boulder_toss', 'crystal_bloom'],
  ),
  stormcaller(
    'Stormcaller',
    CoreStats(maxHealth: 100, defense: 0.95, attack: 1.15, cooldown: 1.15),
    MagicDiscipline.gravitational,
    ['chain_lightning', 'tempest_pull', 'thunder_lance', 'static_ward'],
  );

  final String displayName;
  final CoreStats baseline;
  final MagicDiscipline discipline;
  final List<String> starterSpells;

  const WizardClass(this.displayName, this.baseline, this.discipline, this.starterSpells);
}