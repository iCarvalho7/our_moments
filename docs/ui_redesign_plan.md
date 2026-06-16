# Plano de Redesign de UI — Nossos Momentos

> Branch: `release/2.0.0` · Referências: `img.png` (gift app coral), `img_1.png` (events roxo)
> Status: proposta para revisão — **nenhum código escrito ainda**
> Foco principal pedido: **tela de criar/editar momento**. Bônus: repensar todas as telas.

---

## 1. Linguagem visual (destilada das referências)

O que as duas referências têm em comum e vira nossa direção:

| Princípio | Como aplicamos |
|---|---|
| **Image-forward** | A foto vira protagonista (hero grande), não um anexo no meio do form |
| **Hero + sheet sobreposto** | Imagem no topo + card arredondado "subindo" por cima dela (img_1) |
| **Linhas de metadata** | Data, Local, Voz viram *rows* compactas com ícone + valor + chevron (img_1) |
| **CTA fixo embaixo** | Barra flutuante com botão pill de destaque (img.png "Pay Now") |
| **Botões de ação circulares** | Ações no accent, redondas, com sombra suave |
| **Headings display** | Títulos grandes e bold; respiro generoso |
| **Chips com underline** | Seletor de tipo/categoria com indicador animado |
| **Decoração suave de fundo** | Blobs/gradientes sutis, cantos super arredondados |

> Já temos a base certa no `app_theme.dart` (coral, `AppRadii`, `AppShadows.soft`,
> escala tipográfica). O redesign é **de composição/layout**, aproveitando os tokens.

### Tokens a adicionar (em `AppRadii` / novos)
- `AppRadii.sheet = 28` (cantos do sheet sobreposto)
- `AppRadii.hero = 28`
- Sombra "lift" mais forte para a barra de CTA flutuante (`AppShadows.lift(context)`)
- Helper de "blob" decorativo de fundo reaproveitável (`SoftBackdrop`)

---

## 2. ⭐ Tela Criar/Editar Momento (peça central)

### Problema atual
Hoje é uma **pilha vertical de seções rotuladas** (`_SectionLabel` + widget), com
cara de formulário plano. Fotos ficam perdidas no meio. Sem hierarquia visual, sem
protagonismo da imagem, CTA com borda simples no rodapé.

### Proposta — "hero photo + sheet de detalhes"

```
┌─────────────────────────────────────┐
│ ←                              ⤴     │  appbar transparente sobre a foto
│                                       │
│        ┌───────────────────┐          │
│        │                   │          │  HERO (tap = adicionar/trocar fotos)
│        │     FOTO 16:10     │          │  • 1ª foto = capa
│        │   (ou gradiente    │          │  • sem foto: gradiente do tipo +
│        │    do tipo)        │          │    ícone câmera "Adicionar fotos"
│        │            ● ● ○   │          │  • miniaturas/carrossel no rodapé
│        └───────────────────┘          │
│   ╭─────────────────────────────────╮ │  ← sheet arredondado SOBE por cima
│   │  [😍 Romântico][🙂 Bom][😕 Ruim] │ │  seletor de tipo = chips segmentados
│   │                                  │ │
│   │  Título grande aqui_             │ │  TextField estilo heading (display)
│   │                                  │ │
│   │  Conte como foi esse momento…    │ │  descrição multiline, leve
│   │                                  │ │
│   │  ┌─────────────────────────────┐ │ │
│   │  │ 📅  Quando      Hoje, 14:30 ›│ │ │  ROWS de metadata (estilo img_1)
│   │  │ 📍  Onde        Praia …     ›│ │ │  ícone + label + valor + chevron
│   │  │ 🎤  Recado de voz   Gravar  ›│ │ │  abrem picker/sheet
│   │  └─────────────────────────────┘ │ │
│   │                                  │ │
│   │  (edição) ❤️ Reações e comentários│ │  só no modo edição
│   ╰─────────────────────────────────╯ │
├───────────────────────────────────────┤
│   ╭───────────────────────────────╮   │  BARRA CTA flutuante (sticky)
│   │   Registrar eternamente   →   │   │  pill no accent, sombra lift
│   ╰───────────────────────────────╯   │  desabilitada até campos válidos
└───────────────────────────────────────┘
```

**Mudanças concretas:**
1. **Hero de fotos no topo** — `PhotosContainer` repensado como capa 16:10 com
   carrossel + indicadores; placeholder bonito por tipo quando vazio. Foto vira o
   centro da tela (resolve o "image-forward").
2. **Sheet sobreposto** — conteúdo do form num container `AppRadii.sheet`, com
   `margin-top` negativo encostando no hero (efeito da img_1).
3. **Tipo como chips segmentados** no topo do sheet (substitui `SelectTypeToggle`
   atual por algo mais enxuto, com indicador animado).
4. **Título como heading editável** (`headlineMedium`), descrição logo abaixo —
   menos "campos de formulário", mais "escrever uma memória".
5. **Data / Local / Voz viram rows compactas** (ícone + label + valor + `›`) num
   cartão único, em vez de 3 seções altas. Cada row abre o picker existente
   (`DateTimeSection`, `LocationPickerPage`, `AudioSection`) num bottom sheet.
6. **CTA flutuante** — `_SubmitButton` vira barra com sombra `lift`, pill no accent,
   ícone de seta; mantém o gate de `isAllFieldsFilled`.
7. **Reações/comentários** (modo edição) ganham um bloco próprio ao final do sheet.

> Lógica de bloc/estado **não muda** — só a camada de apresentação. Os widgets de
> picker (data, local, áudio, fotos) são reaproveitados, só reembalados.

---

## 3. Direção para as demais telas (consistência)

### 3.1 TimeLinePage (home) — `time_line/.../time_line_page.dart`
- AppBar com 4 ícones está sobrecarregada. **Proposta:** mover ações para uma
  **bottom nav flutuante** (ver §4) e deixar o topo respirável com o nome da
  timeline em heading display + "Juntos há" como faixa hero.
- Busca + chips de filtro: chips com underline animado (estilo img.png "Popular /
  Best Seller / Category").
- `MemoryCard` já é forte (hero + scrim) — manter, só alinhar raios/sombras aos
  novos tokens.

### 3.2 SelectTimeLinePage — seletor de timelines
- Cards image-forward: cada timeline com faixa de cor (accent) + avatares do casal,
  estilo "card de evento" da img_1. CTA "Criar" como card destacado com gradiente.

### 3.3 OnThisDayPage ("Neste dia")
- Cabeçalho hero com data de hoje em display + subtítulo afetivo.
- `_YearHeader` como "pílula" sticky; reusa `MemoryCard`.

### 3.4 MomentsMapPage (mapa)
- Card inferior selecionado → estilo sheet sobreposto arredondado (igual detalhe
  da img_1). Marcadores com sombra suave.

### 3.5 ShareMomentPage
- Já tem `ShareableMomentCard` polido. Adicionar **botão de baixar** além de
  compartilhar; barra CTA flutuante consistente. (Marca d'água amarra com o premium.)

### 3.6 SettingsPage ("Gerenciar acesso")
- Seções em cards arredondados claros (Personalizar / Quem tem acesso).
- Swatches de cor maiores; preview ao vivo num "mini-card" hero.

### 3.7 LoginPage / SignUpPage
- Manter o form centrado, mas com `SoftBackdrop` (blobs) + brand mark maior,
  inputs com o novo raio. Headings display.

### 3.8 StoryPage
- Já é fullscreen estilo Instagram — manter; só padronizar barras de progresso e
  botão fechar com os tokens.

### 3.9 LocationPickerPage
- Painel inferior vira sheet arredondado sobreposto; barra de busca flutuante com
  sombra lift.

---

## 4. Decisão de navegação (impacta várias telas)

Hoje **não há bottom nav** — tudo vive em ícones na AppBar. As duas referências usam
**bottom nav flutuante**. Proposta:

```
   ╭───────────────────────────────────────╮
   │   🏠        🗺️       ➕      🔔     ⚙️   │   nav flutuante (pill, sombra)
   ╰───────────────────────────────────────╯
   Início     Mapa    (criar)  Neste dia  Ajustes
```

- Centro = botão "+" em destaque (criar momento), estilo FAB embutido.
- Desafoga a AppBar da home e dá identidade moderna.
- **Alternativa mais conservadora:** manter AppBar, só refinar visual. (Menos obra.)

> Esta é a maior decisão estrutural. Default recomendado: **adotar a bottom nav**.

---

## 5. Componentes compartilhados novos (em `core`)

- `SoftBackdrop` — fundo com blobs/gradiente sutil reaproveitável.
- `OverlaySheet` — container do "sheet sobreposto" (margin-top negativo + raio).
- `MetadataRow` — linha ícone + label + valor + chevron (usada no momento, settings).
- `FloatingCtaBar` — barra de CTA fixa com sombra lift.
- `SegmentedChips` — seletor de chips com indicador animado (tipo, filtros).
- `AppBottomNav` — se adotarmos §4.

> Reutilizáveis garantem consistência e baixam o custo de cada tela.

---

## 6. Ordem de execução sugerida

1. **Tokens + componentes compartilhados** (§5) — base de tudo.
2. **Criar/Editar Momento** (§2) — o pedido principal, vitrine do novo estilo.
3. **TimeLinePage + bottom nav** (§3.1/§4) — a home, maior impacto percebido.
4. Demais telas em lote, seguindo os componentes (§3).

> Cada passo entra com `fvm flutter analyze` limpo e commit próprio.

---

## 7. Decisões a confirmar (suas)

- [ ] **Bottom nav flutuante** (§4) ou manter AppBar refinada?
- [ ] Começar **só pela tela de momento** ou já levar o novo estilo pra home junto?
- [ ] Manter a **identidade coral** atual ou quer explorar outra paleta base?
- [ ] Entregar como **plano + mockups** (atual) ou já partir para implementação da
      tela de momento depois do seu OK?

---

## 8. Convenções respeitadas
- FVM em todos os comandos · UI em PT-BR, código em EN · `analyze` limpo
- Sem mexer em bloc/estado/serialização — redesign é camada de apresentação
- Trailer de commit: `Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>`
```
