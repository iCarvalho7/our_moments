// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:cloud_firestore/cloud_firestore.dart' as _i974;
import 'package:file_picker/file_picker.dart' as _i388;
import 'package:firebase_auth/firebase_auth.dart' as _i59;
import 'package:firebase_remote_config/firebase_remote_config.dart' as _i627;
import 'package:firebase_storage/firebase_storage.dart' as _i457;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../modules/core/feature_toggles/feature_toggle_manager.dart' as _i568;
import '../modules/core/premium/premium_service.dart' as _i423;
import '../modules/login/data/data_source/auth_remote_data_source.dart'
    as _i283;
import '../modules/login/data/external/firebase_auth_remote_data_source.dart'
    as _i678;
import '../modules/login/data/repository/auth_repository_impl.dart' as _i401;
import '../modules/login/domain/repository/auth_repository.dart' as _i884;
import '../modules/login/domain/use_case/is_user_authenticated_use_case.dart'
    as _i393;
import '../modules/login/domain/use_case/sign_in_use_case.dart' as _i518;
import '../modules/login/presentation/bloc/login_bloc.dart' as _i260;
import '../modules/moment/domain/repository/moment_repository.dart' as _i980;
import '../modules/moment/domain/use_case/delete_moments_use_case.dart'
    as _i183;
import '../modules/moment/domain/use_case/get_moments_use_case.dart' as _i589;
import '../modules/moment/domain/use_case/register_moments_use_case.dart'
    as _i663;
import '../modules/moment/domain/use_case/update_moment_use_case.dart' as _i272;
import '../modules/moment/external/firebase/firebase_moments_data_source.dart'
    as _i1056;
import '../modules/moment/infra/data_source/moments_data_source.dart' as _i771;
import '../modules/moment/infra/models/moment_model.dart' as _i797;
import '../modules/moment/infra/repository/register_moment_repository_impl.dart'
    as _i775;
import '../modules/moment/interactions/domain/repository/interactions_repository.dart'
    as _i323;
import '../modules/moment/interactions/domain/use_case/add_comment_use_case.dart'
    as _i753;
import '../modules/moment/interactions/domain/use_case/add_reaction_use_case.dart'
    as _i426;
import '../modules/moment/interactions/domain/use_case/remove_comment_use_case.dart'
    as _i937;
import '../modules/moment/interactions/domain/use_case/remove_reaction_use_case.dart'
    as _i606;
import '../modules/moment/interactions/domain/use_case/watch_comments_use_case.dart'
    as _i1067;
import '../modules/moment/interactions/domain/use_case/watch_reactions_use_case.dart'
    as _i787;
import '../modules/moment/interactions/external/firebase/firebase_interactions_data_source.dart'
    as _i832;
import '../modules/moment/interactions/infra/data_source/interactions_data_source.dart'
    as _i271;
import '../modules/moment/interactions/infra/repository/interactions_repository_impl.dart'
    as _i737;
import '../modules/moment/interactions/presenter/bloc/interactions_bloc.dart'
    as _i315;
import '../modules/moment/presenter/bloc/add_or_edit_moment_bloc.dart' as _i321;
import '../modules/notifications/domain/repository/notification_repository.dart'
    as _i727;
import '../modules/notifications/infra/data_source/local_notification_data_source.dart'
    as _i674;
import '../modules/notifications/infra/data_source/notification_preference_store.dart'
    as _i374;
import '../modules/notifications/infra/repository/notification_repository_impl.dart'
    as _i894;
import '../modules/notifications/notification_service.dart' as _i821;
import '../modules/photos/domain/repository/photos_repository.dart' as _i179;
import '../modules/photos/domain/use_case/delete_all_photos_from_moment_use_case.dart'
    as _i522;
import '../modules/photos/domain/use_case/delete_photo_use_case.dart' as _i271;
import '../modules/photos/domain/use_case/get_media_use_case.dart' as _i465;
import '../modules/photos/domain/use_case/upload_photo_use_case.dart' as _i262;
import '../modules/photos/external/file_picker_data_source.dart' as _i370;
import '../modules/photos/external/firebase_storage_photo_data_source.dart'
    as _i320;
import '../modules/photos/infra/data_source/photo_data_source.dart' as _i592;
import '../modules/photos/infra/repository/photos_repository_impl.dart'
    as _i724;
import '../modules/photos/presentation/bloc/photos_bloc.dart' as _i876;
import '../modules/premium/domain/repository/purchase_repository.dart' as _i248;
import '../modules/premium/domain/use_case/get_entitlement_status_use_case.dart'
    as _i1036;
import '../modules/premium/domain/use_case/get_offerings_use_case.dart'
    as _i458;
import '../modules/premium/domain/use_case/present_customer_center_use_case.dart'
    as _i7;
import '../modules/premium/domain/use_case/present_paywall_use_case.dart'
    as _i915;
import '../modules/premium/domain/use_case/purchase_use_case.dart' as _i844;
import '../modules/premium/domain/use_case/restore_purchases_use_case.dart'
    as _i771;
import '../modules/premium/domain/use_case/sync_entitlement_use_case.dart'
    as _i1047;
import '../modules/premium/domain/use_case/sync_user_entitlement_use_case.dart'
    as _i774;
import '../modules/premium/entitlement_sync_service.dart' as _i166;
import '../modules/premium/infra/data_source/purchase_data_source.dart'
    as _i1025;
import '../modules/premium/infra/repository/purchase_repository_impl.dart'
    as _i226;
import '../modules/premium/presenter/bloc/premium_bloc.dart' as _i99;
import '../modules/settings/domain/use_case/add_email_use_case.dart' as _i619;
import '../modules/settings/domain/use_case/delete_account_use_case.dart'
    as _i461;
import '../modules/settings/domain/use_case/delete_email_use_case.dart'
    as _i275;
import '../modules/settings/domain/use_case/get_current_user_use_case.dart'
    as _i1069;
import '../modules/settings/domain/use_case/reauthenticate_use_case.dart'
    as _i734;
import '../modules/settings/presentation/bloc/settings_bloc.dart' as _i970;
import '../modules/signup/domain/sign_up_use_case.dart' as _i480;
import '../modules/signup/presentation/bloc/sign_up_bloc.dart' as _i773;
import '../modules/stories/presenter/bloc/story_bloc.dart' as _i211;
import '../modules/time_line/bucket_list/domain/repository/bucket_list_repository.dart'
    as _i258;
import '../modules/time_line/bucket_list/domain/use_case/add_bucket_item_use_case.dart'
    as _i409;
import '../modules/time_line/bucket_list/domain/use_case/remove_bucket_item_use_case.dart'
    as _i49;
import '../modules/time_line/bucket_list/domain/use_case/toggle_bucket_item_use_case.dart'
    as _i355;
import '../modules/time_line/bucket_list/domain/use_case/watch_bucket_list_use_case.dart'
    as _i768;
import '../modules/time_line/bucket_list/external/firebase/firebase_bucket_list_data_source.dart'
    as _i865;
import '../modules/time_line/bucket_list/infra/data_source/bucket_list_data_source.dart'
    as _i631;
import '../modules/time_line/bucket_list/infra/repository/bucket_list_repository_impl.dart'
    as _i326;
import '../modules/time_line/bucket_list/presenter/bloc/bucket_list_bloc.dart'
    as _i209;
import '../modules/time_line/couple_book/couple_book_service.dart' as _i200;
import '../modules/time_line/domain/repository/time_line_repository.dart'
    as _i184;
import '../modules/time_line/domain/use_case/create_time_line_use_case.dart'
    as _i283;
import '../modules/time_line/domain/use_case/delete_time_line_use_case.dart'
    as _i1037;
import '../modules/time_line/domain/use_case/get_month_use_case.dart' as _i341;
import '../modules/time_line/domain/use_case/get_time_line_from_email_use_case.dart'
    as _i783;
import '../modules/time_line/domain/use_case/get_time_line_from_id_use_case.dart'
    as _i13;
import '../modules/time_line/domain/use_case/get_year_use_case.dart' as _i970;
import '../modules/time_line/domain/use_case/logout_use_case.dart' as _i44;
import '../modules/time_line/domain/use_case/update_access_levels_use_case.dart'
    as _i711;
import '../modules/time_line/domain/use_case/update_couple_header_use_case.dart'
    as _i339;
import '../modules/time_line/domain/use_case/update_relationship_end_date_use_case.dart'
    as _i1065;
import '../modules/time_line/domain/use_case/update_relationship_start_date_use_case.dart'
    as _i759;
import '../modules/time_line/domain/use_case/update_time_line_details_use_case.dart'
    as _i740;
import '../modules/time_line/infra/data_source/time_line_data_source.dart'
    as _i1061;
import '../modules/time_line/infra/model/time_line_model.dart' as _i452;
import '../modules/time_line/infra/repository/time_line_repository_impl.dart'
    as _i294;
import '../modules/time_line/presenter/bloc/all_timelines_map_bloc.dart'
    as _i981;
import '../modules/time_line/presenter/bloc/select_time_line_bloc.dart' as _i11;
import '../modules/time_line/presenter/bloc/time_line_bloc.dart' as _i716;
import '../modules/time_line/special_dates/domain/repository/special_dates_repository.dart'
    as _i1007;
import '../modules/time_line/special_dates/domain/use_case/add_special_date_use_case.dart'
    as _i1005;
import '../modules/time_line/special_dates/domain/use_case/remove_special_date_use_case.dart'
    as _i337;
import '../modules/time_line/special_dates/domain/use_case/watch_special_dates_use_case.dart'
    as _i789;
import '../modules/time_line/special_dates/external/firebase/firebase_special_dates_data_source.dart'
    as _i337;
import '../modules/time_line/special_dates/infra/data_source/special_dates_data_source.dart'
    as _i591;
import '../modules/time_line/special_dates/infra/repository/special_dates_repository_impl.dart'
    as _i929;
import '../modules/time_line/special_dates/presenter/bloc/special_dates_bloc.dart'
    as _i895;
import '../modules/time_line/time_capsule/domain/repository/time_capsule_repository.dart'
    as _i688;
import '../modules/time_line/time_capsule/domain/use_case/add_time_capsule_use_case.dart'
    as _i961;
import '../modules/time_line/time_capsule/domain/use_case/remove_time_capsule_use_case.dart'
    as _i720;
import '../modules/time_line/time_capsule/domain/use_case/watch_time_capsules_use_case.dart'
    as _i422;
import '../modules/time_line/time_capsule/external/firebase/firebase_time_capsule_data_source.dart'
    as _i674;
import '../modules/time_line/time_capsule/infra/data_source/time_capsule_data_source.dart'
    as _i333;
import '../modules/time_line/time_capsule/infra/repository/time_capsule_repository_impl.dart'
    as _i801;
import '../modules/time_line/time_capsule/presenter/bloc/time_capsule_bloc.dart'
    as _i430;
import '../modules/user/domain/repository/user_premium_repository.dart'
    as _i878;
import '../modules/user/domain/use_case/get_user_premium_use_case.dart'
    as _i338;
import '../modules/user/infra/data_source/user_premium_data_source.dart'
    as _i913;
import '../modules/user/infra/model/user_premium_model.dart' as _i372;
import '../modules/user/infra/repository/user_premium_repository_impl.dart'
    as _i243;
import 'modules/app_modules.dart' as _i1023;
import 'modules/firebase_modules.dart' as _i279;

// initializes the registration of main-scope dependencies inside of GetIt
_i174.GetIt $initGetIt(
  _i174.GetIt getIt, {
  String? environment,
  _i526.EnvironmentFilter? environmentFilter,
}) {
  final gh = _i526.GetItHelper(getIt, environment, environmentFilter);
  final appModules = _$AppModules();
  final firebaseModule = _$FirebaseModule();
  gh.factory<_i388.FilePicker>(() => appModules.filePicker);
  gh.factory<_i59.FirebaseAuth>(() => firebaseModule.firebaseAuth);
  gh.factory<_i627.FirebaseRemoteConfig>(() => firebaseModule.remoteConfig);
  gh.factory<_i211.StoryBloc>(() => _i211.StoryBloc());
  gh.factory<_i200.CoupleBookService>(() => const _i200.CoupleBookService());
  gh.factory<_i341.GetMonthUseCase>(() => _i341.GetMonthUseCase());
  gh.factory<_i970.GetYearUseCase>(() => _i970.GetYearUseCase());
  gh.lazySingleton<_i423.PremiumService>(() => _i423.PremiumService());
  gh.lazySingleton<_i568.FeatureToggleManager>(
    () => _i568.FeatureToggleManager(gh<_i627.FirebaseRemoteConfig>()),
  );
  gh.factory<_i974.CollectionReference<_i797.MomentModel>>(
    () => firebaseModule.momentsDBRef,
    instanceName: 'momentsDBParam',
  );
  gh.factory<_i974.CollectionReference<Map<String, dynamic>>>(
    () => firebaseModule.momentsRawCollectionRef,
    instanceName: 'momentsRawCollectionParam',
  );
  gh.factory<_i974.CollectionReference<Map<String, dynamic>>>(
    () => firebaseModule.timeLineRawCollectionRef,
    instanceName: 'timeLineRawCollectionParam',
  );
  gh.factory<_i457.Reference>(
    () => firebaseModule.momentsPhotoRef,
    instanceName: 'photosStorage',
  );
  gh.factory<_i374.NotificationPreferenceStore>(
    () => _i374.SharedPrefsNotificationPreferenceStore(),
  );
  gh.factory<_i333.TimeCapsuleDataSource>(
    () => _i674.FirebaseTimeCapsuleDataSource(
      gh<_i974.CollectionReference<Map<String, dynamic>>>(
        instanceName: 'timeLineRawCollectionParam',
      ),
    ),
  );
  gh.factory<_i271.InteractionsDataSource>(
    () => _i832.FirebaseInteractionsDataSource(
      gh<_i974.CollectionReference<Map<String, dynamic>>>(
        instanceName: 'momentsRawCollectionParam',
      ),
    ),
  );
  gh.factory<_i974.CollectionReference<_i372.UserPremiumModel>>(
    () => firebaseModule.usersDbRef,
    instanceName: 'users',
  );
  gh.factory<_i631.BucketListDataSource>(
    () => _i865.FirebaseBucketListDataSource(
      gh<_i974.CollectionReference<Map<String, dynamic>>>(
        instanceName: 'timeLineRawCollectionParam',
      ),
    ),
  );
  gh.factory<_i1025.PurchaseDataSource>(
    () => _i1025.RevenueCatPurchaseDataSourceImpl(),
  );
  gh.factory<_i370.FilePickerDataSource>(
    () => _i370.FilePickerDataSource(gh<_i388.FilePicker>()),
  );
  gh.factory<_i771.MomentsDataSource>(
    () => _i1056.FirebaseMomentsDataSource(
      gh<_i974.CollectionReference<_i797.MomentModel>>(
        instanceName: 'momentsDBParam',
      ),
      gh<_i457.Reference>(instanceName: 'photosStorage'),
    ),
  );
  gh.factory<_i913.UserPremiumDataSource>(
    () => _i913.FirebaseUserPremiumDataSourceImpl(
      gh<_i974.CollectionReference<_i372.UserPremiumModel>>(
        instanceName: 'users',
      ),
    ),
  );
  gh.factory<_i688.TimeCapsuleRepository>(
    () => _i801.TimeCapsuleRepositoryImpl(gh<_i333.TimeCapsuleDataSource>()),
  );
  gh.factory<_i974.CollectionReference<_i452.TimeLineModel>>(
    () => firebaseModule.timelineDbRef,
    instanceName: 'timeline',
  );
  gh.factory<_i674.LocalNotificationDataSource>(
    () => _i674.FlutterLocalNotificationDataSource(),
  );
  gh.factory<_i592.PhotoDataSource>(
    () => _i320.FirebaseStoragePhotoDataSource(
      gh<_i457.Reference>(instanceName: 'photosStorage'),
    ),
  );
  gh.factory<_i323.InteractionsRepository>(
    () => _i737.InteractionsRepositoryImpl(gh<_i271.InteractionsDataSource>()),
  );
  gh.factory<_i283.AuthRemoteDataSource>(
    () => _i678.FirebaseAuthRemoteDataSource(gh<_i59.FirebaseAuth>()),
  );
  gh.factory<_i937.RemoveCommentUseCase>(
    () => _i937.RemoveCommentUseCase(gh<_i323.InteractionsRepository>()),
  );
  gh.factory<_i606.RemoveReactionUseCase>(
    () => _i606.RemoveReactionUseCase(gh<_i323.InteractionsRepository>()),
  );
  gh.factory<_i1067.WatchCommentsUseCase>(
    () => _i1067.WatchCommentsUseCase(gh<_i323.InteractionsRepository>()),
  );
  gh.factory<_i787.WatchReactionsUseCase>(
    () => _i787.WatchReactionsUseCase(gh<_i323.InteractionsRepository>()),
  );
  gh.factory<_i248.PurchaseRepository>(
    () => _i226.PurchaseRepositoryImpl(gh<_i1025.PurchaseDataSource>()),
  );
  gh.factory<_i422.WatchTimeCapsulesUseCase>(
    () => _i422.WatchTimeCapsulesUseCase(gh<_i688.TimeCapsuleRepository>()),
  );
  gh.factory<_i179.PhotosRepository>(
    () => _i724.PhotosRepositoryImpl(
      gh<_i592.PhotoDataSource>(),
      gh<_i370.FilePickerDataSource>(),
    ),
  );
  gh.factory<_i262.UploadPhotoUseCase>(
    () => _i262.UploadPhotoUseCase(gh<_i179.PhotosRepository>()),
  );
  gh.factory<_i1061.TimeLineDataSource>(
    () => _i1061.FirebaseTimelineRemoteDataSourceImpl(
      gh<_i974.CollectionReference<_i452.TimeLineModel>>(
        instanceName: 'timeline',
      ),
    ),
  );
  gh.factory<_i878.UserPremiumRepository>(
    () => _i243.UserPremiumRepositoryImpl(gh<_i913.UserPremiumDataSource>()),
  );
  gh.factory<_i591.SpecialDatesDataSource>(
    () => _i337.FirebaseSpecialDatesDataSource(
      gh<_i974.CollectionReference<Map<String, dynamic>>>(
        instanceName: 'timeLineRawCollectionParam',
      ),
    ),
  );
  gh.factory<_i258.BucketListRepository>(
    () => _i326.BucketListRepositoryImpl(gh<_i631.BucketListDataSource>()),
  );
  gh.factory<_i727.NotificationRepository>(
    () => _i894.NotificationRepositoryImpl(
      gh<_i674.LocalNotificationDataSource>(),
      gh<_i374.NotificationPreferenceStore>(),
    ),
  );
  gh.factory<_i980.MomentRepository>(
    () => _i775.MomentRepositoryImpl(gh<_i771.MomentsDataSource>()),
  );
  gh.factory<_i884.AuthRepository>(
    () => _i401.AuthRepositoryImpl(gh<_i283.AuthRemoteDataSource>()),
  );
  gh.factory<_i465.GetMediaUseCase>(
    () => _i465.GetMediaUseCase(gh<_i179.PhotosRepository>()),
  );
  gh.factory<_i409.AddBucketItemUseCase>(
    () => _i409.AddBucketItemUseCase(gh<_i258.BucketListRepository>()),
  );
  gh.factory<_i49.RemoveBucketItemUseCase>(
    () => _i49.RemoveBucketItemUseCase(gh<_i258.BucketListRepository>()),
  );
  gh.factory<_i355.ToggleBucketItemUseCase>(
    () => _i355.ToggleBucketItemUseCase(gh<_i258.BucketListRepository>()),
  );
  gh.factory<_i768.WatchBucketListUseCase>(
    () => _i768.WatchBucketListUseCase(gh<_i258.BucketListRepository>()),
  );
  gh.lazySingleton<_i821.NotificationService>(
    () => _i821.NotificationService(
      gh<_i727.NotificationRepository>(),
      gh<_i423.PremiumService>(),
    ),
  );
  gh.factory<_i1036.GetEntitlementStatusUseCase>(
    () => _i1036.GetEntitlementStatusUseCase(gh<_i248.PurchaseRepository>()),
  );
  gh.factory<_i458.GetOfferingsUseCase>(
    () => _i458.GetOfferingsUseCase(gh<_i248.PurchaseRepository>()),
  );
  gh.factory<_i7.PresentCustomerCenterUseCase>(
    () => _i7.PresentCustomerCenterUseCase(gh<_i248.PurchaseRepository>()),
  );
  gh.factory<_i915.PresentPaywallUseCase>(
    () => _i915.PresentPaywallUseCase(gh<_i248.PurchaseRepository>()),
  );
  gh.factory<_i844.PurchaseUseCase>(
    () => _i844.PurchaseUseCase(gh<_i248.PurchaseRepository>()),
  );
  gh.factory<_i771.RestorePurchasesUseCase>(
    () => _i771.RestorePurchasesUseCase(gh<_i248.PurchaseRepository>()),
  );
  gh.factory<_i393.IsUserAuthenticatedUseCase>(
    () => _i393.IsUserAuthenticatedUseCase(gh<_i884.AuthRepository>()),
  );
  gh.factory<_i518.SignInUseCase>(
    () => _i518.SignInUseCase(gh<_i884.AuthRepository>()),
  );
  gh.factory<_i734.ReauthenticateUseCase>(
    () => _i734.ReauthenticateUseCase(gh<_i884.AuthRepository>()),
  );
  gh.factory<_i480.SignUpUseCase>(
    () => _i480.SignUpUseCase(gh<_i884.AuthRepository>()),
  );
  gh.factory<_i44.LogoutUseCase>(
    () => _i44.LogoutUseCase(gh<_i884.AuthRepository>()),
  );
  gh.factory<_i774.SyncUserEntitlementUseCase>(
    () => _i774.SyncUserEntitlementUseCase(
      gh<_i878.UserPremiumRepository>(),
      gh<_i884.AuthRepository>(),
    ),
  );
  gh.factory<_i338.GetUserPremiumUseCase>(
    () => _i338.GetUserPremiumUseCase(
      gh<_i878.UserPremiumRepository>(),
      gh<_i884.AuthRepository>(),
    ),
  );
  gh.factory<_i184.TimeLineRepository>(
    () => _i294.TimeLineRepositoryImpl(
      momentsDataSource: gh<_i771.MomentsDataSource>(),
      timeLineDataSource: gh<_i1061.TimeLineDataSource>(),
    ),
  );
  gh.factory<_i1069.GetCurrentUserUseCase>(
    () => _i1069.GetCurrentUserUseCase(gh<_i884.AuthRepository>()),
  );
  gh.factory<_i183.DeleteMomentsUseCase>(
    () => _i183.DeleteMomentsUseCase(gh<_i980.MomentRepository>()),
  );
  gh.factory<_i272.UpdateMomentUseCase>(
    () => _i272.UpdateMomentUseCase(gh<_i980.MomentRepository>()),
  );
  gh.factory<_i783.GetTimeLineFromEmailUseCase>(
    () => _i783.GetTimeLineFromEmailUseCase(
      gh<_i884.AuthRepository>(),
      gh<_i184.TimeLineRepository>(),
    ),
  );
  gh.factory<_i522.ClearAllPhotosFromMomentUseCase>(
    () => _i522.ClearAllPhotosFromMomentUseCase(gh<_i179.PhotosRepository>()),
  );
  gh.factory<_i271.DeletePhotoUseCase>(
    () => _i271.DeletePhotoUseCase(gh<_i179.PhotosRepository>()),
  );
  gh.factory<_i260.LoginBloc>(
    () => _i260.LoginBloc(
      gh<_i518.SignInUseCase>(),
      gh<_i393.IsUserAuthenticatedUseCase>(),
    ),
  );
  gh.factory<_i753.AddCommentUseCase>(
    () => _i753.AddCommentUseCase(
      gh<_i323.InteractionsRepository>(),
      gh<_i884.AuthRepository>(),
    ),
  );
  gh.factory<_i426.AddReactionUseCase>(
    () => _i426.AddReactionUseCase(
      gh<_i323.InteractionsRepository>(),
      gh<_i884.AuthRepository>(),
    ),
  );
  gh.factory<_i1007.SpecialDatesRepository>(
    () => _i929.SpecialDatesRepositoryImpl(gh<_i591.SpecialDatesDataSource>()),
  );
  gh.factory<_i461.DeleteAccountUseCase>(
    () => _i461.DeleteAccountUseCase(
      gh<_i884.AuthRepository>(),
      gh<_i184.TimeLineRepository>(),
      gh<_i980.MomentRepository>(),
      gh<_i878.UserPremiumRepository>(),
    ),
  );
  gh.factory<_i773.SignUpBloc>(
    () => _i773.SignUpBloc(gh<_i480.SignUpUseCase>()),
  );
  gh.factory<_i720.RemoveTimeCapsuleUseCase>(
    () => _i720.RemoveTimeCapsuleUseCase(
      gh<_i688.TimeCapsuleRepository>(),
      gh<_i821.NotificationService>(),
    ),
  );
  gh.factory<_i339.UpdateCoupleHeaderUseCase>(
    () => _i339.UpdateCoupleHeaderUseCase(
      gh<_i184.TimeLineRepository>(),
      gh<_i262.UploadPhotoUseCase>(),
    ),
  );
  gh.factory<_i981.AllTimelinesMapBloc>(
    () => _i981.AllTimelinesMapBloc(
      gh<_i783.GetTimeLineFromEmailUseCase>(),
      gh<_i184.TimeLineRepository>(),
    ),
  );
  gh.factory<_i789.WatchSpecialDatesUseCase>(
    () => _i789.WatchSpecialDatesUseCase(gh<_i1007.SpecialDatesRepository>()),
  );
  gh.factory<_i876.PhotosBloc>(
    () => _i876.PhotosBloc(gh<_i465.GetMediaUseCase>()),
  );
  gh.factory<_i589.GetMomentsUseCase>(
    () => _i589.GetMomentsUseCase(gh<_i184.TimeLineRepository>()),
  );
  gh.factory<_i1047.SyncEntitlementUseCase>(
    () => _i1047.SyncEntitlementUseCase(gh<_i184.TimeLineRepository>()),
  );
  gh.factory<_i619.AddEmailUseCase>(
    () => _i619.AddEmailUseCase(gh<_i184.TimeLineRepository>()),
  );
  gh.factory<_i275.DeleteEmailUseCase>(
    () => _i275.DeleteEmailUseCase(gh<_i184.TimeLineRepository>()),
  );
  gh.factory<_i13.GetTimeLineFromIdUseCase>(
    () => _i13.GetTimeLineFromIdUseCase(gh<_i184.TimeLineRepository>()),
  );
  gh.factory<_i711.UpdateRolesUseCase>(
    () => _i711.UpdateRolesUseCase(gh<_i184.TimeLineRepository>()),
  );
  gh.factory<_i1065.UpdateRelationshipEndDateUseCase>(
    () =>
        _i1065.UpdateRelationshipEndDateUseCase(gh<_i184.TimeLineRepository>()),
  );
  gh.factory<_i759.UpdateRelationshipStartDateUseCase>(
    () => _i759.UpdateRelationshipStartDateUseCase(
      gh<_i184.TimeLineRepository>(),
    ),
  );
  gh.factory<_i740.UpdateTimeLineDetailsUseCase>(
    () => _i740.UpdateTimeLineDetailsUseCase(gh<_i184.TimeLineRepository>()),
  );
  gh.factory<_i1005.AddSpecialDateUseCase>(
    () => _i1005.AddSpecialDateUseCase(
      gh<_i1007.SpecialDatesRepository>(),
      gh<_i884.AuthRepository>(),
      gh<_i821.NotificationService>(),
    ),
  );
  gh.lazySingleton<_i166.EntitlementSyncService>(
    () => _i166.EntitlementSyncService(
      gh<_i1047.SyncEntitlementUseCase>(),
      gh<_i774.SyncUserEntitlementUseCase>(),
      gh<_i1036.GetEntitlementStatusUseCase>(),
      gh<_i423.PremiumService>(),
    ),
  );
  gh.factory<_i961.AddTimeCapsuleUseCase>(
    () => _i961.AddTimeCapsuleUseCase(
      gh<_i688.TimeCapsuleRepository>(),
      gh<_i884.AuthRepository>(),
      gh<_i821.NotificationService>(),
    ),
  );
  gh.factory<_i209.BucketListBloc>(
    () => _i209.BucketListBloc(
      gh<_i768.WatchBucketListUseCase>(),
      gh<_i409.AddBucketItemUseCase>(),
      gh<_i355.ToggleBucketItemUseCase>(),
      gh<_i49.RemoveBucketItemUseCase>(),
    ),
  );
  gh.factory<_i283.CreateTimeLineUseCase>(
    () => _i283.CreateTimeLineUseCase(
      gh<_i184.TimeLineRepository>(),
      gh<_i884.AuthRepository>(),
    ),
  );
  gh.factory<_i1037.DeleteTimeLineUseCase>(
    () => _i1037.DeleteTimeLineUseCase(gh<_i184.TimeLineRepository>()),
  );
  gh.factory<_i315.InteractionsBloc>(
    () => _i315.InteractionsBloc(
      gh<_i787.WatchReactionsUseCase>(),
      gh<_i1067.WatchCommentsUseCase>(),
      gh<_i426.AddReactionUseCase>(),
      gh<_i753.AddCommentUseCase>(),
      gh<_i606.RemoveReactionUseCase>(),
      gh<_i937.RemoveCommentUseCase>(),
      gh<_i884.AuthRepository>(),
    ),
  );
  gh.factory<_i430.TimeCapsuleBloc>(
    () => _i430.TimeCapsuleBloc(
      gh<_i422.WatchTimeCapsulesUseCase>(),
      gh<_i961.AddTimeCapsuleUseCase>(),
      gh<_i720.RemoveTimeCapsuleUseCase>(),
    ),
  );
  gh.factory<_i11.SelectTimeLineBloc>(
    () => _i11.SelectTimeLineBloc(
      gh<_i783.GetTimeLineFromEmailUseCase>(),
      gh<_i44.LogoutUseCase>(),
    ),
  );
  gh.factory<_i663.RegisterMomentsUseCase>(
    () => _i663.RegisterMomentsUseCase(
      gh<_i980.MomentRepository>(),
      gh<_i184.TimeLineRepository>(),
    ),
  );
  gh.factory<_i337.RemoveSpecialDateUseCase>(
    () => _i337.RemoveSpecialDateUseCase(
      gh<_i1007.SpecialDatesRepository>(),
      gh<_i821.NotificationService>(),
    ),
  );
  gh.factory<_i895.SpecialDatesBloc>(
    () => _i895.SpecialDatesBloc(
      gh<_i789.WatchSpecialDatesUseCase>(),
      gh<_i1005.AddSpecialDateUseCase>(),
      gh<_i337.RemoveSpecialDateUseCase>(),
    ),
  );
  gh.factory<_i99.PremiumBloc>(
    () => _i99.PremiumBloc(
      gh<_i458.GetOfferingsUseCase>(),
      gh<_i844.PurchaseUseCase>(),
      gh<_i771.RestorePurchasesUseCase>(),
      gh<_i915.PresentPaywallUseCase>(),
      gh<_i166.EntitlementSyncService>(),
    ),
  );
  gh.factory<_i716.TimeLineBloc>(
    () => _i716.TimeLineBloc(
      gh<_i589.GetMomentsUseCase>(),
      gh<_i183.DeleteMomentsUseCase>(),
      gh<_i522.ClearAllPhotosFromMomentUseCase>(),
      gh<_i283.CreateTimeLineUseCase>(),
      gh<_i13.GetTimeLineFromIdUseCase>(),
      gh<_i759.UpdateRelationshipStartDateUseCase>(),
      gh<_i1065.UpdateRelationshipEndDateUseCase>(),
      gh<_i272.UpdateMomentUseCase>(),
      gh<_i423.PremiumService>(),
      gh<_i338.GetUserPremiumUseCase>(),
    ),
  );
  gh.factory<_i321.AddOrEditMomentBloc>(
    () => _i321.AddOrEditMomentBloc(
      gh<_i272.UpdateMomentUseCase>(),
      gh<_i663.RegisterMomentsUseCase>(),
      gh<_i262.UploadPhotoUseCase>(),
      gh<_i271.DeletePhotoUseCase>(),
      gh<_i183.DeleteMomentsUseCase>(),
      gh<_i884.AuthRepository>(),
    ),
  );
  gh.factory<_i970.SettingsBloc>(
    () => _i970.SettingsBloc(
      gh<_i619.AddEmailUseCase>(),
      gh<_i275.DeleteEmailUseCase>(),
      gh<_i1069.GetCurrentUserUseCase>(),
      gh<_i13.GetTimeLineFromIdUseCase>(),
      gh<_i740.UpdateTimeLineDetailsUseCase>(),
      gh<_i339.UpdateCoupleHeaderUseCase>(),
      gh<_i1065.UpdateRelationshipEndDateUseCase>(),
      gh<_i711.UpdateRolesUseCase>(),
      gh<_i1037.DeleteTimeLineUseCase>(),
      gh<_i461.DeleteAccountUseCase>(),
      gh<_i734.ReauthenticateUseCase>(),
    ),
  );
  return getIt;
}

class _$AppModules extends _i1023.AppModules {}

class _$FirebaseModule extends _i279.FirebaseModule {}
