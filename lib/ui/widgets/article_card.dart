import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:awesome_dev/api/articles.dart';

class ArticleCard extends StatefulWidget {
  ArticleCard({
    this.article,
    @required this.onCardClick,
    @required this.onStarClick,
  });

  final Article article;

  final VoidCallback onCardClick;
  final VoidCallback onStarClick;

  @override
  State<StatefulWidget> createState() => new ArticleCardState();
}

class ArticleCardState extends State<ArticleCard> {
  final _biggerFont = const TextStyle(fontSize: 18.0);

  @override
  Widget build(BuildContext context) {
    final tagsWidgets = <Widget>[];
    if (widget.article.tags != null) {
      for (var tag in widget.article.tags) {
        tagsWidgets.add(new Text(tag));
      }
    }

    return new GestureDetector(
      onTap: widget.onCardClick,
      child: new Card(
          child: new Container(
            padding: const EdgeInsets.all(8.0),

              child: new Column(
                children: <Widget>[

                  new Container(
                      padding: const EdgeInsets.only(bottom: 5.0),
                      child: new Row(
                        children: <Widget>[
                          new Text(widget.article.domain),

                          new Expanded(child: new Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              new IconButton(
                                icon: widget.article.starred
                                    ? new Icon(Icons.favorite)
                                    : new Icon(Icons.favorite_border),
                                color: widget.article.starred ? Colors.red : null,
                                onPressed: widget.onStarClick,
                                alignment: Alignment.topRight,
                              )
                            ],
                          ))
                        ],
                      )),


                  new Row(
                    children: <Widget>[
                      widget.article.screenshot != null &&
                          widget.article.screenshot.data != null
                          ? new Hero(
                        child: new Image.memory(
                          base64.decode(widget.article.screenshot.data),
                          width: 150.0,
                        ),
                        tag: widget.article.id,
                      )
                          : new Container(),
                      new Expanded(
                        child: new Stack(
                          children: <Widget>[
                            new Align(
                              child: new Padding(
                                child: new Text(widget.article.title,
                                    style: _biggerFont),
                                padding: const EdgeInsets.all(8.0),
                              ),
                              alignment: Alignment.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  new Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: new Align(
                        alignment: Alignment.bottomLeft,
                        child: new Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: tagsWidgets),
                      )),
                ],
              )),
    ),
    );
  }
}