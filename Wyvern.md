# Wyvern.md — Guia do projeto **Nossos Momentos**

Guia para agentes de IA (e humanos) trabalharem neste repositório. Leia antes de mexer no código.

App Flutter de casal: registrar **momentos** (título, descrição, data, tipo, fotos/vídeos), organizados em **linhas do tempo** compartilhadas, com visualização em **stories**.

---

## 1. Setup & comandos

O projeto é **fixado via FVM** (`.fvmrc` → Flutter 3.44.1 / Dart 3.12). **Sempre** use o prefixo `fvm`:

```bash
fvm flutter pub get
fvm flutter analyze                 # deve terminar com "No issues found!"
fvm flutter run                     # rodar no device/emulador
fvm flutter build web               # rápido — bom pra confirmar compilação Dart
fvm flutter build apk --debug       # confirma os plugins nativos Android
```

- Antes de concluir qualquer tarefa de código, rode `fvm flutter analyze` e mantenha **zero issues**.
- `build web` é a forma mais rápida de validar que compila; `build apk` valida o lado Android.

---

## 2. Arquitetura

Clean Architecture modular. Cada feature em `lib/modules/<feature>/` com as camadas:

```
domain/        entidades, repositórios (abstratos), use_cases
infra/         models (json_serializable), data_sources (abstratos), repository impls
external/      implementações concretas (Firebase, file picker, etc.)
presenter/ |
presentation/  page (telas), widget(s), bloc (estado)
```

> Atenção: a camada de UI usa **dois nomes** dependendo do módulo: `presenter/` (moment, stories, time_line) e `presentation/` (login, signup, photos, settings). Siga o que já existe no módulo.

Módulos: `core`, `login`, `signup`, `moment`, `photos`, `settings`, `stories`, `time_line`.

### Estado: BLoC (`flutter_bloc`)
- Um `Bloc` por feature, com `part 'xxx_event.dart'` / `part 'xxx_state.dart'`.
- Estados/eventos são classes simples (sem Equatable na maioria — emitir nova instância sempre notifica).
- Telas usam `BlocProvider(create: (_) => getIt<XBloc>()..add(InitEvent()))` e `BlocBuilder`/`BlocConsumer`.

### Injeção de dependência: `injectable` + `get_it`
- Resolva com `getIt<T>()`. Registre com `@injectable` / `@Injectable(as: Interface)`.
- Providers de infra (coleções Firestore, FirebaseAuth) em `lib/di/modules/firebase_modules.dart` (`@module`).
- O grafo é **gerado** em `lib/di/injection.config.dart`.

> **Codegen (build_runner) — funcionando.** Para (re)gerar `injection.config.dart` e os `*.g.dart`:
> ```bash
> fvm dart run build_runner build --delete-conflicting-outputs
> ```
> Toolchain compatível: `analyzer 8.4`, `json_serializable 6.11`, `injectable_generator 2.9`, `injectable 2.6`, `build_runner 2.15` (SDK Dart `>=3.8`). Rode após mudar a estrutura de um model (`@JsonSerializable`) ou anotações de DI (`@injectable`/`@module`). Mudar só os helpers `_fromJson*`/`_toJson*` não exige regen.

---

## 3. Backend (Firebase)

- **Firestore**: coleções `moments` e `time_line` (via `withConverter` em `firebase_modules.dart`).
- **Firebase Storage**: mídia dos momentos em `moments_photo/<momentId>/<arquivo>`. Requer plano **Blaze** (no Spark dá `402`).
- **Firebase Auth**: e-mail/senha.

### Modelo de dados — cuidados
- Campo Firestore do timeline id é **`time_line_id`** (snake_case); no Dart é `timelineId` (`@JsonKey(name: 'time_line_id')`).
- `dateTime` é serializado como string com `DateFormat.YEAR_MONTH_DAY`.
- **`MomentType.value` é a string PERSISTIDA** (`'Ruim'`, `'Romantico'`, `'Bom'`) e é casada na leitura — **nunca** mude esses valores. Para texto de UI use **`MomentType.label`** (`'Romântico'` com acento). O parser `_fromJsonType` é tolerante (casa por value/label e cai num default), pra um registro ruim não derrubar a query inteira.
- `getMomentsByDate` busca **todos** os docs do timeline e filtra por data **em memória** (`isAfter(start) && isBefore(end)`, limites exclusivos). Um range amplo (ex.: 2000–2100) retorna tudo.

---

## 4. UI & Design System

Tudo em `lib/modules/core/utils/theme/app_theme.dart`. Identidade "romântica moderna": accent **coral**, tipografia **Inter**, claro **e** escuro. Default = **light** (`ThemeMode.light` no `main.dart`).

**Regras de estilo (importantes):**
- Cores: use `context.palette` (extensão → `AppPalette` por brilho). **Nunca** hardcode `Colors.black/white/grey` em UI — quebra o dark mode. (Exceção: telas imersivas como o viewer de stories, que são sempre escuras.)
- Texto: `Theme.of(context).textTheme.*` (displaySmall, headlineMedium, titleLarge/Medium/Small, bodyLarge/Medium/Small...).
- Tokens: `AppRadii` (card 20, button 16, input 14, pill 999), `AppShadows.soft(context)`, espaçadores `kSpacerHeight/Width{8,12,16,24,32}`.
- Cores por tipo de momento: `moment.type.colors(context)` → `MomentColors(bg, accent, onBg)`.

**Componentes reutilizáveis** (`core/presenter/widgets/`): `AppCard`, `PrimaryButton`, `BackgroundGradient` (use sempre dentro de algo com tamanho — ele se expande via `SizedBox.expand`), `PrimaryAppBar`, `CustomDeleteDialog`, `LoadingEffect` (shimmer). No time_line: `MemoryCard` (card de memória com foto/gradiente).

### Carregamento de imagens
- Mídia vem de URLs do Firebase Storage, exibidas com `Image.network`.
- **Web**: o bucket precisa de **CORS** configurado, senão dá `statusCode: 0` (o `curl` funciona, o navegador bloqueia). Configure com `gcloud storage buckets update gs://<bucket> --cors-file=cors.json`.
- Prefira sempre passar `errorBuilder` (degrada pra um placeholder/gradiente em vez de estourar erro).

---

## 5. Navegação

`AppRoute` (enum em `lib/modules/core/presenter/routes.dart`) define rotas nomeadas; navegue com `Navigator.pushNamed(context, AppRoute.x.tag)`.

---

## 6. Convenções

- **Strings de UI em português**, código e comentários em inglês.
- Imports: **relativos** dentro do mesmo módulo, **package:** entre módulos.
- Não use `BuildContext` após `await`/gap async sem checar `mounted` — capture o `bloc` antes (`final bloc = context.read<X>();`) e use ele no callback.
- Lints: `analysis_options.yaml` (flutter_lints). Mantenha o `analyze` limpo.

### Git / commits
- Branch default: `main`. Trabalhe em branch de feature/release (ex.: `release/2.0.0`).
- Commits **pequenos e lógicos**, mensagens em inglês no estilo Conventional Commits (`feat:`, `fix:`, `chore:`).
- Só faça commit/push quando o usuário pedir.
- Finalize a mensagem com o trailer:
  ```
  Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>
  ```

---

## 7. Armadilhas conhecidas (já mordemos)

- **Gradle "Java heap space" / cache corrompido**: se um build Android falhar com `metadata.bin` ilegível em `~/.gradle/caches/<ver>/transforms`, limpe essa pasta de transforms e rebuilde.
- **Mudar `MomentType.value`** quebra a desserialização de momentos existentes (ver §3).
- **`Expanded` dentro de `SingleChildScrollView`** estoura (altura ilimitada) — use `minLines`/altura fixa.
- **`BackgroundGradient` sem tamanho**: ele se auto-expande, mas precisa de constraints (Stack com outro filho dimensionado, `Positioned.fill`, ou `flexibleSpace` de AppBar).
```
