import 'dart:async';
import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nofap_reboot/bloc/Theme/app_theme.dart';
import 'package:nofap_reboot/bloc/global_cubit.dart';
import 'package:nofap_reboot/bloc/streak_cubit.dart';
import 'package:nofap_reboot/bloc/urge_cubit.dart';
import 'package:nofap_reboot/firebase_options.dart';
import 'package:nofap_reboot/l10n/generated/i18n/app_localizations.dart';
import 'package:nofap_reboot/router/app_router.dart';
import 'package:nofap_reboot/utils/notification.dart';

import 'data/helper/database.dart';

setRemoteConfig() async {
  try {
    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setConfigSettings(
      RemoteConfigSettings(fetchTimeout: const Duration(minutes: 2), minimumFetchInterval: const Duration(hours: 5)),
    );
    await remoteConfig.setDefaults(<String, dynamic>{'isDialogShow': false, 'isAppOpenAds': true});
    remoteConfig.onConfigUpdated.listen((event) async {
      await remoteConfig.activate();
    });
    await remoteConfig.fetchAndActivate();
  } catch (e) {
    log(e.toString());
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Pref.initializeHive();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  MessagingService().init();
  setRemoteConfig();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then((value) {
    runApp(const MyApp());
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      splitScreenMode: true,
      builder: (context1, child) {
        return MultiBlocProvider(
          providers: providers,
          child: BlocBuilder<GlobalCubit, GlobalState>(
            builder: (context, state) {
              return MaterialApp.router(
                routerConfig: AppRouter.router,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                locale: state.locale,
                supportedLocales: AppLocalizations.supportedLocales,
                debugShowCheckedModeBanner: false,
                title: 'NoFap Reboot',
                theme: darkThemeData,
                darkTheme: darkThemeData,
                themeMode: ThemeMode.dark,
              );
            },
          ),
        );
      },
    );
  }
}

List<BlocProvider> providers = [
  BlocProvider<GlobalCubit>(create: (context) => GlobalCubit(Pref.locale)),
  BlocProvider<StreakCubit>(create: (context) => StreakCubit()),
  BlocProvider<UrgeCubit>(create: (context) => UrgeCubit()),
];
