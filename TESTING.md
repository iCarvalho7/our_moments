# Cenários de teste manual — Nossos Momentos

Roteiro pra validar as features construídas nesta leva. Marque ✅/❌ conforme for testando.

> **Antes de começar**
> - Rode com `fvm flutter run` (faça **hot restart**, tecla `R`, após puxar o código — mudou enum/DI).
> - Esteja **logado** e com uma **timeline** que tenha **vários momentos** (de datas e tipos diferentes; pelo menos um com foto).
> - Para reações/comentários funcionarem em produção: aplicar as **regras do Firestore** (`firestore.rules`) — veja o fim deste arquivo.

---

## 1. Reações e comentários (na edição do momento)
- [ ] Abra um momento existente (toque num card do feed) → role até **"Reações e comentários"**.
- [ ] Toque num **emoji** → ele aparece na lista de reações com contagem **1** e fica **destacado** no seletor.
- [ ] Toque **no mesmo emoji de novo** → a reação some (toggle de remoção). Contagem volta a zero/desaparece.
- [ ] Escreva um **comentário** e envie (ícone de enviar) → aparece na lista com o **seu e-mail** como autor; o campo limpa.
- [ ] **Segure** o seu comentário → abre o diálogo "Remover este comentário?" → confirme → ele some.
- [ ] (2 contas) Reaja/comente numa conta e veja aparecer **em tempo real** na outra (mesma timeline).
- [ ] **Momento novo** (ainda não salvo): a seção de reações/comentários **não** deve aparecer.

## 2. Contador "Juntos há…" (topo da timeline)
- [ ] Numa timeline **sem** data de relacionamento: aparece o banner coral **"Definir início do relacionamento"**.
- [ ] Toque nele → escolha uma data passada → o banner passa a mostrar **"Juntos há X anos, Y meses e Z dias"**.
- [ ] Feche e reabra a timeline → a data **persiste** (continua mostrando).
- [ ] Toque no banner de novo (ícone de calendário) → consegue **editar** a data.

## 3. Filtro por tipo
- [ ] Acima do feed, toque no chip **"Romântico"** → o feed mostra **só** momentos românticos; o agrupamento por data continua.
- [ ] Toque no chip selecionado de novo (ou em **"Todos"**) → volta a mostrar tudo.
- [ ] Escolha um tipo que **não tem** momentos → aparece **"Nenhum momento encontrado"**.

## 4. Busca
- [ ] Digite um trecho do **título** de um momento no campo de busca → o feed filtra na hora.
- [ ] Digite um trecho da **descrição** → também filtra.
- [ ] Combine **busca + filtro de tipo** → resultado respeita os dois.
- [ ] Busque algo inexistente → **"Nenhum momento encontrado"**. Limpe a busca → tudo volta.

## 5. Localização (mapa estilo app)
- [ ] Criar/editar momento → seção **"Onde foi"** → toque no ícone de **mapa** → abre o seletor.
- [ ] O **mapa segue o tema** do app (tiles claros no tema claro; troque o sistema p/ escuro e confira o mapa escuro), pino e botões em coral.
- [ ] **Buscar**: digite um lugar (3+ letras) → aparece uma **lista de sugestões** → toque numa → o mapa vai pro local e preenche o nome.
- [ ] **Arraste o mapa**: o pino central marca o ponto e o **nome do lugar é preenchido sozinho** (reverse-geocoding).
- [ ] Toque em **"minha localização"** (botão flutuante) → conceda a permissão → o mapa **pula pra sua posição** e preenche o nome.
- [ ] **Edite** o nome (ex.: *Nosso restaurante*) → **"Usar este local"** → volta ao form com o nome; digite mais no campo → continua editável.
- [ ] Salve → no feed o card mostra **📍 nome do lugar** abaixo da data.
- [ ] Reabra o picker de um momento que já tem local → abre **centrado no ponto salvo**.
- [ ] Negue a permissão de localização → toque em "minha localização" → aparece aviso (sem crash).
- [ ] Momento **sem** localização → o card **não** mostra o pin.

## 6. Favoritos
- [ ] No feed, toque no **coração** (canto superior direito do card) → ele fica **preenchido** (coral).
- [ ] Toque no chip **"Favoritos"** (topo) → o feed mostra **só** os favoritados.
- [ ] Toque no coração de um card pra **desfavoritar** → com o filtro "Favoritos" ativo, ele **sai** da lista.
- [ ] Feche e reabra a timeline → o estado de favorito **persiste**.
- [ ] Tocar no coração **não** deve abrir a tela de edição (só o resto do card abre).

## 7. Regressões (não pode ter quebrado)
- [ ] **Momentos antigos** aparecem (use o filtro de calendário → chip **"Tudo"**).
- [ ] **Criar** um momento novo (tipo + foto + data + título + descrição) → salva e aparece no feed.
- [ ] **Excluir** um momento (segurar o card → confirmar) → some.
- [ ] **Stories**: abra uma foto → toque na **direita** (próximo), **esquerda** (anterior), **segure** (pausa).
- [ ] App abre no **tema claro** por padrão.
- [ ] Agrupamento do feed por data ("Hoje/Ontem/Este mês/…") correto.

---

## Regras do Firestore (necessário pra #1 em produção)
As subcoleções `reactions`/`comments` **não herdam** as regras do doc pai. No Firebase Console, dentro do seu `match /moments/{momentId} { … }`, adicione:
```
match /{document=**} {
  allow read, write: if request.auth != null;
}
```
(ou deploye o `firestore.rules` versionado com `firebase deploy --only firestore:rules` — **substitui** as regras atuais, então revise antes.)
