import 'package:flutter/material.dart';
import 'localization/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'settings/settings_controller.dart';
import 'pages/home.dart';
import 'pages/login.dart';
import 'solutions/minidrama/pages/drama_channel.dart';
import 'solutions/minidrama/pages/ad_player.dart';
import 'solutions/minidrama/pages/drama_player.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loader_overlay/loader_overlay.dart';

/// The Widget that configures your application.
class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.settingsController,
  });

  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    // Glue the SettingsController to the MaterialApp.
    //
    // The ListenableBuilder Widget listens to the SettingsController for changes.
    // Whenever the user updates their settings, the MaterialApp is rebuilt.
    return ListenableBuilder(
        listenable: settingsController,
        builder: (BuildContext context, Widget? child) {
          return ScreenUtilInit(
              designSize: const Size(375, 812),
              minTextAdapt: true,
              splitScreenMode: true,
              // Use builder only if you need to use library outside ScreenUtilInit context
              builder: (_, Widget? child) {
                return GlobalLoaderOverlay(
                  overlayColor: Colors.transparent,
                  child: MaterialApp(
                    // Providing a restorationScopeId allows the Navigator built by the
                    // MaterialApp to restore the navigation stack when a user leaves and
                    // returns to the app after it has been killed while running in the
                    // background.
                    restorationScopeId: 'app',

                    // Provide the generated AppLocalizations to the MaterialApp. This
                    // allows descendant Widgets to display the correct translations
                    // depending on the user's locale.
                    localizationsDelegates: const [
                      AppLocalizations.delegate,
                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                      GlobalCupertinoLocalizations.delegate,
                    ],
                    supportedLocales: const [
                      Locale('en', ''), // English, no country code
                    ],

                    // Use AppLocalizations to configure the correct application title
                    // depending on the user's locale.
                    //
                    // The appTitle is defined in .arb files found in the localization
                    // directory.
                    onGenerateTitle: (BuildContext context) =>
                        AppLocalizations.of(context)!.appTitle,

                    // Define a light and dark color theme. Then, read the user's
                    // preferred ThemeMode (light, dark, or system default) from the
                    // SettingsController to display the correct theme.
                    theme: ThemeData(),
                    darkTheme: ThemeData.dark(),
                    themeMode: settingsController.themeMode,

                    // Define a function to handle named routes in order to support
                    // Flutter web url navigation and deep linking.
                    onGenerateRoute: (RouteSettings routeSettings) {
                      return MaterialPageRoute<void>(
                        settings: routeSettings,
                        builder: (BuildContext context) {
                          switch (routeSettings.name) {
                            // case LoginView.routeName:
                            //   return const LoginView();
                            case DramaChannelView.routeName:
                              return const DramaChannelView();
                            case AdPlayerView.routeName:
                              return const AdPlayerView();
                            case DramaPlayerView.routeName:
                              return const DramaPlayerView();
                            default:
                              return const HomeView();
                          }
                        },
                      );
                    },
                  ),
                );
              });
        });
  }
}
