import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/src/gestures/events.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slide_puzzle_by_ercan/experimentmode.dart';

class ExperimentMode2 extends StatefulWidget {
  const ExperimentMode2(/*this._displayAd, */ {Key? key}) : super(key: key);
  //final Function _displayAd;
  @override
  State<ExperimentMode2> createState() => _ExperimentMode2State();
}

class _ExperimentMode2State extends State<ExperimentMode2> with TickerProviderStateMixin {
  final StreamController<int> _chronometer = StreamController<int>();
  late int _colorCnt, _bestScore = -1, _size = 960, _movement = 160, _chronometerValue = 0;
  final ValueNotifier<int> _moveCnt = ValueNotifier<int>(0), _inPosition = ValueNotifier<int>(0);
  late double _opacity = 0.0, _radius = 24.0, _squareDimension = 0.0, _squareRadius = 0.0, _textShadow = 0.0, _textFontSize = 0.0;
  final List<int> _blankPosition = <int>[3, 3], _inversionControl = <int>[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15];
  final List<List<int>> _items = <List<int>>[
    <int>[0, 0, 0, 0],
    <int>[0, 0, 0, 0],
    <int>[0, 0, 0, 0],
    <int>[0, 0, 0]
  ];
  final List<List<ValueNotifier<List<int>>>> _margins = <List<ValueNotifier<List<int>>>>[
    <ValueNotifier<List<int>>>[
      ValueNotifier<List<int>>(<int>[0, 0, 0]),
      ValueNotifier<List<int>>(<int>[0, 0, 0]),
      ValueNotifier<List<int>>(<int>[0, 0, 0]),
      ValueNotifier<List<int>>(<int>[0, 0, 0])
    ],
    <ValueNotifier<List<int>>>[
      ValueNotifier<List<int>>(<int>[0, 0, 0]),
      ValueNotifier<List<int>>(<int>[0, 0, 0]),
      ValueNotifier<List<int>>(<int>[0, 0, 0]),
      ValueNotifier<List<int>>(<int>[0, 0, 0])
    ],
    <ValueNotifier<List<int>>>[
      ValueNotifier<List<int>>(<int>[0, 0, 0]),
      ValueNotifier<List<int>>(<int>[0, 0, 0]),
      ValueNotifier<List<int>>(<int>[0, 0, 0]),
      ValueNotifier<List<int>>(<int>[0, 0, 0])
    ],
    <ValueNotifier<List<int>>>[
      ValueNotifier<List<int>>(<int>[0, 0, 0]),
      ValueNotifier<List<int>>(<int>[0, 0, 0]),
      ValueNotifier<List<int>>(<int>[0, 0, 0])
    ],
  ];
  late SharedPreferences _sp;
  late Timer _timer;
  final AudioPlayer _player = AudioPlayer();
  final List<List<ValueNotifier<double>>> _hoverSize = <List<ValueNotifier<double>>>[
    <ValueNotifier<double>>[ValueNotifier<double>(1.0), ValueNotifier<double>(1.0), ValueNotifier<double>(1.0), ValueNotifier<double>(1.0)],
    <ValueNotifier<double>>[ValueNotifier<double>(1.0), ValueNotifier<double>(1.0), ValueNotifier<double>(1.0), ValueNotifier<double>(1.0)],
    <ValueNotifier<double>>[ValueNotifier<double>(1.0), ValueNotifier<double>(1.0), ValueNotifier<double>(1.0), ValueNotifier<double>(1.0)],
    <ValueNotifier<double>>[ValueNotifier<double>(1.0), ValueNotifier<double>(1.0), ValueNotifier<double>(1.0)],
  ];
  late bool _isShuffling = false;
  late int _picture = 1;

  Future<void> _fetch() async {
    _sp = await SharedPreferences.getInstance();
    if (_sp.getInt('_bestScore') != null) {
      _bestScore = _sp.getInt('_bestScore')!;
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _fetch();
    while (true) {
      _inversionControl.shuffle();
      int inversionCnt = 0;
      for (int i = 0; i < _inversionControl.length; i++) {
        for (int j = i + 1; j < _inversionControl.length; j++) {
          if (_inversionControl[i] > _inversionControl[j]) {
            inversionCnt++;
          }
        }
      }
      if (inversionCnt % 2 == 0) {
        //SOLVABLE
        for (int i = 0; i < 4; i++) {
          _items[i][0] = _inversionControl[0 + (i * 4)];
          _items[i][1] = _inversionControl[1 + (i * 4)];
          _items[i][2] = _inversionControl[2 + (i * 4)];
          if (i < 3) {
            _items[i][3] = _inversionControl[3 + (i * 4)];
          }
        }
        break;
      }
    }
    int cnt = 0;
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < _margins[i].length; j++) {
        if (((j + 1) + (i * 4)) == _items[i][j]) {
          _margins[i][j].value[2] = 1;
          _margins[i][j].notifyListeners();
          cnt++;
        } else {
          _margins[i][j].value[2] = 0;
          _margins[i][j].notifyListeners();
        }
      }
    }
    _inPosition.value = cnt;
    _chronometer.add(_chronometerValue);
    WidgetsBinding.instance!.addPostFrameCallback((Duration timeStamp) {
      Timer(const Duration(milliseconds: 600), () {
        setState(() {
          _opacity = 1.0;
        });
        for (int i = 0; i < 4; i++) {
          for (int j = 0; j < _margins[i].length; j++) {
            _margins[i][j].value[0] = (j * _movement).toInt();
            _margins[i][j].value[1] = (i * _movement).toInt();
            _margins[i][j].notifyListeners();
          }
        }
        _resumeChronometer();
      });
    });
  }

  void _shuffle() async {
    await _player.setAsset('assets/Shuffle-Reset.wav');
    HapticFeedback.lightImpact();
    while (true) {
      _inversionControl.shuffle();
      int inversionCnt = 0;
      for (int i = 0; i < _inversionControl.length; i++) {
        for (int j = i + 1; j < _inversionControl.length; j++) {
          if (_inversionControl[i] > _inversionControl[j]) {
            inversionCnt++;
          }
        }
      }
      if (inversionCnt % 2 == 0) {
        //SOLVABLE
        for (int i = 0; i < 4; i++) {
          _items[i][0] = _inversionControl[0 + (i * 4)];
          _items[i][1] = _inversionControl[1 + (i * 4)];
          _items[i][2] = _inversionControl[2 + (i * 4)];
          if (i < 3) {
            _items[i][3] = _inversionControl[3 + (i * 4)];
          }
        }
        break;
      }
    }
    setState(() {
      _squareDimension /= 1.5;
    });
    _blankPosition[0] = 3;
    _blankPosition[1] = 3;
    int cnt = 0;
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < _margins[i].length; j++) {
        _margins[i][j].value[0] = (j * _movement).toInt();
        _margins[i][j].value[1] = (i * _movement).toInt();
        if (((j + 1) + (i * 4)) == _items[i][j]) {
          _margins[i][j].value[2] = 1;
          cnt++;
        } else {
          _margins[i][j].value[2] = 0;
        }
        _margins[i][j].notifyListeners();
      }
    }
    Timer(const Duration(milliseconds: 300), () {
      _inPosition.value = cnt;
      _moveCnt.value = 0;
      _timer.cancel();
      _chronometerValue = 0;
      _chronometer.add(_chronometerValue);
      _resumeChronometer();
      _player.play();
      setState(() {
        _squareDimension *= 1.5;
      });
      Timer(const Duration(seconds: 1), () {
        setState(() {
          _isShuffling = false;
        });
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _moveCnt.dispose();
    _inPosition.dispose();
    for (int i = 0; i < _margins.length; i++) {
      for (int j = 0; j < _margins[i].length; j++) {
        _margins[i][j].dispose();
      }
    }
  }

  void _resumeChronometer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      _chronometerValue++;
      _chronometer.add(_chronometerValue);
    });
  }

  void _tap(int row, int col) async {
    int actualCol = (_margins[row][col].value[0] == 0)
            ? 0
            : (_margins[row][col].value[0] == _movement)
                ? 1
                : (_margins[row][col].value[0] == (_movement * 2))
                    ? 2
                    : (_margins[row][col].value[0] == (_movement * 3))
                        ? 3
                        : -1,
        actualRow = (_margins[row][col].value[1] == 0)
            ? 0
            : (_margins[row][col].value[1] == _movement)
                ? 1
                : (_margins[row][col].value[1] == (_movement * 2))
                    ? 2
                    : (_margins[row][col].value[1] == (_movement * 3))
                        ? 3
                        : -1;
    if (actualCol == _blankPosition[1] || actualRow == _blankPosition[0]) {
      List<int> oldBlankPosition = <int>[_blankPosition[0], _blankPosition[1]];
      _blankPosition[0] = actualRow;
      _blankPosition[1] = actualCol;
      int cnt = 0;
      for (int i = 0; i < _items.length; i++) {
        for (int j = 0; j < _items[i].length; j++) {
          int _column = (_margins[i][j].value[0] == 0)
              ? 0
              : (_margins[i][j].value[0] == _movement)
                  ? 1
                  : (_margins[i][j].value[0] == (_movement * 2))
                      ? 2
                      : (_margins[i][j].value[0] == (_movement * 3))
                          ? 3
                          : -1;
          int _row = (_margins[i][j].value[1] == 0)
              ? 0
              : (_margins[i][j].value[1] == _movement)
                  ? 1
                  : (_margins[i][j].value[1] == (_movement * 2))
                      ? 2
                      : (_margins[i][j].value[1] == (_movement * 3))
                          ? 3
                          : -1;
          if (actualCol == oldBlankPosition[1]) {
            // SAME COLUMN
            if (actualRow < oldBlankPosition[0]) {
              // SLIDE TO BOTTOM
              if (_column == actualCol && _row <= oldBlankPosition[0] && _row >= actualRow) {
                _margins[i][j].value[1] += _movement;
                _margins[i][j].notifyListeners();
              }
            } else {
              // SLIDE TO TOP
              if (_column == actualCol && _row >= oldBlankPosition[0] && _row <= actualRow) {
                _margins[i][j].value[1] -= _movement;
                _margins[i][j].notifyListeners();
              }
            }
          } else if (actualRow == oldBlankPosition[0]) {
            // SAME ROW
            if (actualCol < oldBlankPosition[1]) {
              // SLIDE TO RIGHT
              if (_row == actualRow && _column <= oldBlankPosition[1] && _column >= actualCol) {
                _margins[i][j].value[0] += _movement;
                _margins[i][j].notifyListeners();
              }
            } else {
              // SLIDE TO LEFT
              if (_row == actualRow && _column >= oldBlankPosition[1] && _column <= actualCol) {
                _margins[i][j].value[0] -= _movement;
                _margins[i][j].notifyListeners();
              }
            }
          }
          _column = (_margins[i][j].value[0] == 0)
              ? 0
              : (_margins[i][j].value[0] == _movement)
                  ? 1
                  : (_margins[i][j].value[0] == (_movement * 2))
                      ? 2
                      : (_margins[i][j].value[0] == (_movement * 3))
                          ? 3
                          : -1;
          _row = (_margins[i][j].value[1] == 0)
              ? 0
              : (_margins[i][j].value[1] == _movement)
                  ? 1
                  : (_margins[i][j].value[1] == (_movement * 2))
                      ? 2
                      : (_margins[i][j].value[1] == (_movement * 3))
                          ? 3
                          : -1;
          if (((_column + 1) + (_row * 4)) == _items[i][j]) {
            _margins[i][j].value[2] = 1;
            _margins[i][j].notifyListeners();
            cnt++;
          } else {
            _margins[i][j].value[2] = 0;
            _margins[i][j].notifyListeners();
          }
        }
      }
      _inPosition.value = cnt;
      if (cnt == 15) {
        //GAME FINISHED
        await _player.setAsset('assets/Choir Harp Bless.wav');
        _timer.cancel();
        Timer(const Duration(seconds: 1), () async {
          _player.play();
          HapticFeedback.heavyImpact();
          for (int i = 0; i < 4; i++) {
            for (int j = 0; j < _margins[i].length; j++) {
              _margins[i][j].value[0] = (_margins[i][j].value[0] * 1.2).toInt();
              _margins[i][j].value[1] = (_margins[i][j].value[1] * 1.2).toInt();
              _margins[i][j].notifyListeners();
            }
          }
          Timer(const Duration(milliseconds: 800), () async {
            for (int k = 1; k < 16; k++) {
              int cnt = 0;
              for (int i = 0; i < 4; i++) {
                for (int j = 0; j < _margins[i].length; j++) {
                  if (_items[i][j] == k) {
                    cnt++;
                    await Future.delayed(const Duration(milliseconds: 30), () {
                      _hoverSize[i][j].value = 1.25;
                      Timer(const Duration(milliseconds: 550), () {
                        _hoverSize[i][j].value = 1.0;
                      });
                    });
                    break;
                  }
                }
                if (cnt != 0) {
                  break;
                }
              }
              if ((k % 4) == 0) {
                await Future.delayed(const Duration(milliseconds: 160), () {});
              }
            }
            Timer(const Duration(milliseconds: 800), () {
              for (int i = 0; i < 4; i++) {
                for (int j = 0; j < _margins[i].length; j++) {
                  _margins[i][j].value[0] = _margins[i][j].value[0] ~/ 1.2;
                  _margins[i][j].value[1] = _margins[i][j].value[1] ~/ 1.2;
                  _margins[i][j].notifyListeners();
                }
              }
              Timer(const Duration(milliseconds: 800), () {
                //widget._displayAd();
                double radius = (_size / 40);
                /*setState(() {
                  _size = 0;
                  _movement = 0;
                });*/
                showGeneralDialog(
                  pageBuilder: (BuildContext context, Animation<double> anim1, Animation<double> anim2) {
                    return WillPopScope(
                      onWillPop: () async {
                        Navigator.of(context).popUntil((Route route) => route.isFirst);
                        return true;
                      },
                      child: AlertDialog(
                        backgroundColor: Colors.grey.shade900,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(radius)),
                        ),
                        title: (_moveCnt.value < _bestScore)
                            ? const Text(
                                'Congratulations! New best score!',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 20.0),
                              )
                            : const Text(
                                'Congratulations!',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 20.0),
                              ),
                        content: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Text>[
                              (_moveCnt.value < _bestScore)
                                  ? const Text(
                                      'You solved the puzzle with a new record!\n',
                                      style: TextStyle(fontSize: 20.0),
                                    )
                                  : const Text(
                                      'You solved the puzzle!\n',
                                      style: TextStyle(fontSize: 20.0),
                                    ),
                              Text(
                                'Score: ${_moveCnt.value} moves.\n',
                                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w600, color: Colors.grey.shade800),
                              ),
                              (_bestScore == -1)
                                  ? const Text(
                                      'No best score.\n',
                                      style: TextStyle(fontSize: 20.0),
                                    )
                                  : Text(
                                      'Best score: $_bestScore moves.\n',
                                      style: const TextStyle(fontSize: 20.0),
                                    ),
                            ],
                          ),
                        ),
                        actions: <Widget>[
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <TextButton>[
                                TextButton(
                                    onPressed: () => Navigator.of(context).popUntil((Route route) => route.isFirst),
                                    style: TextButton.styleFrom(
                                      primary: Colors.white,
                                      backgroundColor: Colors.black38,
                                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(512.0))),
                                    ),
                                    child: const Text(
                                      'QUIT',
                                      style: TextStyle(fontFamily: 'Manrope'),
                                    )),
                                TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      Timer(const Duration(milliseconds: 500), () {
                                        Navigator.of(context)
                                            .pushReplacement(MyRoute(builder: (BuildContext context) => const ExperimentMode2(/*widget._displayAd*/)));
                                      });
                                    },
                                    style: TextButton.styleFrom(
                                      primary: Colors.white,
                                      backgroundColor: Colors.black38,
                                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(512.0))),
                                    ),
                                    child: const Text(
                                      'PLAY AGAIN',
                                      style: TextStyle(fontFamily: 'Manrope'),
                                    )),
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  },
                  context: context,
                  useRootNavigator: true,
                  transitionBuilder: (BuildContext context, Animation<double> anim1, Animation<double> anim2, Widget child) {
                    return FadeTransition(
                      opacity: CurvedAnimation(parent: anim1, curve: Curves.easeInOut).drive(Tween<double>(begin: 0.15, end: 1.0)),
                      child: ScaleTransition(
                        scale: CurvedAnimation(parent: anim1, curve: Curves.easeInOutCubicEmphasized).drive(Tween<double>(begin: 0.0, end: 1.0)),
                        alignment: Alignment.bottomCenter,
                        child: child,
                      ),
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 600),
                );
                if (_moveCnt.value < _bestScore || _bestScore == -1) {
                  _sp.setInt('_bestScore', _moveCnt.value);
                }
              });
            });
          });
        });
      } else {
        await _player.setAsset('assets/Tile Move.wav');
        _player.play();
      }
      _moveCnt.value++;
    } else {
      await _player.setAsset('assets/Not Movable.wav');
      _player.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_opacity == 0.0) {
      _size = (sqrt(MediaQuery.of(context).size.width) * sqrt(MediaQuery.of(context).size.height)).floor();
      if (MediaQuery.of(context).size.aspectRatio <= 1) {
        _size = (_size * sqrt(sqrt(sqrt(MediaQuery.of(context).size.aspectRatio)))).floor();
      } else {
        _size = ((_size / sqrt(MediaQuery.of(context).size.aspectRatio)) / 1.25).floor();
      }
      _movement = _size ~/ 5.5;
      _radius = _size / 40;
      _squareDimension = _movement - (_size / 40);
      _squareRadius = _size / 40;
      _textShadow = _size / 384;
      _textFontSize = _size / 12;
      setState(() {});
    }
    return WillPopScope(
      onWillPop: () async {
        _timer.cancel();
        showGeneralDialog(
          barrierDismissible: true,
          barrierLabel: '',
          pageBuilder: (BuildContext context, Animation<double> anim1, Animation<double> anim2) {
            return WillPopScope(
              onWillPop: () async {
                _resumeChronometer();
                return true;
              },
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(_radius)),
                  side: BorderSide(color: Colors.grey.shade900),
                ),
                content: const SingleChildScrollView(
                  child: Text('Do you want to quit?', textAlign: TextAlign.center, style: TextStyle(fontSize: 20.0)),
                ),
                actions: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <TextButton>[
                      TextButton(
                          onPressed: () => Navigator.of(context).popUntil((Route route) => route.isFirst),
                          style: TextButton.styleFrom(
                            primary: Colors.white,
                            backgroundColor: Colors.grey.shade900,
                            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(512.0))),
                          ),
                          child: const Text(
                            'QUIT',
                            style: TextStyle(fontFamily: 'Manrope'),
                          )),
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _resumeChronometer();
                          },
                          style: TextButton.styleFrom(
                            primary: Colors.white,
                            backgroundColor: Colors.grey.shade900,
                            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(512.0))),
                          ),
                          child: const Text(
                            'CONTINUE',
                            style: TextStyle(fontFamily: 'Manrope'),
                          )),
                    ],
                  )
                ],
              ),
            );
          },
          context: context,
          useRootNavigator: true,
          transitionBuilder: (BuildContext context, Animation<double> anim1, Animation<double> anim2, Widget child) {
            return FadeTransition(
              opacity: CurvedAnimation(parent: anim1, curve: Curves.easeInOut).drive(Tween<double>(begin: 0.15, end: 1.0)),
              child: ScaleTransition(
                scale: CurvedAnimation(parent: anim1, curve: Curves.easeInOutCubicEmphasized).drive(Tween<double>(begin: 0.0, end: 1.0)),
                alignment: Alignment.bottomCenter,
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 600),
        );
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: ValueListenableBuilder<int>(
            valueListenable: _moveCnt,
            builder: (BuildContext context, int value, Widget? child) {
              return Text('MOVES: $value', style: TextStyle(fontSize: _textFontSize / 2));
            },
          ),
          /*iconTheme: IconThemeData(color: _complement),
          systemOverlayStyle: (_medium == Colors.grey.shade900)
              ? SystemUiOverlayStyle.light.copyWith(
                  statusBarColor: Colors.transparent,
                  systemNavigationBarColor: Colors.transparent,
                )
              : SystemUiOverlayStyle.dark.copyWith(
                  statusBarColor: Colors.transparent,
                  systemNavigationBarColor: Colors.transparent,
                ),*/
          bottom: PreferredSize(
              preferredSize: const Size.fromHeight(16.0),
              child: ValueListenableBuilder<int>(
                  valueListenable: _inPosition,
                  builder: (BuildContext context, int value, Widget? child) {
                    return Text('IN POSITION: $value', style: TextStyle(fontSize: _textFontSize / 2.8, color: Colors.white, fontFamily: 'Manrope'));
                  })),
          centerTitle: true,
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          actions: <TextButton>[
            /*TextButton.icon(
              icon: const Icon(
                CupertinoIcons.lab_flask_solid,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pushReplacement(MyRoute(builder: (BuildContext context) => ExperimentMode(widget._displayAd)));
              },
              label: const Text(
                'CHANGE\nMODE',
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),*/
            TextButton.icon(
              icon: const Icon(
                Icons.image_outlined,
                color: Colors.white,
              ),
              onPressed: () {
                if (_picture < 4) {
                  setState(() {
                    _picture++;
                  });
                } else {
                  setState(() {
                    _picture = 1;
                  });
                }
              },
              label: const Text(
                'CHANGE\nBACKGROUND',
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(_textFontSize / 5),
              decoration: const ShapeDecoration(color: Colors.black38, shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(96.0)))),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.timer_outlined,
                    size: _textFontSize / 2,
                  ),
                  SizedBox(
                    width: _textFontSize * 1.3,
                    height: _textFontSize / 1.5,
                    child: Center(
                      child: StreamBuilder<int>(
                        stream: _chronometer.stream,
                        builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                          return Text(
                            '${((snapshot.data)! ~/ 60).toString().padLeft(2, '0')}:${((snapshot.data)! % 60).toString().padLeft(2, '0')}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: _textFontSize / 2.5,
                              shadows: <Shadow>[
                                Shadow(
                                  color: Colors.black38,
                                  offset: Offset(0.0, (_textShadow / (1.5))),
                                  blurRadius: _textShadow,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: (_textFontSize * 1.2),
              height: (_textFontSize * 1.2),
              child: FloatingActionButton(
                heroTag: null,
                onPressed: () {
                  _timer.cancel();
                  showGeneralDialog(
                    barrierDismissible: true,
                    barrierLabel: '',
                    pageBuilder: (BuildContext context, Animation<double> anim1, Animation<double> anim2) {
                      return WillPopScope(
                        onWillPop: () async {
                          _resumeChronometer();
                          return true;
                        },
                        child: AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(_radius)),
                            side: BorderSide(color: Colors.grey.shade900),
                          ),
                          content: const SingleChildScrollView(
                            child: Text('Do you want to restart?', textAlign: TextAlign.center, style: TextStyle(fontSize: 20.0)),
                          ),
                          actions: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <TextButton>[
                                TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      setState(() {
                                        _isShuffling = true;
                                      });
                                      Timer(const Duration(milliseconds: 600), () => _shuffle());
                                    },
                                    style: TextButton.styleFrom(
                                      primary: Colors.white,
                                      backgroundColor: Colors.grey.shade900,
                                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(512.0))),
                                    ),
                                    child: const Text(
                                      'RESTART',
                                      style: TextStyle(fontFamily: 'Manrope'),
                                    )),
                                TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      _resumeChronometer();
                                    },
                                    style: TextButton.styleFrom(
                                      primary: Colors.white,
                                      backgroundColor: Colors.grey.shade900,
                                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(512.0))),
                                    ),
                                    child: const Text(
                                      'CONTINUE',
                                      style: TextStyle(fontFamily: 'Manrope'),
                                    )),
                              ],
                            )
                          ],
                        ),
                      );
                    },
                    context: context,
                    useRootNavigator: true,
                    transitionBuilder: (BuildContext context, Animation<double> anim1, Animation<double> anim2, Widget child) {
                      return FadeTransition(
                        opacity: CurvedAnimation(parent: anim1, curve: Curves.easeInOut).drive(Tween<double>(begin: 0.15, end: 1.0)),
                        child: ScaleTransition(
                          scale: CurvedAnimation(parent: anim1, curve: Curves.easeInOutCubicEmphasized).drive(Tween<double>(begin: 0.0, end: 1.0)),
                          alignment: Alignment.bottomCenter,
                          child: child,
                        ),
                      );
                    },
                    transitionDuration: const Duration(milliseconds: 600),
                  );
                },
                backgroundColor: Colors.white,
                foregroundColor: Colors.grey.shade900,
                //shape: CircleBorder(side: BorderSide(color: _colors[_colorCnt])),
                tooltip: 'Restart',
                child: const Icon(Icons.refresh_rounded, size: 42.0),
              ),
            ),
            FloatingActionButton.extended(
              heroTag: 'experiment',
              onPressed: () {
                Navigator.of(context).pushReplacement(MyRoute(builder: (BuildContext context) => const ExperimentMode(/*widget._displayAd*/)));
              },
              icon: const Icon(CupertinoIcons.lab_flask_solid),
              label: const Text(
                'CHANGE\nMODE',
                textAlign: TextAlign.center,
                style: TextStyle(letterSpacing: 0.0),
              ),
            ),
          ],
        ),
        body: Stack(
          children: <RepaintBoundary>[
            RepaintBoundary(
              key: const Key('backgroundBlur'),
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0, tileMode: TileMode.decal),
                child: Image.asset(
                  'assets/$_picture/original.jpg',
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.cover,
                  colorBlendMode: BlendMode.darken,
                  color: Colors.black26,
                ),
              ),
            ),
            RepaintBoundary(
              key: const Key('centersquare'),
              child: Center(
                child: Stack(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all((_size / 60)),
                      child: Stack(
                        children: <Widget>[
                          for (int i = 0; i < _items.length; i++)
                            for (int j = 0; j < _items[i].length; j++)
                              RepaintBoundary(
                                key: Key('${_items[i][j]}'),
                                child: GestureDetector(
                                  onTap: () => _tap(i, j),
                                  child: AnimatedOpacity(
                                    opacity: _opacity,
                                    duration: const Duration(seconds: 1),
                                    curve: Curves.easeInOut,
                                    child: ValueListenableBuilder<List<int>>(
                                      valueListenable: _margins[i][j],
                                      builder: (BuildContext context, List<int> value, Widget? child) {
                                        return AnimatedContainer(
                                          duration: const Duration(seconds: 1),
                                          curve: (!_isShuffling && _inPosition.value != 15) ? Curves.fastLinearToSlowEaseIn : Curves.linearToEaseOut,
                                          width: /*(_isShuffling) ? (_squareDimension / 1.5) :*/ _squareDimension,
                                          height: /*(_isShuffling) ? (_squareDimension / 1.5) :*/ _squareDimension,
                                          decoration: ShapeDecoration(
                                            color: Colors.white10,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(Radius.circular(_squareRadius)),
                                              side: BorderSide(color: (value[2] == 1) ? Colors.grey.shade800 : Colors.white24),
                                            ),
                                          ),
                                          margin: EdgeInsets.fromLTRB(value[0].toDouble(), value[1].toDouble(), 0.0, 0.0),
                                          child: child,
                                        );
                                      },
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.all(Radius.circular(_squareRadius)),
                                        child: BackdropFilter(
                                          filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
                                          child: MouseRegion(
                                            onEnter: (PointerEnterEvent event) {
                                              _hoverSize[i][j].value = 1.25;
                                            },
                                            onExit: (PointerExitEvent event) {
                                              _hoverSize[i][j].value = 1.0;
                                            },
                                            child: Center(
                                              child: ValueListenableBuilder<double>(
                                                  valueListenable: _hoverSize[i][j],
                                                  builder: (BuildContext context, double value, Widget? child) {
                                                    return AnimatedScale(
                                                      duration: const Duration(milliseconds: 300),
                                                      curve: (_inPosition.value != 15) ? Curves.linearToEaseOut : Curves.easeInOut,
                                                      scale: value,
                                                      child: Text(
                                                        '${_items[i][j]}',
                                                        style: TextStyle(
                                                          fontSize: _textFontSize,
                                                          color: Colors.white38,
                                                          /*color: Colors.grey.shade800,
                                                          shadows: <Shadow>[
                                                            Shadow(
                                                              color: Colors.black38,
                                                              offset: Offset(_textShadow, _textShadow),
                                                              blurRadius: _textShadow * (1.2),
                                                            ),
                                                          ],*/
                                                        ),
                                                      ),
                                                    );
                                                  }),
                                            ),
                                          ),
                                        ),
                                      ),
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
          ],
        ),
      ),
    );
  }
}

class MyRoute extends MaterialPageRoute {
  MyRoute({dynamic builder}) : super(builder: builder);
  @override
  Duration get transitionDuration => const Duration(seconds: 1);
}
