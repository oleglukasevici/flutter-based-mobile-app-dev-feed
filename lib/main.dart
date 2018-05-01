import 'dart:io';

import 'package:awesome_dev/config/application.dart';
import 'package:awesome_dev/config/routes.dart';
import 'package:awesome_dev/ui/about.dart';
import 'package:awesome_dev/ui/archives.dart';
import 'package:awesome_dev/ui/favorites.dart';
import 'package:awesome_dev/ui/latest_news.dart';
import 'package:awesome_dev/ui/tags.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stetho/flutter_stetho.dart';
import 'package:logging/logging.dart';

void main() {
  assert(() {
    //assert will execute only in Debug Mode
    //Note in particular the () at the end of the call -
    // assert can only operate on a boolean, so just passing in a function doesn't work.
    HttpOverrides.global = new StethoHttpOverrides();
    return true;
  }());

  runApp(new AwesomeDevApp());
}

class AwesomeDevApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Logger.root // Optional
      ..level = Level.ALL
      ..onRecord.listen((rec) {
        print('${rec.level.name}: ${rec.time}: ${rec.message}');
      });

    return new MaterialApp(
      title: 'Awesome Dev',
      theme: new ThemeData(
        primaryColor: Colors.green,
        backgroundColor: Colors.white,
      ),
      home: new AwesomeDev(),
    );
  }
}

class AwesomeDev extends StatefulWidget {
  static const String routeName = '/material/bottom_navigation';

  @override
  State<StatefulWidget> createState() => new _AwesomeDevState();
}

class _AwesomeDevState extends State<AwesomeDev> with TickerProviderStateMixin {
//  SearchBar searchBar;
  int _currentIndex = 0;
  List<NavigationIconView> _navigationViews;

  void onAppBarMenuItemSelected(String value) {
    print("Selected value from popup menu: [$value]");
    if (value == "about") {
      showGalleryAboutDialog(context);
    } else if (value == 'send-feedback') {
      //TODO
    }
  }

  _AwesomeDevState() {
    final router = new Router();
    Routes.configureRoutes(router);
    Application.router = router;
  }

  @override
  void initState() {
    super.initState();

    _navigationViews = <NavigationIconView>[
      new NavigationIconView(
        icon: const Icon(Icons.new_releases),
        title: 'Latest',
//        color: Colors.deepPurple,
        vsync: this,
      ),
      new NavigationIconView(
        icon: const Icon(Icons.favorite),
        title: 'Favorites',
        color: Colors.indigo,
        vsync: this,
      ),
      new NavigationIconView(
        icon: const Icon(Icons.archive),
        title: 'Archives',
        color: Colors.deepOrange,
        vsync: this,
      ),
      new NavigationIconView(
        icon: const Icon(Icons.label),
        title: 'Tags',
        color: Colors.teal,
        vsync: this,
      ),
    ];

    for (NavigationIconView view in _navigationViews) {
      view.controller.addListener(_rebuild);
    }
    _navigationViews[_currentIndex].controller.value = 1.0;
  }

  @override
  void dispose() {
    for (NavigationIconView view in _navigationViews) view.controller.dispose();
    super.dispose();
  }

  void _rebuild() {
    setState(() {
      // Rebuild in order to animate views.
    });
  }

  Widget _buildTransitionsStack() {
    if (_currentIndex == 0) {
      return const LatestNews();
    }
    if (_currentIndex == 1) {
      return const FavoriteNews();
    }
    if (_currentIndex == 2) {
      return const ArticleArchives();
    }
    if (_currentIndex == 3) {
      return const Tags();
    }

    final List<FadeTransition> transitions = <FadeTransition>[];

    for (NavigationIconView view in _navigationViews) {
      transitions.add(view.transition(BottomNavigationBarType.fixed, context));
    }

    // We want to have the newly animating (fading in) views on top.
    transitions.sort((FadeTransition a, FadeTransition b) {
      final Animation<double> aAnimation = a.opacity;
      final Animation<double> bAnimation = b.opacity;
      final double aValue = aAnimation.value;
      final double bValue = bAnimation.value;
      return aValue.compareTo(bValue);
    });

    return new Stack(children: transitions);
  }

  @override
  Widget build(BuildContext context) {
    final BottomNavigationBar botNavBar = new BottomNavigationBar(
      items: _navigationViews
          .map((NavigationIconView navigationView) => navigationView.item)
          .toList(),
      currentIndex: _currentIndex,
      type: BottomNavigationBarType.fixed,
      onTap: (int index) {
        setState(() {
          _navigationViews[_currentIndex].controller.reverse();
          _currentIndex = index;
          _navigationViews[_currentIndex].controller.forward();
        });
      },
    );

    return new Scaffold(
      appBar: new AppBar(
        title: const Text('Awesome Dev'),
        actions: <Widget>[
          new PopupMenuButton<String>(
            onSelected: onAppBarMenuItemSelected,
            itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
//                  const PopupMenuItem<String>(
//                      value: 'settings', child: const Text('Settings')),
                  const PopupMenuItem<String>(
                      value: 'about', child: const Text('About')),
                  const PopupMenuItem<String>(
                      value: 'send-feedback',
                      child: const Text('Send Feedback')),
                ],
          ),
        ],
      ),
      body: new Center(child: _buildTransitionsStack()),
      bottomNavigationBar: botNavBar,
    );
  }
}

class NavigationIconView {
  NavigationIconView({
    Widget icon,
    String title,
    Color color,
    TickerProvider vsync,
  })  : _icon = icon,
        _color = color,
        _title = title,
        item = new BottomNavigationBarItem(
          icon: icon,
          title: new Text(title),
          backgroundColor: color,
        ),
        controller = new AnimationController(
          duration: kThemeAnimationDuration,
          vsync: vsync,
        ) {
    _animation = new CurvedAnimation(
      parent: controller,
      curve: const Interval(0.5, 1.0, curve: Curves.fastOutSlowIn),
    );
  }

  final Widget _icon;
  final Color _color;
  final String _title;
  final BottomNavigationBarItem item;
  final AnimationController controller;
  CurvedAnimation _animation;

  FadeTransition transition(
      BottomNavigationBarType type, BuildContext context) {
    Color iconColor;
    if (type == BottomNavigationBarType.shifting) {
      iconColor = _color;
    } else {
      final ThemeData themeData = Theme.of(context);
      iconColor = themeData.brightness == Brightness.light
          ? themeData.primaryColor
          : themeData.accentColor;
    }

    return new FadeTransition(
      opacity: _animation,
      child: new SlideTransition(
        position: new Tween<Offset>(
          begin: const Offset(0.0, 0.02), // Slightly down.
          end: Offset.zero,
        ).animate(_animation),
        child: new IconTheme(
          data: new IconThemeData(
            color: iconColor,
            size: 120.0,
          ),
          child: new Semantics(
            label: 'Placeholder for $_title tab',
            child: _icon,
          ),
        ),
      ),
    );
  }
}
