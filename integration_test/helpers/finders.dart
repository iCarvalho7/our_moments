import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Reusable finders for the E2E suite.
///
/// Key-based finders are preferred: the production widgets now expose stable
/// `ValueKey('key_<context>_<element>')` keys on the login/signup fields, the
/// primary action buttons, the moment & timeline forms, the bottom nav and the
/// map. Text-based finders remain only where we intentionally assert visible
/// (stable, pt-BR) copy — titles, banners and dialog headings.
///
/// Keep these in one place: if a key or label changes, only this file updates.
class F {
  const F._();

  // --- Login screen -----------------------------------------------------
  /// The N-th plain [TextField] on the current screen. Kept for the flows that
  /// still address fields positionally; prefer the key-based finders below.
  /// On the login page index 0 = e-mail, index 1 = password.
  static Finder textFieldAt(int index) => find.byType(TextField).at(index);

  static final Finder loginEmailField = find.byKey(const ValueKey('key_login_email_field'));
  static final Finder loginPasswordField = find.byKey(const ValueKey('key_login_password_field'));
  static final Finder loginButton = find.byKey(const ValueKey('key_login_submit_button'));
  static final Finder goToSignUp = find.byKey(const ValueKey('key_login_create_account_button'));

  // --- Sign-up screen ---------------------------------------------------
  static final Finder signUpTitle = find.text('Vamos começar');
  static final Finder signUpEmailField = find.byKey(const ValueKey('key_signup_email_field'));
  static final Finder signUpPasswordField = find.byKey(const ValueKey('key_signup_password_field'));
  static final Finder signUpConfirmPasswordField =
      find.byKey(const ValueKey('key_signup_confirm_password_field'));
  static final Finder signUpSubmit = find.byKey(const ValueKey('key_signup_submit_button'));
  /// Success bottom sheet shown after account creation; tap to go to login.
  static final Finder signUpSuccessLoginButton = find.text('Fazer login');

  // --- Home feed (NewSelectTimeLinePage) --------------------------------
  static final Finder feedAppBarTitle = find.text('Nossos Momentos');
  static final Finder navHome = find.byKey(const ValueKey('key_bottom_nav_home'));
  static final Finder navCreate = find.byKey(const ValueKey('key_bottom_nav_create'));
  static final Finder navMap = find.byKey(const ValueKey('key_bottom_nav_map'));
  static final Finder navMoments = find.byKey(const ValueKey('key_bottom_nav_moments'));
  static final Finder navSettings = find.byKey(const ValueKey('key_bottom_nav_settings'));

  // --- Timeline page nav (TimeLinePage) ---------------------------------
  static final Finder timelineNavCreate =
      find.byKey(const ValueKey('key_timeline_nav_create'));
  static final Finder timelineNavSettings =
      find.byKey(const ValueKey('key_timeline_nav_settings'));

  // --- Add / edit moment ------------------------------------------------
  static final Finder momentTitleField = find.byKey(const ValueKey('key_moment_form_title_field'));
  static final Finder momentBodyField = find.byKey(const ValueKey('key_moment_form_body_field'));
  static final Finder momentDateSelector = find.byKey(const ValueKey('key_moment_form_date_selector'));
  static final Finder momentTitleHint = find.text('Dê um título a esse momento');

  /// Both create and edit render the same keyed save button (only its label
  /// changes: "Registrar eternamente" vs "Salvar edição").
  static final Finder momentSave = find.byKey(const ValueKey('key_moment_form_save_button'));
  static final Finder momentSaveNew = momentSave;
  static final Finder momentSaveEdit = momentSave;

  /// Delete icon in the moment form app bar (only visible when editing).
  static final Finder momentDeleteButton =
      find.byKey(const ValueKey('key_moment_delete_button'));
  static final Finder momentDeleteConfirmTitle = find.text('Deletar momento');
  static final Finder momentDeleteConfirmButton =
      find.byKey(const ValueKey('key_moment_delete_confirm_button'));

  /// A mood/type chip on the moment form, targeted by its persisted
  /// [MomentType] value (e.g. 'Bom', 'Ruim', 'Romantico').
  static Finder momentTypeChip(String typeValue) =>
      find.byKey(ValueKey('key_moment_type_$typeValue'));

  /// The timeline picker that pops up when the account can edit more than one
  /// timeline (title of the bottom sheet).
  static final Finder timelinePickerSheet = find.text('Em qual história?');

  // --- Timeline ---------------------------------------------------------
  static final Finder createTimelineCard = find.text('Criar nova história');
  static final Finder policySheetTitle = find.text('Nova história');
  static final Finder createTimelineConfirm =
      find.byKey(const ValueKey('key_timeline_create_confirm_button'));
  static final Finder relationshipDateCta =
      find.byKey(const ValueKey('key_timeline_start_date_button'));
  static final Finder togetherLabel = find.text('Juntos há');
  static final Finder timelineSettingsAppBar = find.text('Gerenciar acesso');
  static final Finder timelineNameField =
      find.byKey(const ValueKey('key_timeline_form_name_field'));
  static final Finder saveTimelineChanges =
      find.byKey(const ValueKey('key_timeline_form_save_button'));
  static final Finder deleteTimelineButton = find.text('Deletar história');
  static final Finder deleteTimelineSheetTitle = find.text('Deletar história?');
  static final Finder continueButton = find.widgetWithText(ElevatedButton, 'Continuar');
  static final Finder deleteConfirmButton =
      find.byKey(const ValueKey('key_timeline_delete_confirm_button'));

  // --- Map --------------------------------------------------------------
  static final Finder mapView = find.byKey(const ValueKey('key_map_view'));

  // key_bottom_nav_map → MomentsMapPage (requires an active timeline).
  static final Finder mapTitle = find.text('Mapa dos momentos');
  static final Finder mapEmpty = find.text('Nenhum momento com localização');

  // key_bottom_nav_moments (navMoments) → AllTimelinesMapPage (always available).
  static final Finder allTimelinesMapTitle = find.text('Todos os momentos');
  static final Finder allTimelinesMapEmpty = find.text('Nenhum momento ainda');

  static final Finder mapFilterAll = find.text('Todos');
  static final Finder mapOpenMoment = find.byKey(const ValueKey('key_map_open_moment_button'));

  /// A moment pin on the map, targeted by its moment id.
  static Finder mapMarker(String momentId) =>
      find.byKey(ValueKey('key_map_marker_$momentId'));

  /// A [TextField] located by the hint text it shows while empty. Robust way to
  /// target one specific field on a screen that has several.
  static Finder fieldByHint(String hint) =>
      find.ancestor(of: find.text(hint), matching: find.byType(TextField));

  // --- Account settings -------------------------------------------------
  static final Finder accountTitle = find.text('Minha conta');
  static final Finder logoutButton = find.text('Sair da conta');
  static final Finder deleteAccountButton = find.text('Excluir minha conta');

  /// Finds a moment feed card / list item by the moment title it displays.
  /// Uses a plain Text widget predicate to avoid matching the EditableText
  /// inside the moment form field (which has the same content while editing).
  static Finder momentByTitle(String title) => find.byWidgetPredicate(
    (w) => w is Text && w.data == title,
  );
}
