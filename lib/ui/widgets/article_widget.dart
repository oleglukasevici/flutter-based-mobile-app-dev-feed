import 'package:awesome_dev/api/articles.dart';
import 'package:awesome_dev/config/application.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ArticleWidget extends StatefulWidget {
  ArticleWidget({
    this.article,
    this.onCardClick,
    @required this.onStarClick,
  });

  final Article article;
  final VoidCallback onCardClick;
  final VoidCallback onStarClick;

  @override
  State<StatefulWidget> createState() => ArticleWidgetState();
}

class ArticleWidgetState extends State<ArticleWidget> {
  void _launchURL() async {
    try {
      await launch(
        widget.article.url,
        option: CustomTabsOption(
          toolbarColor: Theme.of(context).primaryColor,
          enableDefaultShare: true,
          enableUrlBarHiding: true,
          showPageTitle: true,
        ),
      );
    } catch (e) {
      // An exception is thrown if browser app is not installed on Android device.
      debugPrint(e.toString());
      Scaffold.of(context).showSnackBar(SnackBar(
          content: Text(
              'Could not launch URL ($this.article.url): ${e.toString()}')));
    }
  }

  void _handleStarClick() async {
    final prefs = await SharedPreferences.getInstance();
    final newFavoritesList = <String>[];
    final favorites = prefs.getStringList("favs") ?? <String>[];
    newFavoritesList.addAll(favorites);
    final String favoriteData = widget.article.toSharedPreferencesString();
    if (!widget.article.starred) {
      //previous state
      newFavoritesList.add(favoriteData);
    } else {
      newFavoritesList.remove(favoriteData);
    }
    prefs.setStringList("favs", newFavoritesList);
    if (widget.onStarClick != null) {
      widget.onStarClick();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tagsWidgets = <Widget>[];
    if (widget.article.tags != null) {
      for (var tag in widget.article.tags) {
        tagsWidgets.add(Expanded(
            child: GestureDetector(
          onTap: () => Application.router.navigateTo(context, "/tags/$tag",
              transition: TransitionType.fadeIn),
          child: Text(tag),
        )));
      }
    }

    return GestureDetector(
        onTap: widget.onCardClick != null ? widget.onCardClick : _launchURL,
        child: Container(
            padding: const EdgeInsets.only(top: 8.0),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Column(
                          children: <Widget>[
                            Align(
                                alignment: Alignment.topLeft,
                                child: Text(widget.article.title,
                                    textAlign: TextAlign.left,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15.0))),
                            Padding(padding: const EdgeInsets.all(3.0)),
                            Align(
                              alignment: Alignment.topLeft,
                              child: Text(widget.article.domain,
                                  style: const TextStyle(color: Colors.black38),
                                  textAlign: TextAlign.left),
                            )
                          ],
                        ),
                      ),
                    ),
                    Stack(
                      children: <Widget>[
                        widget.article.screenshot != null &&
                                widget.article.screenshot.dataBytes != null
                            ? Hero(
                                child: Image.memory(
                                  widget.article.screenshot.dataBytes,
                                  width: 110.0,
                                ),
                                tag: widget.article.id,
                              )
                            : Container(),
                        IconButton(
                            icon: widget.article.starred
                                ? Icon(Icons.favorite)
                                : Icon(Icons.favorite_border),
                            color: widget.article.starred ? Colors.red : null,
                            onPressed: _handleStarClick,
                            alignment: Alignment.topRight,
                            padding: const EdgeInsets.only(left: 85.0))
                      ],
                    )
                  ],
                ),

                Padding(padding: const EdgeInsets.all(3.0)),

                //Tags
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: tagsWidgets),

                Padding(padding: const EdgeInsets.all(3.0)),

                Divider(height: 10.0, color: Theme.of(context).primaryColor)
              ],
            )));
  }
}
