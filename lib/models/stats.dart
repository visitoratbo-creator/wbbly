/// Core attribute engine shared by Wizards, Witches, and Floppy Familiars.
/// Every combat equation in the game derives from exactly these five numbers.
class CoreStats {
  final int maxHealth;
  final int currentHealth;
  final double defense;     // flat reduction AND % scaling mitigation
  final double attack;      // raw output multiplier for spell equations
  final double cooldown;    // percentage-based cast speed modifier (1.0 = neutral)

  const CoreStats({
    required this.maxHealth,
    int? currentHealth,
    this.defense = 1.0,
    this.attack = 1.0,
    this.cooldown = 1.0,
  }) : currentHealth = currentHealth ?? maxHealth;

  CoreStats copyWith({
    int? maxHealth,
    int? currentHealth,
    double? defense,
    double? attack,
    double? cooldown,
  }) =>
      CoreStats(
        maxHealth: maxHealth ?? this.maxHealth,
        currentHealth: currentHealth ?? this.currentHealth,
        defense: defense ?? this.defense,
        attack: attack ?? this.attack,
        cooldown: cooldown ?? this.cooldown,
      );

  /// Effective damage after defense curve: diminishing returns past 0.5.
  double mitigate(double incoming) {
    final mitigation = defense / (1.0 + defense);
    return incoming * (1.0 - mitigation);
  }

  /// Actual cast interval for a spell with base [baseCooldownMs].
  int effectiveCooldown(int baseCooldownMs) =>
      (baseCooldownMs * (2.0 - cooldown)).round();
}