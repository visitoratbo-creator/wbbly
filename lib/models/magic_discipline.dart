/// Core logic flags configuring casting patterns.
enum MagicDiscipline {
  kinetic,      // knockback — applies impulse to rigid targets
  gravitational,// pull — drags entities toward the caster
  volatile,     // explosive — AoE burst on impact
  chrono;       // speed — haste/slow time dilation bubbles
}