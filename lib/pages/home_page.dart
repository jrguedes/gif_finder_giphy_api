import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';

import 'gif_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _search;
  int _offset = 0;
  String _apiKey = 'your_giphy_api_key';

  Future<Map> _getGifs() async {
    http.Response response;

    if (_search == null || _search.isEmpty) {
      response = await http.get('https://api.giphy.com/v1/gifs/trending?api_key=$_apiKey&limit=20&rating=G');
    } else {
      response = await http.get(
          'https://api.giphy.com/v1/gifs/search?api_key=$_apiKey&q=$_search&limit=19&offset=$_offset&rating=G&lang=en');
    }
    return json.decode(response.body);
  }

  @override
  void initState() {
    super.initState();
    _getGifs().then((map) {
      print(map);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('images/dev-logo-lg.7404c00322a8.gif'),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 15, left: 10, right: 10),
            child: TextField(
              decoration: InputDecoration(
                  labelText: 'Search Here',
                  labelStyle: TextStyle(color: Colors.white, fontSize: 23),
                  border: OutlineInputBorder()),
              style: TextStyle(color: Colors.white),
              onSubmitted: (value) {
                setState(() {
                  _search = value;
                  _offset = 0;
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder(
                future: _getGifs(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      return Container(
                        width: 200,
                        height: 200,
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                          strokeWidth: 4,
                        ),
                      );
                    default:
                      if (snapshot.hasError) {
                        return Container();
                      } else {
                        return _createGifTable(context, snapshot);
                      }
                  }
                }),
          )
        ],
      ),
    );
  }

  int _getCount(List data) {
    if (_search == null) {
      return data.length;
    } else {
      return data.length + 1;
    }
  }

  Widget _createGifTable(context, snapshot) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: GridView.builder(
        padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: _getCount(snapshot.data['data']),
        itemBuilder: (context, index) {
          if ((_search == null || _search.isEmpty) || index < snapshot.data['data'].length) {
            return GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => GifPage(snapshot.data['data'][index])));
              },
              onLongPress: () {
                Share.share(snapshot.data['data'][index]['images']['fixed_height']['url']);
              },
              child: getGifBox(snapshot, index),
            );
          } else {
            return Container(
              child: GestureDetector(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.add,
                      size: 70,
                      color: Colors.white,
                    ),
                    Text(
                      'Load more...',
                      style: TextStyle(fontSize: 22, color: Colors.white),
                    )
                  ],
                ),
                onTap: () {
                  setState(() {
                    _offset += 19;
                  });
                },
              ),
            );
          }
        },
      ),
    );
  }

  Widget getGifBox(snapshot, int index) {
    return Stack(alignment: Alignment.center, children: <Widget>[
      CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.pink),
        strokeWidth: 2,
      ),
      FadeInImage.memoryNetwork(
        placeholder: kTransparentImage,
        image: snapshot.data['data'][index]['images']['fixed_height']['url'],
        height: 300,
        fit: BoxFit.cover,
      ),
    ]);
  }
}
