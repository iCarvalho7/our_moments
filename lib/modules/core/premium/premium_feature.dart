/// Premium tiers, ordered by how much they unlock.
///
/// [couple] is a superset of [individual]: the group plan (bound to the shared
/// [TimeLine]) covers every individual feature plus the shared ones, while
/// the individual plan (bound to the user) covers only the individual features.
/// Works for any group — couple, friends, open relationships, etc.
enum PremiumTier {
  free,
  individual,
  couple; // displayed as "Grupo" in the UI

  /// Higher rank covers everything a lower rank covers.
  int get rank {
    switch (this) {
      case PremiumTier.free:
        return 0;
      case PremiumTier.individual:
        return 1;
      case PremiumTier.couple:
        return 2;
    }
  }

  /// Whether this tier is enough to unlock something that requires [required].
  bool covers(PremiumTier required) => rank >= required.rank;
}

/// Single source of truth for the premium-locked features of the app.
///
/// Each value carries a PT-BR [label] used by the locks/CTAs (and, later, the
/// paywall) and a [minTier] — the lowest [PremiumTier] that unlocks it. Add a
/// feature here and gate it through [PremiumService].
enum PremiumFeature {
  unlimitedPhotos('Fotos ilimitadas por momento', PremiumTier.individual),
  voiceNotes('Recados de voz', PremiumTier.individual),
  allThemes('Todos os temas e cores', PremiumTier.individual),
  mapView('Mapa dos momentos', PremiumTier.individual),
  watermarkFree('Compartilhar sem marca d\'água', PremiumTier.individual),
  onThisDayPush('Notificação "Neste dia"', PremiumTier.individual),
  export('Exportar memórias', PremiumTier.individual),
  momentAuthorStats('Autoria e estatísticas do grupo', PremiumTier.couple),
  coupleCover('Foto de capa e apelidos', PremiumTier.couple),
  coupleBucketList('Lista de sonhos do grupo', PremiumTier.couple),
  specialDates('Datas especiais e lembretes', PremiumTier.couple),
  timeCapsule('Cápsula do tempo', PremiumTier.couple),
  yearInReview('Retrospectiva do ano', PremiumTier.couple),
  coupleBook('Livro de memórias em PDF', PremiumTier.couple);

  const PremiumFeature(this.label, this.minTier);

  /// PT-BR display name shown on locks and the paywall.
  final String label;

  /// Lowest tier that unlocks this feature.
  final PremiumTier minTier;
}
