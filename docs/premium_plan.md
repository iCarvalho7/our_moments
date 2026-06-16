# Plano de Implementação — Premium / Freemium (RevenueCat)

> App: **Nossos Momentos** · Branch: `release/2.0.0`
> Billing escolhido: **RevenueCat** (`purchases_flutter`)
> Status: plano aprovado para revisão — **nenhum código escrito ainda**

---

## 1. Visão geral

Transformar o app num modelo **freemium**. Regra de ouro: o que cria hábito e
vínculo emocional fica grátis; o que aprofunda, embeleza ou escala vira premium.

**Premium é do casal, não do indivíduo.** A entidade `TimeLine` já é compartilhada
pelos dois parceiros (`emails`, `accentColor`, ...). É nela que penduramos o
entitlement: um paga → o doc da timeline desbloqueia → os dois veem premium.

---

## 2. O que é grátis vs. premium

### 🆓 Free (cria o hábito)
- Timeline compartilhada do casal
- Criar momentos com **até 3 fotos** + texto
- Contador "Juntos há…"
- Reações e comentários
- Filtro por tipo + busca
- **3 das 10** cores de tema
- Favoritos
- "Neste dia" (ver na tela)

### ⭐ Premium (aprofunda / embeleza / escala)
| Feature | Regra premium | Arquivo de encaixe |
|---|---|---|
| Fotos ilimitadas por momento | free = 3, premium = ∞ | `add_moment_page.dart` / `photos_container.dart` |
| Notas de voz (#13) | só premium | `moment/.../widget/audio_section.dart` |
| Todos os temas (#8) | free = 3 cores, premium = 10 | `settings_page.dart` (`_kAccentColors` / `_Swatch`) |
| Compartilhar sem marca d'água (#9) | free com marca, premium sem | `shareable_moment_card.dart` (~linhas 102-115) |
| Mapa dos momentos (#10) | só premium | entrada do `moments_map_page.dart` |
| Push "Neste dia" (#6) | só premium | `on_this_day_page.dart` + infra nova |
| Exportar memórias (PDF/álbum) | só premium | novo (fase posterior) |

> **Não travar:** reações, comentários, contador "Juntos há". São o coração viral.

---

## 3. Arquitetura do gating

```
Compra (App Store / Play) ──▶ RevenueCat confirma entitlement "premium"
                                          │
                  SyncEntitlementUseCase grava espelho em
                  Firestore: time_line/{id}.is_premium = true
                                          │
        PremiumService (singleton) é "amarrado" à timeline ativa
                                          │
            PremiumGate (UI) / use cases consultam can(feature)
                                          │
                       libera  ──ou──  mostra paywall
```

**Por que espelhar no Firestore?**
RevenueCat identifica só o **comprador**. Para o **parceiro** que não comprou também
desbloquear (e para funcionar offline), gravamos o resultado no doc da timeline.
Premium efetivo = `RevenueCat ativo (comprador)` **OU** `timeLine.isPremium (espelho)`.

---

## 4. Mudanças no domínio

### 4.1 `TimeLine` entity
`lib/modules/time_line/domain/entity/time_line.dart`
```dart
final bool isPremium;          // espelho do entitlement
final DateTime? premiumUntil;  // null = vitalício; senão expira

bool get isActivePremium =>
    isPremium && (premiumUntil == null || premiumUntil!.isAfter(DateTime.now()));
```

### 4.2 `TimeLineModel`
`lib/modules/time_line/infra/model/time_line_model.dart`
```dart
@JsonKey(name: 'is_premium', defaultValue: false)
@override
final bool isPremium;

@JsonKey(name: 'premium_until', fromJson: _dateFromJson, toJson: _dateToJson)
@override
final DateTime? premiumUntil;
```
Atualizar também o construtor, `super(...)`, e `fromEntity(...)`.
> Migração suave: docs antigos sem o campo viram `false` (defaultValue).

### 4.3 `PremiumFeature` enum
`lib/modules/core/premium/premium_feature.dart` — fonte única dos recursos travados:
`unlimitedPhotos, voiceNotes, allThemes, mapView, watermarkFree, onThisDayPush, export`
(cada um com `label` PT-BR para os locks/paywall).

### 4.4 `PremiumService` (`@lazySingleton`)
`lib/modules/core/premium/premium_service.dart` — centraliza TODA a regra:
```dart
void bind(TimeLine tl);              // TimeLineBloc chama no init/reload
bool get isPremium;                  // tl.isActivePremium
bool can(PremiumFeature f);          // por enquanto: == isPremium
int  get freePhotosPerMoment => 3;
int  get maxPhotosPerMoment => isPremium ? 1 << 30 : freePhotosPerMoment;
int  get freeThemeCount => 3;
```
> Mudar qualquer limite free = **1 arquivo**.

### 4.5 `PremiumGate` (widget)
`lib/modules/core/premium/widget/premium_gate.dart` — mostra `child` se liberado,
senão um CTA/cadeado que abre o paywall.

---

## 5. Camada RevenueCat (billing)

`lib/modules/premium/...` seguindo o padrão Clean Architecture do projeto:

- **pubspec:** adicionar `purchases_flutter` (RevenueCat).
- **domain/repository:** `PurchaseRepository` (`offerings()`, `purchase()`, `restore()`, `entitlementStatus()`).
- **infra/datasource:** implementação que fala com o SDK da RevenueCat.
- **domain/use_case:** `GetOfferingsUseCase`, `PurchaseUseCase`, `RestorePurchasesUseCase`, `SyncEntitlementUseCase` (grava o espelho no doc via o `updateTimeline` que já existe no datasource).
- **presenter:** `PremiumBloc` + `PaywallPage` (tela de assinatura).
- **init:** `Purchases.configure(...)` no `main.dart` com a API key.

### Configuração externa (você preenche)
- [ ] Criar conta/projeto na RevenueCat
- [ ] Produtos no App Store Connect (assinatura mensal, anual, vitalício)
- [ ] Produtos no Google Play Console
- [ ] Entitlement `premium` + Offering na RevenueCat
- [ ] API keys (iOS / Android) → colocar em config (placeholder no código)

---

## 6. Pontos de encaixe dos gates (já localizados no código)

| # | Local | O que muda |
|---|---|---|
| 1 | `add_moment_page.dart` / `photos_container.dart` | bloquear add acima de `maxPhotosPerMoment`, mostrar CTA |
| 2 | `audio_section.dart` | envolver botão de gravar em `PremiumGate(voiceNotes)` |
| 3 | `settings_page.dart` → `_Swatch` | cadeado nas cores além de `freeThemeCount` |
| 4 | `shareable_moment_card.dart` | watermark só `if (!can(watermarkFree))` |
| 5 | navegação p/ `moments_map_page.dart` | `PremiumGate(mapView)` |
| 6 | `on_this_day_page.dart` | push só premium (precisa infra de notificação) |

`PremiumService` é injetado no `TimeLineBloc`; `bind(timeLine)` é chamado no
`_init` e no `_handleReloadTimeline` (que já existe) para manter o singleton em dia.

---

## 7. Push "Neste dia" (#6) — infra de notificação

- `firebase_messaging ^15.2.5` **já está** no pubspec, mas **sem código consumindo**.
- Para o lembrete diário local, o ideal é `flutter_local_notifications` (agendamento
  local, sem servidor) disparando "Há 1 ano vocês…".
- Fica para a **Fase 3** (não bloqueia o resto).

---

## 8. Faseamento

### Fase 1 — Fundação (sem loja) ⬅️ começar aqui
- `PremiumFeature`, `PremiumService`, `PremiumGate`
- Campos `isPremium` / `premiumUntil` na entity + model
- `bind()` no `TimeLineBloc`
- Plugar **todos os gates de UI**
- `isPremium` setável manualmente (Firestore) para testar travado/destravado
- `build_runner` (regenera `.g.dart` + `injection.config.dart`)
- **Zero dependência externa.** Já dá pra ver e testar a experiência premium.

### Fase 2 — Billing real (RevenueCat)
- `purchases_flutter`, `PurchaseRepository` + use cases + datasource
- `PremiumBloc` + `PaywallPage`
- `Purchases.configure` no `main.dart`
- `SyncEntitlementUseCase` grava o espelho na timeline
- Restore de compras

### Fase 3 — Push "Neste dia"
- `flutter_local_notifications` + agendamento diário

---

## 9. Decisões de produto a confirmar

- [ ] Limites free: **3 fotos/momento**, **3 cores**, **marca d'água on**, **voz+mapa premium** — ok?
- [ ] Preços: mensal + anual (com desconto) + **vitalício** (funciona bem nesse nicho)?
- [ ] Marca d'água no free serve de marketing orgânico — manter?

---

## 10. Convenções respeitadas
- FVM em todos os comandos (`fvm flutter ...` / `fvm dart run ...`)
- Strings de UI em PT-BR, código/comentário em EN
- `fvm flutter analyze` limpo
- Imports relativos dentro do módulo, package entre módulos
- `build_runner` após mexer em model serializável / DI
- Trailer de commit: `Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>`
