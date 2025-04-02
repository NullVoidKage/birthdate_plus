import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('hi'),
    Locale('ja'),
    Locale('ko'),
    Locale('pt'),
    Locale('zh')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Birthdate+'**
  String get appTitle;

  /// No description provided for @calculateAge.
  ///
  /// In en, this message translates to:
  /// **'Calculate Age'**
  String get calculateAge;

  /// No description provided for @birthDate.
  ///
  /// In en, this message translates to:
  /// **'Birth Date'**
  String get birthDate;

  /// No description provided for @currentAge.
  ///
  /// In en, this message translates to:
  /// **'Current Age'**
  String get currentAge;

  /// No description provided for @years.
  ///
  /// In en, this message translates to:
  /// **'Years'**
  String get years;

  /// No description provided for @months.
  ///
  /// In en, this message translates to:
  /// **'Months'**
  String get months;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get days;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @detailedTime.
  ///
  /// In en, this message translates to:
  /// **'Detailed Time'**
  String get detailedTime;

  /// No description provided for @simpleTime.
  ///
  /// In en, this message translates to:
  /// **'Simple Time'**
  String get simpleTime;

  /// No description provided for @showAge.
  ///
  /// In en, this message translates to:
  /// **'Show Age'**
  String get showAge;

  /// No description provided for @hideAge.
  ///
  /// In en, this message translates to:
  /// **'Hide Age'**
  String get hideAge;

  /// No description provided for @customize.
  ///
  /// In en, this message translates to:
  /// **'Customize'**
  String get customize;

  /// No description provided for @showInfo.
  ///
  /// In en, this message translates to:
  /// **'Show Info'**
  String get showInfo;

  /// No description provided for @hideInfo.
  ///
  /// In en, this message translates to:
  /// **'Hide Info'**
  String get hideInfo;

  /// No description provided for @resetAll.
  ///
  /// In en, this message translates to:
  /// **'Reset All'**
  String get resetAll;

  /// No description provided for @createBeautifulCards.
  ///
  /// In en, this message translates to:
  /// **'Create Beautiful\nBirthday Cards'**
  String get createBeautifulCards;

  /// No description provided for @discoverFacts.
  ///
  /// In en, this message translates to:
  /// **'Discover fascinating facts about your birthday and create stunning shareable cards.'**
  String get discoverFacts;

  /// No description provided for @basicFeatures.
  ///
  /// In en, this message translates to:
  /// **'Basic Features'**
  String get basicFeatures;

  /// No description provided for @premiumFeatures.
  ///
  /// In en, this message translates to:
  /// **'Premium Features'**
  String get premiumFeatures;

  /// No description provided for @fontSize.
  ///
  /// In en, this message translates to:
  /// **'Font Size'**
  String get fontSize;

  /// No description provided for @textOpacity.
  ///
  /// In en, this message translates to:
  /// **'Text Opacity'**
  String get textOpacity;

  /// No description provided for @textColor.
  ///
  /// In en, this message translates to:
  /// **'Text Color'**
  String get textColor;

  /// No description provided for @backgroundColor.
  ///
  /// In en, this message translates to:
  /// **'Background Color'**
  String get backgroundColor;

  /// No description provided for @textStyle.
  ///
  /// In en, this message translates to:
  /// **'Text Style'**
  String get textStyle;

  /// No description provided for @bold.
  ///
  /// In en, this message translates to:
  /// **'Bold'**
  String get bold;

  /// No description provided for @italic.
  ///
  /// In en, this message translates to:
  /// **'Italic'**
  String get italic;

  /// No description provided for @addPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add Photo'**
  String get addPhoto;

  /// No description provided for @captureMoments.
  ///
  /// In en, this message translates to:
  /// **'Capture Your Moments'**
  String get captureMoments;

  /// No description provided for @addPhotosDescription.
  ///
  /// In en, this message translates to:
  /// **'Add photos to create beautiful memories and track your special moments'**
  String get addPhotosDescription;

  /// No description provided for @getInTouch.
  ///
  /// In en, this message translates to:
  /// **'Get in Touch'**
  String get getInTouch;

  /// No description provided for @contactDescription.
  ///
  /// In en, this message translates to:
  /// **'Have questions or feedback? We\'d love to hear from you!'**
  String get contactDescription;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @enterName.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get enterName;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterEmail;

  /// No description provided for @pleaseEnterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get pleaseEnterName;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterEmail;

  /// No description provided for @enterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get enterValidEmail;

  /// No description provided for @otherWaysToReach.
  ///
  /// In en, this message translates to:
  /// **'Other Ways to Reach Us'**
  String get otherWaysToReach;

  /// No description provided for @supportHours.
  ///
  /// In en, this message translates to:
  /// **'Support Hours'**
  String get supportHours;

  /// No description provided for @supportHoursValue.
  ///
  /// In en, this message translates to:
  /// **'Monday - Friday, 9am - 5pm EST'**
  String get supportHoursValue;

  /// No description provided for @aboutUs.
  ///
  /// In en, this message translates to:
  /// **'About Us'**
  String get aboutUs;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @birthdayCards.
  ///
  /// In en, this message translates to:
  /// **'Birthday Cards'**
  String get birthdayCards;

  /// No description provided for @createCustomCards.
  ///
  /// In en, this message translates to:
  /// **'Create custom cards'**
  String get createCustomCards;

  /// No description provided for @anniversaryCards.
  ///
  /// In en, this message translates to:
  /// **'Anniv. Cards'**
  String get anniversaryCards;

  /// No description provided for @calculateExactAge.
  ///
  /// In en, this message translates to:
  /// **'Calculate your exact age'**
  String get calculateExactAge;

  /// No description provided for @birthFacts.
  ///
  /// In en, this message translates to:
  /// **'Birth Facts'**
  String get birthFacts;

  /// No description provided for @zodiacAndMore.
  ///
  /// In en, this message translates to:
  /// **'Zodiac, birthstone & more'**
  String get zodiacAndMore;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @shareWithFriends.
  ///
  /// In en, this message translates to:
  /// **'Share with friends'**
  String get shareWithFriends;

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'Birthdate+ is your personal birthday companion app that helps you discover fascinating facts about your special day and create beautiful shareable cards. Our app combines historical events, zodiac information, and creative design to make your birthday celebrations even more memorable.'**
  String get aboutDescription;

  /// No description provided for @features.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get features;

  /// No description provided for @birthdayCardsDescription.
  ///
  /// In en, this message translates to:
  /// **'Create and share beautiful birthday cards with your photos and personalized messages.'**
  String get birthdayCardsDescription;

  /// No description provided for @anniversaryCardsDescription.
  ///
  /// In en, this message translates to:
  /// **'Calculate your exact age and upcoming milestone birthdays.'**
  String get anniversaryCardsDescription;

  /// No description provided for @birthFactsDescription.
  ///
  /// In en, this message translates to:
  /// **'Discover your zodiac sign, birthstone, and interesting historical events from your birth date.'**
  String get birthFactsDescription;

  /// No description provided for @madeWithLove.
  ///
  /// In en, this message translates to:
  /// **'Made with ❤️ for birthday celebrations'**
  String get madeWithLove;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @messageSent.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your message! We\'ll get back to you soon.'**
  String get messageSent;

  /// No description provided for @couldNotLaunch.
  ///
  /// In en, this message translates to:
  /// **'Could not launch '**
  String get couldNotLaunch;

  /// No description provided for @privacyPolicyIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'Introduction'**
  String get privacyPolicyIntroTitle;

  /// No description provided for @privacyPolicyIntroContent.
  ///
  /// In en, this message translates to:
  /// **'Birthdate+ is committed to protecting your privacy. This Privacy Policy explains how we collect, use, and safeguard your information when you use our mobile application.'**
  String get privacyPolicyIntroContent;

  /// No description provided for @dataCollectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Information We Collect'**
  String get dataCollectionTitle;

  /// No description provided for @dataCollectionContent.
  ///
  /// In en, this message translates to:
  /// **'We collect the following types of information:\n\n• Birth date information that you voluntarily provide\n• Photos that you choose to include in birthday cards\n• Device information for app functionality\n• Usage statistics to improve our services'**
  String get dataCollectionContent;

  /// No description provided for @dataSharingTitle.
  ///
  /// In en, this message translates to:
  /// **'How We Use Your Information'**
  String get dataSharingTitle;

  /// No description provided for @dataSharingContent.
  ///
  /// In en, this message translates to:
  /// **'We use the collected information to:\n\n• Generate birthday cards and facts\n• Improve app functionality\n• Provide personalized content\n• Enhance user experience'**
  String get dataSharingContent;

  /// No description provided for @dataSecurityTitle.
  ///
  /// In en, this message translates to:
  /// **'Data Storage'**
  String get dataSecurityTitle;

  /// No description provided for @dataSecurityContent.
  ///
  /// In en, this message translates to:
  /// **'Your data is stored securely on our servers. We implement appropriate security measures to protect your personal information from unauthorized access, alteration, disclosure, or destruction.'**
  String get dataSecurityContent;

  /// No description provided for @contactTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactTitle;

  /// No description provided for @contactContent.
  ///
  /// In en, this message translates to:
  /// **'If you have any questions about this Privacy Policy, please contact us at:\n\nEmail: privacy@birthdateplus.app'**
  String get contactContent;

  /// No description provided for @birthstone.
  ///
  /// In en, this message translates to:
  /// **'Birthstone'**
  String get birthstone;

  /// No description provided for @birthFlower.
  ///
  /// In en, this message translates to:
  /// **'Birth Flower'**
  String get birthFlower;

  /// No description provided for @chineseZodiac.
  ///
  /// In en, this message translates to:
  /// **'Chinese Zodiac'**
  String get chineseZodiac;

  /// No description provided for @luckyNumber.
  ///
  /// In en, this message translates to:
  /// **'Lucky Number'**
  String get luckyNumber;

  /// No description provided for @zodiacSign.
  ///
  /// In en, this message translates to:
  /// **'Zodiac Sign'**
  String get zodiacSign;

  /// No description provided for @generation.
  ///
  /// In en, this message translates to:
  /// **'Generation'**
  String get generation;

  /// No description provided for @week.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get week;

  /// No description provided for @weeks.
  ///
  /// In en, this message translates to:
  /// **'Weeks'**
  String get weeks;

  /// No description provided for @choosePhoto.
  ///
  /// In en, this message translates to:
  /// **'Choose a Photo'**
  String get choosePhoto;

  /// No description provided for @yearsAndDays.
  ///
  /// In en, this message translates to:
  /// **'{years} years and {days} days'**
  String yearsAndDays(int years, int days);

  /// No description provided for @birthstoneGarnet.
  ///
  /// In en, this message translates to:
  /// **'Garnet'**
  String get birthstoneGarnet;

  /// No description provided for @birthstoneAmethyst.
  ///
  /// In en, this message translates to:
  /// **'Amethyst'**
  String get birthstoneAmethyst;

  /// No description provided for @birthstoneAquamarine.
  ///
  /// In en, this message translates to:
  /// **'Aquamarine'**
  String get birthstoneAquamarine;

  /// No description provided for @birthstoneDiamond.
  ///
  /// In en, this message translates to:
  /// **'Diamond'**
  String get birthstoneDiamond;

  /// No description provided for @birthstoneEmerald.
  ///
  /// In en, this message translates to:
  /// **'Emerald'**
  String get birthstoneEmerald;

  /// No description provided for @birthstonePearl.
  ///
  /// In en, this message translates to:
  /// **'Pearl'**
  String get birthstonePearl;

  /// No description provided for @birthstoneRuby.
  ///
  /// In en, this message translates to:
  /// **'Ruby'**
  String get birthstoneRuby;

  /// No description provided for @birthstonePeridot.
  ///
  /// In en, this message translates to:
  /// **'Peridot'**
  String get birthstonePeridot;

  /// No description provided for @birthstoneSapphire.
  ///
  /// In en, this message translates to:
  /// **'Sapphire'**
  String get birthstoneSapphire;

  /// No description provided for @birthstoneOpal.
  ///
  /// In en, this message translates to:
  /// **'Opal'**
  String get birthstoneOpal;

  /// No description provided for @birthstoneTopaz.
  ///
  /// In en, this message translates to:
  /// **'Topaz'**
  String get birthstoneTopaz;

  /// No description provided for @birthstoneTurquoise.
  ///
  /// In en, this message translates to:
  /// **'Turquoise'**
  String get birthstoneTurquoise;

  /// No description provided for @flowerCarnation.
  ///
  /// In en, this message translates to:
  /// **'Carnation'**
  String get flowerCarnation;

  /// No description provided for @flowerViolet.
  ///
  /// In en, this message translates to:
  /// **'Violet'**
  String get flowerViolet;

  /// No description provided for @flowerDaffodil.
  ///
  /// In en, this message translates to:
  /// **'Daffodil'**
  String get flowerDaffodil;

  /// No description provided for @flowerDaisy.
  ///
  /// In en, this message translates to:
  /// **'Daisy'**
  String get flowerDaisy;

  /// No description provided for @flowerLilyValley.
  ///
  /// In en, this message translates to:
  /// **'Lily of the Valley'**
  String get flowerLilyValley;

  /// No description provided for @flowerRose.
  ///
  /// In en, this message translates to:
  /// **'Rose'**
  String get flowerRose;

  /// No description provided for @flowerLarkspur.
  ///
  /// In en, this message translates to:
  /// **'Larkspur'**
  String get flowerLarkspur;

  /// No description provided for @flowerGladiolus.
  ///
  /// In en, this message translates to:
  /// **'Gladiolus'**
  String get flowerGladiolus;

  /// No description provided for @flowerAster.
  ///
  /// In en, this message translates to:
  /// **'Aster'**
  String get flowerAster;

  /// No description provided for @flowerMarigold.
  ///
  /// In en, this message translates to:
  /// **'Marigold'**
  String get flowerMarigold;

  /// No description provided for @flowerChrysanthemum.
  ///
  /// In en, this message translates to:
  /// **'Chrysanthemum'**
  String get flowerChrysanthemum;

  /// No description provided for @flowerPoinsettia.
  ///
  /// In en, this message translates to:
  /// **'Poinsettia'**
  String get flowerPoinsettia;

  /// No description provided for @zodiacAries.
  ///
  /// In en, this message translates to:
  /// **'Aries'**
  String get zodiacAries;

  /// No description provided for @zodiacTaurus.
  ///
  /// In en, this message translates to:
  /// **'Taurus'**
  String get zodiacTaurus;

  /// No description provided for @zodiacGemini.
  ///
  /// In en, this message translates to:
  /// **'Gemini'**
  String get zodiacGemini;

  /// No description provided for @zodiacCancer.
  ///
  /// In en, this message translates to:
  /// **'Cancer'**
  String get zodiacCancer;

  /// No description provided for @zodiacLeo.
  ///
  /// In en, this message translates to:
  /// **'Leo'**
  String get zodiacLeo;

  /// No description provided for @zodiacVirgo.
  ///
  /// In en, this message translates to:
  /// **'Virgo'**
  String get zodiacVirgo;

  /// No description provided for @zodiacLibra.
  ///
  /// In en, this message translates to:
  /// **'Libra'**
  String get zodiacLibra;

  /// No description provided for @zodiacScorpio.
  ///
  /// In en, this message translates to:
  /// **'Scorpio'**
  String get zodiacScorpio;

  /// No description provided for @zodiacSagittarius.
  ///
  /// In en, this message translates to:
  /// **'Sagittarius'**
  String get zodiacSagittarius;

  /// No description provided for @zodiacCapricorn.
  ///
  /// In en, this message translates to:
  /// **'Capricorn'**
  String get zodiacCapricorn;

  /// No description provided for @zodiacAquarius.
  ///
  /// In en, this message translates to:
  /// **'Aquarius'**
  String get zodiacAquarius;

  /// No description provided for @zodiacPisces.
  ///
  /// In en, this message translates to:
  /// **'Pisces'**
  String get zodiacPisces;

  /// No description provided for @chineseMonkey.
  ///
  /// In en, this message translates to:
  /// **'Monkey'**
  String get chineseMonkey;

  /// No description provided for @chineseRooster.
  ///
  /// In en, this message translates to:
  /// **'Rooster'**
  String get chineseRooster;

  /// No description provided for @chineseDog.
  ///
  /// In en, this message translates to:
  /// **'Dog'**
  String get chineseDog;

  /// No description provided for @chinesePig.
  ///
  /// In en, this message translates to:
  /// **'Pig'**
  String get chinesePig;

  /// No description provided for @chineseRat.
  ///
  /// In en, this message translates to:
  /// **'Rat'**
  String get chineseRat;

  /// No description provided for @chineseOx.
  ///
  /// In en, this message translates to:
  /// **'Ox'**
  String get chineseOx;

  /// No description provided for @chineseTiger.
  ///
  /// In en, this message translates to:
  /// **'Tiger'**
  String get chineseTiger;

  /// No description provided for @chineseRabbit.
  ///
  /// In en, this message translates to:
  /// **'Rabbit'**
  String get chineseRabbit;

  /// No description provided for @chineseDragon.
  ///
  /// In en, this message translates to:
  /// **'Dragon'**
  String get chineseDragon;

  /// No description provided for @chineseSnake.
  ///
  /// In en, this message translates to:
  /// **'Snake'**
  String get chineseSnake;

  /// No description provided for @chineseHorse.
  ///
  /// In en, this message translates to:
  /// **'Horse'**
  String get chineseHorse;

  /// No description provided for @chineseGoat.
  ///
  /// In en, this message translates to:
  /// **'Goat'**
  String get chineseGoat;

  /// No description provided for @generationBeta.
  ///
  /// In en, this message translates to:
  /// **'Generation Beta'**
  String get generationBeta;

  /// No description provided for @generationAlpha.
  ///
  /// In en, this message translates to:
  /// **'Generation Alpha'**
  String get generationAlpha;

  /// No description provided for @generationZ.
  ///
  /// In en, this message translates to:
  /// **'Generation Z'**
  String get generationZ;

  /// No description provided for @generationMillennial.
  ///
  /// In en, this message translates to:
  /// **'Millennial Generation'**
  String get generationMillennial;

  /// No description provided for @generationX.
  ///
  /// In en, this message translates to:
  /// **'Generation X'**
  String get generationX;

  /// No description provided for @generationBabyBoomer.
  ///
  /// In en, this message translates to:
  /// **'Baby Boomer Generation'**
  String get generationBabyBoomer;

  /// No description provided for @generationSilent.
  ///
  /// In en, this message translates to:
  /// **'Silent Generation'**
  String get generationSilent;

  /// No description provided for @upgradeToPremium.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium'**
  String get upgradeToPremium;

  /// No description provided for @removeWatermark.
  ///
  /// In en, this message translates to:
  /// **'Remove Watermark'**
  String get removeWatermark;

  /// No description provided for @removeWatermarkDescription.
  ///
  /// In en, this message translates to:
  /// **'Share your photos without the Birthdate Plus watermark'**
  String get removeWatermarkDescription;

  /// No description provided for @highQualityExport.
  ///
  /// In en, this message translates to:
  /// **'High Quality Export'**
  String get highQualityExport;

  /// No description provided for @highQualityExportDescription.
  ///
  /// In en, this message translates to:
  /// **'Export your photos in the highest quality for perfect sharing'**
  String get highQualityExportDescription;

  /// No description provided for @adFreeExperience.
  ///
  /// In en, this message translates to:
  /// **'Ad-Free Experience'**
  String get adFreeExperience;

  /// No description provided for @adFreeExperienceDescription.
  ///
  /// In en, this message translates to:
  /// **'Enjoy a clean, distraction-free interface'**
  String get adFreeExperienceDescription;

  /// No description provided for @upgradeNowWithPrice.
  ///
  /// In en, this message translates to:
  /// **'Upgrade Now - \$2.99'**
  String get upgradeNowWithPrice;

  /// No description provided for @restorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get restorePurchases;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'es', 'hi', 'ja', 'ko', 'pt', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
    case 'hi': return AppLocalizationsHi();
    case 'ja': return AppLocalizationsJa();
    case 'ko': return AppLocalizationsKo();
    case 'pt': return AppLocalizationsPt();
    case 'zh': return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
