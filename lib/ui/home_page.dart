import 'package:buscador_gifs/ui/git_page.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';

import 'package:transparent_image/transparent_image.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _search;

  int _offset = 0;

  Future<Map> _getSearch() async {
    http.Response response;

    if (_search == null)
      response = await http.get(
          "https://api.giphy.com/v1/gifs/trending?api_key=JRY4bFHu1gfXkaFUy7t3cKE59NHF4ZmJ&limit=19&rating=G");
    else
      response = await http.get(
          "https://api.giphy.com/v1/gifs/search?api_key=JRY4bFHu1gfXkaFUy7t3cKE59NHF4ZmJ&q=$_search&limit=19&offset=$_offset&rating=G&lang=en");

    return json.decode(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network(
            'https://developers.giphy.com/static/img/dev-logo-lg.7404c00322a8.gif'),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(12.0),
            child: TextField(
              onSubmitted: (text) {
                if(text.trim().isEmpty)
                  setState(() {
                    _search = null;
                  });

                setState(() {
                  _search = text;
                  _offset = 0;
                });
              },
              style: TextStyle(color: Colors.white, fontSize: 18.0),
              decoration: InputDecoration(
                  labelText: "Pesquise aqui!",
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder()),
            ),
          ),
          Expanded(
            child: FutureBuilder(
                future: _getSearch(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      return Container(
                        width: 200.0,
                        height: 200.0,
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 5.0,
                        ),
                      );
                    default:
                      if (snapshot.hasError)
                        return Container(
                          color: Colors.green
                        );
                      else
                        return _createGifsTable(context, snapshot);
                  }
                }),
          )
        ],
      ),
    );
  }

  int _getCount(List data) {
    if(_search == null) {
      return data.length;
    } else {
      return data.length + 1;
    }
  }

  Widget _createGifsTable(context, snapshot) {
    return GridView.builder(
        padding: EdgeInsets.all(10.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 10.0, mainAxisSpacing: 10.0),
        itemCount: _getCount(snapshot.data['data']),
        itemBuilder: (context, index) {
          if(_search == null ||  index < snapshot.data['data'].length) {
            return GestureDetector(
              child: FadeInImage.memoryNetwork(
                  placeholder: kTransparentImage,
                  image: snapshot.data['data'][index]['images']['fixed_height']['url'],
                  height: 300.0,
                  fit: BoxFit.cover,
              ),
              onTap: () {
                print(snapshot.data["data"][index]);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => GifPage(snapshot.data["data"][index]))
                );
              },
              onLongPress: () {
                Share.share(snapshot.data["data"][index]["images"]["fixed_height"]["url"]);
              },
            );
          } else {
            return Container(
              child: GestureDetector(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.add, size: 70.0, color: Colors.white),
                    Text('Carregar mais...', style: TextStyle(color: Colors.white, fontSize: 22.0))
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

        });
  }
}
