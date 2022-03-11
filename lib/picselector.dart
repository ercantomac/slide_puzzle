import 'dart:html';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:slide_puzzle_by_ercan/picturemode.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyRoute extends MaterialPageRoute {
  MyRoute({dynamic builder}) : super(builder: builder);
  @override
  Duration get transitionDuration => const Duration(seconds: 1);
}

class PicSelector extends StatefulWidget {
  const PicSelector({Key? key}) : super(key: key);

  @override
  _PicSelectorState createState() => _PicSelectorState();
}

class _PicSelectorState extends State<PicSelector> {
  late SharedPreferences _sp;
  final List<int> _bestScores = <int>[-1, -1, -1, -1];
  Future<void> _fetch() async {
    _sp = await SharedPreferences.getInstance();
    for (int i = 0; i < 4; i++) {
      if (_sp.getInt('_pic${(i + 1)}BestScore') != null) {
        _bestScores[i] = _sp.getInt('_pic${(i + 1)}BestScore')!;
      }
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        title: const Text('Select a picture'),
        centerTitle: true,
      ),
      body: Center(
        child: SizedBox(
          width: (sqrt(MediaQuery.of(context).size.width) * sqrt(MediaQuery.of(context).size.height)) * 0.8,
          child: GridView.count(
            padding: EdgeInsets.symmetric(horizontal: (sqrt(MediaQuery.of(context).size.width) * sqrt(MediaQuery.of(context).size.height)) / 24),
            physics: const BouncingScrollPhysics(),
            shrinkWrap: true,
            crossAxisCount: 2,
            crossAxisSpacing: (sqrt(MediaQuery.of(context).size.width) * sqrt(MediaQuery.of(context).size.height)) / 48,
            mainAxisSpacing: (sqrt(MediaQuery.of(context).size.width) * sqrt(MediaQuery.of(context).size.height)) / 48,
            children: <InkWell>[
              for (int i = 1; i < 5; i++)
                InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  onTap: () {
                    document.documentElement?.requestFullscreen();
                    Navigator.of(context).push(MyRoute(builder: (BuildContext context) => PictureMode(i))).then((value) {
                      SharedPreferences.getInstance().then((SharedPreferences _sp) {
                        for (int i = 0; i < 4; i++) {
                          if (_sp.getInt('_pic${(i + 1)}BestScore') != null) {
                            _bestScores[i] = _sp.getInt('_pic${(i + 1)}BestScore')!;
                          }
                        }
                        setState(() {});
                      });
                    });
                  },
                  child: Stack(
                    children: <Widget>[
                      Hero(
                        tag: '$i',
                        createRectTween: (Rect? begin, Rect? end) {
                          return MaterialRectCenterArcTween(begin: begin, end: end);
                        },
                        child: ClipRRect(
                          borderRadius: const BorderRadius.all(Radius.circular(16.0)),
                          child: Image.asset(
                            'assets/$i/original.jpg',
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: Center(
                          child: Container(
                            color: Colors.black38,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Text>[
                                Text(
                                  'Best score: ${(_bestScores[i - 1] == -1) ? ('-') : _bestScores[i - 1]}',
                                  style: TextStyle(
                                    fontSize: (sqrt(MediaQuery.of(context).size.width) * sqrt(MediaQuery.of(context).size.height)) / 24,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
