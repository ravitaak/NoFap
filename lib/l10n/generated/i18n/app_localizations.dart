import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fil.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_id.dart';
import 'app_localizations_it.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'i18n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fil'),
    Locale('fr'),
    Locale('hi'),
    Locale('id'),
    Locale('it'),
    Locale('pt'),
    Locale('ru'),
  ];

  /// No description provided for @no_ads.
  ///
  /// In en, this message translates to:
  /// **'No ads available! Try again!'**
  String get no_ads;

  /// No description provided for @watch_ads.
  ///
  /// In en, this message translates to:
  /// **'Watch Ads'**
  String get watch_ads;

  /// No description provided for @thank_you.
  ///
  /// In en, this message translates to:
  /// **'Thank You!'**
  String get thank_you;

  /// No description provided for @store_unavailable.
  ///
  /// In en, this message translates to:
  /// **'Store is currently unavailable.'**
  String get store_unavailable;

  /// No description provided for @try_again.
  ///
  /// In en, this message translates to:
  /// **'Please try again after some time'**
  String get try_again;

  /// No description provided for @rate_us.
  ///
  /// In en, this message translates to:
  /// **'Rate Us'**
  String get rate_us;

  /// No description provided for @purchage_pending.
  ///
  /// In en, this message translates to:
  /// **'Your purchase is pending. Please wait.'**
  String get purchage_pending;

  /// No description provided for @purchage_error.
  ///
  /// In en, this message translates to:
  /// **'There was an error. Please try again later.'**
  String get purchage_error;

  /// No description provided for @purchage_success.
  ///
  /// In en, this message translates to:
  /// **'Thank you for supporting us!'**
  String get purchage_success;

  /// No description provided for @exit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exit;

  /// No description provided for @donate.
  ///
  /// In en, this message translates to:
  /// **'Donate'**
  String get donate;

  /// No description provided for @privacy_policy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacy_policy;

  /// No description provided for @change_theme.
  ///
  /// In en, this message translates to:
  /// **'Change Theme'**
  String get change_theme;

  /// No description provided for @update_app.
  ///
  /// In en, this message translates to:
  /// **'Update App'**
  String get update_app;

  /// No description provided for @share_app.
  ///
  /// In en, this message translates to:
  /// **'Share App'**
  String get share_app;

  /// No description provided for @more_apps.
  ///
  /// In en, this message translates to:
  /// **'More Apps'**
  String get more_apps;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @change_language.
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get change_language;

  /// No description provided for @tips.
  ///
  /// In en, this message translates to:
  /// **'Tips'**
  String get tips;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @ignore.
  ///
  /// In en, this message translates to:
  /// **'Ignore'**
  String get ignore;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @command.
  ///
  /// In en, this message translates to:
  /// **'Command'**
  String get command;

  /// No description provided for @ascend.
  ///
  /// In en, this message translates to:
  /// **'Ascend'**
  String get ascend;

  /// No description provided for @shield.
  ///
  /// In en, this message translates to:
  /// **'Shield'**
  String get shield;

  /// No description provided for @identity.
  ///
  /// In en, this message translates to:
  /// **'Identity'**
  String get identity;

  /// No description provided for @current_streak.
  ///
  /// In en, this message translates to:
  /// **'Current Streak'**
  String get current_streak;

  /// No description provided for @best_streak.
  ///
  /// In en, this message translates to:
  /// **'Best Streak'**
  String get best_streak;

  /// No description provided for @days_clean.
  ///
  /// In en, this message translates to:
  /// **'Days Clean'**
  String get days_clean;

  /// No description provided for @total_days.
  ///
  /// In en, this message translates to:
  /// **'Total Days'**
  String get total_days;

  /// No description provided for @i_feel_urge.
  ///
  /// In en, this message translates to:
  /// **'I Feel an Urge'**
  String get i_feel_urge;

  /// No description provided for @urge_button.
  ///
  /// In en, this message translates to:
  /// **'URGE'**
  String get urge_button;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get days;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get hours;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'Minutes'**
  String get minutes;

  /// No description provided for @seconds.
  ///
  /// In en, this message translates to:
  /// **'Seconds'**
  String get seconds;

  /// No description provided for @time_since_relapse.
  ///
  /// In en, this message translates to:
  /// **'Time Since Last Relapse'**
  String get time_since_relapse;

  /// No description provided for @no_streak_yet.
  ///
  /// In en, this message translates to:
  /// **'Start Your Journey'**
  String get no_streak_yet;

  /// No description provided for @breathing_exercise.
  ///
  /// In en, this message translates to:
  /// **'Breathing Exercise'**
  String get breathing_exercise;

  /// No description provided for @distract_me.
  ///
  /// In en, this message translates to:
  /// **'Distract Me'**
  String get distract_me;

  /// No description provided for @do_pushups.
  ///
  /// In en, this message translates to:
  /// **'Do 20 Pushups'**
  String get do_pushups;

  /// No description provided for @take_walk.
  ///
  /// In en, this message translates to:
  /// **'Take a Walk'**
  String get take_walk;

  /// No description provided for @drink_water.
  ///
  /// In en, this message translates to:
  /// **'Drink Water'**
  String get drink_water;

  /// No description provided for @cold_shower.
  ///
  /// In en, this message translates to:
  /// **'Cold Shower'**
  String get cold_shower;

  /// No description provided for @meditate.
  ///
  /// In en, this message translates to:
  /// **'Meditate 5 min'**
  String get meditate;

  /// No description provided for @urge_timer.
  ///
  /// In en, this message translates to:
  /// **'Urge Timer'**
  String get urge_timer;

  /// No description provided for @timer_30s.
  ///
  /// In en, this message translates to:
  /// **'30 Seconds'**
  String get timer_30s;

  /// No description provided for @timer_60s.
  ///
  /// In en, this message translates to:
  /// **'60 Seconds'**
  String get timer_60s;

  /// No description provided for @timer_done.
  ///
  /// In en, this message translates to:
  /// **'You survived the urge!'**
  String get timer_done;

  /// No description provided for @inhale.
  ///
  /// In en, this message translates to:
  /// **'Inhale'**
  String get inhale;

  /// No description provided for @hold.
  ///
  /// In en, this message translates to:
  /// **'Hold'**
  String get hold;

  /// No description provided for @exhale.
  ///
  /// In en, this message translates to:
  /// **'Exhale'**
  String get exhale;

  /// No description provided for @relapse.
  ///
  /// In en, this message translates to:
  /// **'I Relapsed'**
  String get relapse;

  /// No description provided for @reset_streak.
  ///
  /// In en, this message translates to:
  /// **'Reset Streak'**
  String get reset_streak;

  /// No description provided for @reset_confirm.
  ///
  /// In en, this message translates to:
  /// **'This will reset your current streak. Are you sure?'**
  String get reset_confirm;

  /// No description provided for @why_i_started.
  ///
  /// In en, this message translates to:
  /// **'Why I Started'**
  String get why_i_started;

  /// No description provided for @edit_reason.
  ///
  /// In en, this message translates to:
  /// **'Edit Your Reason'**
  String get edit_reason;

  /// No description provided for @reason_hint.
  ///
  /// In en, this message translates to:
  /// **'Write your personal reason for quitting...'**
  String get reason_hint;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @achievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @streak_history.
  ///
  /// In en, this message translates to:
  /// **'Streak History'**
  String get streak_history;

  /// No description provided for @weekly_progress.
  ///
  /// In en, this message translates to:
  /// **'Weekly Progress'**
  String get weekly_progress;

  /// No description provided for @most_risky_time.
  ///
  /// In en, this message translates to:
  /// **'Most Risky Time'**
  String get most_risky_time;

  /// No description provided for @insights.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get insights;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// No description provided for @clean_day.
  ///
  /// In en, this message translates to:
  /// **'Clean Day'**
  String get clean_day;

  /// No description provided for @relapse_day.
  ///
  /// In en, this message translates to:
  /// **'Relapse Day'**
  String get relapse_day;

  /// No description provided for @premium_upgrade.
  ///
  /// In en, this message translates to:
  /// **'Go Premium'**
  String get premium_upgrade;

  /// No description provided for @premium_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock all features & remove ads'**
  String get premium_subtitle;

  /// No description provided for @premium_cta.
  ///
  /// In en, this message translates to:
  /// **'Upgrade Now'**
  String get premium_cta;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @daily_reminder.
  ///
  /// In en, this message translates to:
  /// **'Daily Reminder'**
  String get daily_reminder;

  /// No description provided for @motivation.
  ///
  /// In en, this message translates to:
  /// **'Motivation'**
  String get motivation;

  /// No description provided for @quote_of_day.
  ///
  /// In en, this message translates to:
  /// **'Quote of the Day'**
  String get quote_of_day;

  /// No description provided for @day_one.
  ///
  /// In en, this message translates to:
  /// **'1 Day'**
  String get day_one;

  /// No description provided for @day_three.
  ///
  /// In en, this message translates to:
  /// **'3 Days'**
  String get day_three;

  /// No description provided for @day_seven.
  ///
  /// In en, this message translates to:
  /// **'7 Days'**
  String get day_seven;

  /// No description provided for @day_fourteen.
  ///
  /// In en, this message translates to:
  /// **'14 Days'**
  String get day_fourteen;

  /// No description provided for @day_thirty.
  ///
  /// In en, this message translates to:
  /// **'30 Days'**
  String get day_thirty;

  /// No description provided for @day_sixty.
  ///
  /// In en, this message translates to:
  /// **'60 Days'**
  String get day_sixty;

  /// No description provided for @day_ninety.
  ///
  /// In en, this message translates to:
  /// **'90 Days'**
  String get day_ninety;

  /// No description provided for @day_hundred_eighty.
  ///
  /// In en, this message translates to:
  /// **'180 Days'**
  String get day_hundred_eighty;

  /// No description provided for @day_year.
  ///
  /// In en, this message translates to:
  /// **'1 Year'**
  String get day_year;

  /// No description provided for @badge_warrior.
  ///
  /// In en, this message translates to:
  /// **'Warrior'**
  String get badge_warrior;

  /// No description provided for @badge_champion.
  ///
  /// In en, this message translates to:
  /// **'Champion'**
  String get badge_champion;

  /// No description provided for @badge_conqueror.
  ///
  /// In en, this message translates to:
  /// **'Conqueror'**
  String get badge_conqueror;

  /// No description provided for @badge_titan.
  ///
  /// In en, this message translates to:
  /// **'Titan'**
  String get badge_titan;

  /// No description provided for @badge_legend.
  ///
  /// In en, this message translates to:
  /// **'Legend'**
  String get badge_legend;

  /// No description provided for @badge_immortal.
  ///
  /// In en, this message translates to:
  /// **'Immortal'**
  String get badge_immortal;

  /// No description provided for @badge_monk.
  ///
  /// In en, this message translates to:
  /// **'Monk'**
  String get badge_monk;

  /// No description provided for @badge_ascendant.
  ///
  /// In en, this message translates to:
  /// **'Ascendant'**
  String get badge_ascendant;

  /// No description provided for @badge_reborn.
  ///
  /// In en, this message translates to:
  /// **'Reborn'**
  String get badge_reborn;

  /// No description provided for @congrats_message.
  ///
  /// In en, this message translates to:
  /// **'Keep Going. You Are Rising.'**
  String get congrats_message;

  /// No description provided for @relapse_message.
  ///
  /// In en, this message translates to:
  /// **'Every warrior falls. Rise again.'**
  String get relapse_message;

  /// No description provided for @emergency_mode.
  ///
  /// In en, this message translates to:
  /// **'Emergency Mode'**
  String get emergency_mode;

  /// No description provided for @focus_mode.
  ///
  /// In en, this message translates to:
  /// **'Focus Mode — Stay Strong'**
  String get focus_mode;

  /// No description provided for @your_why.
  ///
  /// In en, this message translates to:
  /// **'Remember Your Why'**
  String get your_why;

  /// No description provided for @stats_title.
  ///
  /// In en, this message translates to:
  /// **'Your Stats'**
  String get stats_title;

  /// No description provided for @total_relapses.
  ///
  /// In en, this message translates to:
  /// **'Total Relapses'**
  String get total_relapses;

  /// No description provided for @longest_streak.
  ///
  /// In en, this message translates to:
  /// **'Longest Streak'**
  String get longest_streak;

  /// No description provided for @average_streak.
  ///
  /// In en, this message translates to:
  /// **'Average Streak'**
  String get average_streak;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'de',
    'en',
    'es',
    'fil',
    'fr',
    'hi',
    'id',
    'it',
    'pt',
    'ru',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fil':
      return AppLocalizationsFil();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'id':
      return AppLocalizationsId();
    case 'it':
      return AppLocalizationsIt();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
