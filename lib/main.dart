import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'device_provider.dart';
import 'device_screen.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool isDark = ref.watch(isDarkProvider);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Device',
      theme: isDark ? ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        backgroundColor: Colors.indigo,
        pageTransitionsTheme: MyPageTransitionsTheme(),
      ) :ThemeData.light().copyWith(
        scaffoldBackgroundColor: Colors.white,
        backgroundColor: Colors.indigo,
        pageTransitionsTheme: MyPageTransitionsTheme(),
      ),
      home: DeviceScreen(),
    );
  }
}

// Swipe to cancel
// From left to right
class MyPageTransitionsTheme extends PageTransitionsTheme {
  const MyPageTransitionsTheme();
  static const PageTransitionsBuilder builder = CupertinoPageTransitionsBuilder();
  @override
  Widget buildTransitions<T>(
      PageRoute<T> route,
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
      ) {
    return builder.buildTransitions<T>(route, context, animation, secondaryAnimation, child);
  }
}
