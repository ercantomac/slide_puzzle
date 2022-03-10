import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyRoute extends MaterialPageRoute {
  MyRoute({dynamic builder}) : super(builder: builder);
  @override
  Duration get transitionDuration => const Duration(seconds: 1);
}

class PictureMode extends StatefulWidget {
  final int _picture;
  const PictureMode(this._picture, {Key? key}) : super(key: key);
  @override
  State<PictureMode> createState() => _PictureModeState();
}

class _PictureModeState extends State<PictureMode> with TickerProviderStateMixin {
  final StreamController<int> _chronometer = StreamController<int>();
  late int _bestScore = -1, _size = 960, _movement = 160, _chronometerValue = 0, _centerSquareDimension = 0;
  final ValueNotifier<int> _moveCnt = ValueNotifier<int>(0), _inPosition = ValueNotifier<int>(0);
  late double _opacity = 0.0, _radius = 24.0, _squareDimension = 0.0, _squareRadius = 0.0;
  final List<int> _blankPosition = <int>[3, 3], _inversionControl = <int>[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15];
  final List<List<int>> _items = <List<int>>[
    <int>[0, 0, 0, 0],
    <int>[0, 0, 0, 0],
    <int>[0, 0, 0, 0],
    <int>[0, 0, 0]
  ];
  final List<List<ValueNotifier<List<int>>>> _margins = <List<ValueNotifier<List<int>>>>[
    <ValueNotifier<List<int>>>[
      ValueNotifier<List<int>>(<int>[0, 0]),
      ValueNotifier<List<int>>(<int>[0, 0]),
      ValueNotifier<List<int>>(<int>[0, 0]),
      ValueNotifier<List<int>>(<int>[0, 0])
    ],
    <ValueNotifier<List<int>>>[
      ValueNotifier<List<int>>(<int>[0, 0]),
      ValueNotifier<List<int>>(<int>[0, 0]),
      ValueNotifier<List<int>>(<int>[0, 0]),
      ValueNotifier<List<int>>(<int>[0, 0])
    ],
    <ValueNotifier<List<int>>>[
      ValueNotifier<List<int>>(<int>[0, 0]),
      ValueNotifier<List<int>>(<int>[0, 0]),
      ValueNotifier<List<int>>(<int>[0, 0]),
      ValueNotifier<List<int>>(<int>[0, 0])
    ],
    <ValueNotifier<List<int>>>[
      ValueNotifier<List<int>>(<int>[0, 0]),
      ValueNotifier<List<int>>(<int>[0, 0]),
      ValueNotifier<List<int>>(<int>[0, 0])
    ],
  ];
  late SharedPreferences _sp;
  late AlignmentGeometry _originalImgAlignment = Alignment.topRight;
  late Timer _timer;
  final AudioPlayer _player = AudioPlayer();

  void _fetch() async {
    _sp = await SharedPreferences.getInstance();
    if (_sp.getInt('_pic${(widget._picture)}BestScore') != null) {
      _bestScore = _sp.getInt('_pic${(widget._picture)}BestScore')!;
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
          cnt++;
        }
      }
    }
    _inPosition.value = cnt;
    _chronometer.add(_chronometerValue);
    WidgetsBinding.instance!.addPostFrameCallback((Duration timeStamp) {
      Timer(const Duration(milliseconds: 800), () {
        for (int i = 0; i < 4; i++) {
          for (int j = 0; j < _margins[i].length; j++) {
            _margins[i][j].value[0] = (j * _movement).toInt();
            _margins[i][j].value[1] = (i * _movement).toInt();
            _margins[i][j].notifyListeners();
          }
        }
        setState(() {
          _opacity = 1.0;
        });
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
      _squareDimension /= 1.25;
    });
    _blankPosition[0] = 3;
    _blankPosition[1] = 3;
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < _margins[i].length; j++) {
        _margins[i][j].value[0] = (j * _movement).toInt();
        _margins[i][j].value[1] = (i * _movement).toInt();
        _margins[i][j].notifyListeners();
      }
    }
    int cnt = 0;
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < _margins[i].length; j++) {
        if (((j + 1) + (i * 4)) == _items[i][j]) {
          cnt++;
        }
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
        _squareDimension *= 1.25;
      });
      Timer(const Duration(milliseconds: 1800), () {
        setState(() {
          _centerSquareDimension = 0;
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
          if (actualCol == _blankPosition[1]) {
            // SAME COLUMN
            if (actualRow < _blankPosition[0]) {
              // SLIDE TO BOTTOM
              if (_column == actualCol && _row <= _blankPosition[0] && _row >= actualRow) {
                _margins[i][j].value[1] += _movement;
                _margins[i][j].notifyListeners();
              }
            } else {
              // SLIDE TO TOP
              if (_column == actualCol && _row >= _blankPosition[0] && _row <= actualRow) {
                _margins[i][j].value[1] -= _movement;
                _margins[i][j].notifyListeners();
              }
            }
          } else if (actualRow == _blankPosition[0]) {
            // SAME ROW
            if (actualCol < _blankPosition[1]) {
              // SLIDE TO RIGHT
              if (_row == actualRow && _column <= _blankPosition[1] && _column >= actualCol) {
                _margins[i][j].value[0] += _movement;
                _margins[i][j].notifyListeners();
              }
            } else {
              // SLIDE TO LEFT
              if (_row == actualRow && _column >= _blankPosition[1] && _column <= actualCol) {
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
            cnt++;
          }
        }
      }
      _inPosition.value = cnt;
      if (cnt == 15) {
        //GAME FINISHED
        await _player.setAsset('assets/Choir Harp Bless.wav');
        _timer.cancel();
        Timer(const Duration(milliseconds: 800), () {
          _player.play();
          HapticFeedback.heavyImpact();
          for (int i = 0; i < 4; i++) {
            for (int j = 0; j < _margins[i].length; j++) {
              _margins[i][j].value[0] = (_margins[i][j].value[0] * 1.2).toInt();
              _margins[i][j].value[1] = (_margins[i][j].value[1] * 1.2).toInt();
              _margins[i][j].notifyListeners();
            }
          }
          Timer(const Duration(milliseconds: 800), () {
            for (int i = 0; i < 4; i++) {
              for (int j = 0; j < _margins[i].length; j++) {
                if (_margins[i][j].value[0] ~/ 1.2 >= 0) {
                  _margins[i][j].value[0] = (_margins[i][j].value[0] ~/ 1.2);
                }
                if (_margins[i][j].value[1] ~/ 1.2 >= 0) {
                  _margins[i][j].value[1] = (_margins[i][j].value[1] ~/ 1.2);
                }
                _margins[i][j].notifyListeners();
              }
            }
            setState(() {
              _squareDimension = _movement.toDouble();
              _radius = 0.0;
              _squareRadius = 0.0;
            });
          });
          Timer(const Duration(milliseconds: 1500), () {
            double radius = (_size / 40);
            setState(() {
              _originalImgAlignment = Alignment.center;
            });
            Timer(const Duration(milliseconds: 1200), () {
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
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    Navigator.of(context).pop();
                                  },
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
                                      Navigator.of(context).pushReplacement(MyRoute(builder: (BuildContext context) => PictureMode(widget._picture)));
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
                _sp.setInt('_pic${(widget._picture)}BestScore', _moveCnt.value);
              }
            });
          });
        });
      } else {
        await _player.setAsset('assets/Tile Move.wav');
        _player.play();
      }
      _blankPosition[0] = actualRow;
      _blankPosition[1] = actualCol;
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
        _size = (_size / sqrt(MediaQuery.of(context).size.aspectRatio)).floor();
      }
      _movement = _size ~/ 6;
      _radius = _size / 40;
      _squareDimension = _movement - (_size / 120);
      _squareRadius = _size / 80;
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
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                          },
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
      child: Stack(
        children: <Widget>[
          Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              title: ValueListenableBuilder<int>(
                valueListenable: _moveCnt,
                builder: (BuildContext context, int value, Widget? child) {
                  return Text('MOVES: $value', style: TextStyle(/*fontSize: 32.0*/ fontSize: _size / 24));
                },
              ),
              bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(16.0),
                  child: ValueListenableBuilder<int>(
                      valueListenable: _inPosition,
                      builder: (BuildContext context, int value, Widget? child) {
                        return Text('IN POSITION: $value',
                            style: TextStyle(/*fontSize: 16.0,*/ fontSize: _size / 33.6, color: Colors.white, fontFamily: 'Manrope'));
                      })),
              centerTitle: true,
              elevation: 0.0,
              backgroundColor: Colors.transparent,
            ),
            extendBodyBehindAppBar: true,
            floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
            floatingActionButton: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(_size / 60),
                  decoration:
                      const ShapeDecoration(color: Colors.black38, shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(96.0)))),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.timer_outlined,
                        size: _size / 24,
                      ),
                      SizedBox(
                        width: _size / (9.23),
                        //width: _size / 8,
                        height: _size / 18,
                        child: Center(
                          child: StreamBuilder<int>(
                            stream: _chronometer.stream,
                            builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                              return Text(
                                '${((snapshot.data)! ~/ 60).toString().padLeft(2, '0')}:${((snapshot.data)! % 60).toString().padLeft(2, '0')}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: _size / 30,
                                  shadows: <Shadow>[
                                    Shadow(
                                      color: Colors.black38,
                                      offset: Offset(0.0, (_size / 576)),
                                      blurRadius: _size / 384,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      /*Icon(
                        Icons.timer_outlined,
                        color: Colors.transparent,
                        size: _size / 24,
                      ),*/
                    ],
                  ),
                ),
                SizedBox(
                  width: (_size / 10),
                  height: (_size / 10),
                  child: FloatingActionButton(
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
                                            _centerSquareDimension = (_size * 83) ~/ 120;
                                          });
                                          Timer(const Duration(milliseconds: 600), () {
                                            _shuffle();
                                          });
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
                    tooltip: 'Restart',
                    child: const Icon(Icons.refresh_rounded, size: 42.0),
                  ),
                ),
              ],
            ),
            body: Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                RepaintBoundary(
                  key: const Key('backgroundBlur'),
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 25.2, sigmaY: 25.2, tileMode: TileMode.decal),
                    child: Image.asset(
                      'assets/${widget._picture}/original.jpg',
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                RepaintBoundary(
                  key: const Key('centersquare'),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: _centerSquareDimension.toDouble(),
                        minWidth: _centerSquareDimension.toDouble(),
                      ),
                      child: Container(
                        padding: (_centerSquareDimension == 0) ? EdgeInsets.all((_size / 60)) : EdgeInsets.only(left: (_size / 60), top: (_size / 60)),
                        decoration: ShapeDecoration(
                          color: Colors.black38,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(_size / 40),
                            ),
                          ),
                          /*shadows: <BoxShadow>[
                            /*BoxShadow(
                              //color: Colors.white.withOpacity(0.16),
                              color: Colors.white12,
                              offset: Offset(-_size / 120, -_size / 120),
                              blurRadius: _size / 20,
                              blurStyle: BlurStyle.outer,
                            ),*/
                            BoxShadow(
                              color: Colors.black.withOpacity(0.6),
                              offset: Offset(_size / 45, _size / 45),
                              blurRadius: _size / 26.7,
                              //blurStyle: BlurStyle.outer,
                            ),
                          ],*/
                        ),
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
                                      //duration: const Duration(milliseconds: 800),
                                      duration: const Duration(seconds: 1),
                                      curve: Curves.easeInOut,
                                      child: ValueListenableBuilder<List<int>>(
                                        valueListenable: _margins[i][j],
                                        builder: (BuildContext context, List<int> value, Widget? child) {
                                          return AnimatedContainer(
                                            duration: const Duration(seconds: 1),
                                            curve: (_centerSquareDimension == 0) ? Curves.fastLinearToSlowEaseIn : Curves.linearToEaseOut,
                                            width: _squareDimension,
                                            height: _squareDimension,
                                            margin: EdgeInsets.fromLTRB(value[0].toDouble(), value[1].toDouble(), 0.0, 0.0),
                                            child: child,
                                          );
                                        },
                                        child: Center(
                                          child: ClipRRect(
                                              borderRadius: BorderRadius.all(Radius.circular(_squareRadius)),
                                              child: Image.asset('assets/${widget._picture}/${_items[i][j]}.jpg')),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Material(
            type: MaterialType.transparency,
            child: AnimatedAlign(
              duration: const Duration(seconds: 1),
              curve: (_originalImgAlignment == Alignment.topRight) ? Curves.linearToEaseOut : Curves.fastLinearToSlowEaseIn,
              alignment: _originalImgAlignment,
              child: AnimatedContainer(
                duration: const Duration(seconds: 1),
                curve: (_originalImgAlignment == Alignment.topRight) ? Curves.fastLinearToSlowEaseIn : Curves.linearToEaseOut,
                width: (_movement / 1.33).toDouble(),
                height: (_movement / 1.33).toDouble(),
                margin: (_originalImgAlignment == Alignment.topRight) ? EdgeInsets.fromLTRB(0.0, (_size / 15), (_size / 40), 0.0) : EdgeInsets.zero,
                transformAlignment: Alignment.center,
                transform: Matrix4.identity()..scale((_originalImgAlignment == Alignment.topRight) ? 1.0 : /*4.0*/ 5.33),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(_radius / 2)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: (_opacity == 1.0) ? Colors.black54 : Colors.transparent,
                      offset: Offset(_size / 90, _size / 90),
                      blurRadius: _size / 40,
                    ),
                  ],
                ),
                child: InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  borderRadius: BorderRadius.all(Radius.circular(_radius / 2)),
                  onTap: () {
                    setState(() {
                      _originalImgAlignment = (_originalImgAlignment == Alignment.topRight) ? Alignment.center : Alignment.topRight;
                    });
                  },
                  child: Hero(
                    tag: '${widget._picture}',
                    createRectTween: (Rect? begin, Rect? end) {
                      return MaterialRectCenterArcTween(begin: begin, end: end);
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(_radius / 2)),
                      child: Image.asset(
                        'assets/${widget._picture}/original.jpg',
                        width: _movement.toDouble(),
                        height: _movement.toDouble(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
