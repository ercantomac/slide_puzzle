import 'dart:async';
import 'dart:math';
import 'package:flutter/src/gestures/events.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExperimentMode extends StatefulWidget {
  const ExperimentMode({Key? key}) : super(key: key);
  @override
  State<ExperimentMode> createState() => _ExperimentModeState();
}

class _ExperimentModeState extends State<ExperimentMode> with TickerProviderStateMixin {
  late Color _medium = Colors.grey.shade900, _complement = Colors.white;
  final StreamController<int> _chronometer = StreamController<int>();
  late int _colorCnt, _bestScore = -1, _size = 960, _movement = 160, _chronometerValue = 0;
  final ValueNotifier<int> _moveCnt = ValueNotifier<int>(0), _inPosition = ValueNotifier<int>(0);
  final List<Color> _colors = <Color>[
        Colors.redAccent.shade400,
        Colors.blueAccent.shade400,
        Colors.deepOrangeAccent.shade400,
        Colors.lightGreenAccent.shade400,
        Colors.pinkAccent.shade400,
        Colors.purpleAccent.shade400,
        Colors.greenAccent.shade400,
        //Colors.pink.shade400,
        Colors.tealAccent.shade400,
        const Color(0xFFFF9100)
      ],
      _secondaryColors = <Color>[
        HSLColor.fromColor(Colors.redAccent.shade400).withLightness(HSLColor.fromColor(Colors.redAccent.shade400).lightness * (0.85)).toColor(),
        HSLColor.fromColor(Colors.blueAccent.shade400).withLightness(HSLColor.fromColor(Colors.blueAccent.shade400).lightness * (0.85)).toColor(),
        HSLColor.fromColor(Colors.deepOrangeAccent.shade400).withLightness(HSLColor.fromColor(Colors.deepOrangeAccent.shade400).lightness * (0.85)).toColor(),
        HSLColor.fromColor(Colors.lightGreenAccent.shade400).withLightness(HSLColor.fromColor(Colors.lightGreenAccent.shade400).lightness * (0.85)).toColor(),
        HSLColor.fromColor(Colors.pinkAccent.shade400).withLightness(HSLColor.fromColor(Colors.pinkAccent.shade400).lightness * (0.85)).toColor(),
        HSLColor.fromColor(Colors.purpleAccent.shade400).withLightness(HSLColor.fromColor(Colors.purpleAccent.shade400).lightness * (0.85)).toColor(),
        HSLColor.fromColor(Colors.greenAccent.shade400).withLightness(HSLColor.fromColor(Colors.greenAccent.shade400).lightness * (0.85)).toColor(),
        //HSLColor.fromColor(Colors.pink.shade400).withLightness(HSLColor.fromColor(Colors.pink.shade400).lightness * (0.85)).toColor(),
        HSLColor.fromColor(Colors.tealAccent.shade400).withLightness(HSLColor.fromColor(Colors.tealAccent.shade400).lightness * (0.85)).toColor(),
        HSLColor.fromColor(const Color(0xFFFF9100)).withLightness(HSLColor.fromColor(const Color(0xFFFF9100)).lightness * (0.85)).toColor()
      ];
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

  Future<void> _fetch() async {
    _sp = await SharedPreferences.getInstance();
    setState(() {
      _colorCnt = (_sp.getInt('_colorCnt') != null) ? (_sp.getInt('_colorCnt')!) : 0;
    });
    if (_sp.getInt('_bestScore') != null) {
      _bestScore = _sp.getInt('_bestScore')!;
    }
    if (_sp.getString('themeMode') == 'Light') {
      _changeTheme();
    }
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

  void _changeTheme() async {
    if (_opacity == 1.0) {
      await _player.setAsset('assets/Theme Change.wav');
      _player.play();
      HapticFeedback.lightImpact();
      showGeneralDialog(
        barrierDismissible: true,
        barrierLabel: '',
        barrierColor: (_medium == Colors.grey.shade900) ? const Color(0xFFE0E0E0) : Colors.grey.shade900,
        pageBuilder: (BuildContext context, Animation<double> anim1, Animation<double> anim2) {
          return Container();
        },
        context: context,
        useRootNavigator: true,
        transitionDuration: const Duration(milliseconds: 500),
      );
    }
    if (_medium == Colors.grey.shade900) {
      _sp.setString('themeMode', 'Light');
    } else {
      _sp.setString('themeMode', 'Dark');
    }
    if (_opacity == 1.0) {
      Timer(const Duration(milliseconds: 500), () {
        setState(() {
          _medium = (_medium == Colors.grey.shade900) ? const Color(0xFFE0E0E0) : Colors.grey.shade900;
          _complement = (_complement == Colors.white) ? Colors.grey.shade900 : Colors.white;
        });
        Timer(const Duration(milliseconds: 100), () {
          Navigator.of(context).pop();
        });
      });
    } else {
      setState(() {
        _medium = (_medium == Colors.grey.shade900) ? const Color(0xFFE0E0E0) : Colors.grey.shade900;
        _complement = (_complement == Colors.white) ? Colors.grey.shade900 : Colors.white;
      });
    }
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
          _margins[i][j].value[2] = 1;
          _margins[i][j].notifyListeners();
          cnt++;
        } else {
          _margins[i][j].value[2] = 0;
          _margins[i][j].notifyListeners();
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

  void _changeColor() async {
    await _player.setAsset('assets/Color Change.mp3');
    HapticFeedback.lightImpact();
    _player.play();
    setState(() {
      _colorCnt = (_colorCnt < _colors.length - 1) ? (_colorCnt + 1) : 0;
    });
    _sp.setInt('_colorCnt', _colorCnt);
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
                      Timer(const Duration(milliseconds: 550), () async {
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
                        backgroundColor: _colors[_colorCnt],
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
                                        Navigator.of(context).pushReplacement(MyRoute(builder: (BuildContext context) => const ExperimentMode()));
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
    return Stack(
      children: <Widget>[
        RepaintBoundary(
          key: const Key('greygradient'),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: (_medium == Colors.grey.shade900)
                    ? <Color>[
                        HSLColor.fromColor(const Color(0xFF121212)).withLightness(HSLColor.fromColor(const Color(0xFF121212)).lightness * (1.15)).toColor(),
                        const Color(0xFF121212),
                      ]
                    : <Color>[
                        const Color(0xFFE0E0E0),
                        HSLColor.fromColor(const Color(0xFFE0E0E0)).withLightness(HSLColor.fromColor(const Color(0xFFE0E0E0)).lightness * (0.85)).toColor(),
                      ],
              ),
            ),
          ),
        ),
        RepaintBoundary(
          key: const Key('tilestack'),
          child: WillPopScope(
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
                      backgroundColor: _medium,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(_radius)),
                        side: BorderSide(color: _colors[_colorCnt]),
                      ),
                      content: SingleChildScrollView(
                        child: Text('Do you want to quit?', textAlign: TextAlign.center, style: TextStyle(fontSize: 20.0, color: _complement)),
                      ),
                      actions: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <TextButton>[
                            TextButton(
                                onPressed: () => Navigator.of(context).popUntil((Route route) => route.isFirst),
                                style: TextButton.styleFrom(
                                  primary: _complement,
                                  backgroundColor: _colors[_colorCnt],
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
                                  primary: _complement,
                                  backgroundColor: _colors[_colorCnt],
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
              backgroundColor: Colors.transparent,
              extendBodyBehindAppBar: true,
              appBar: AppBar(
                title: ValueListenableBuilder<int>(
                  valueListenable: _moveCnt,
                  builder: (BuildContext context, int value, Widget? child) {
                    return Text('MOVES: $value', style: TextStyle(fontSize: _textFontSize / 2, color: _complement));
                  },
                ),
                iconTheme: IconThemeData(color: _complement),
                systemOverlayStyle: (_medium == Colors.grey.shade900)
                    ? SystemUiOverlayStyle.light.copyWith(
                        statusBarColor: Colors.transparent,
                        systemNavigationBarColor: Colors.transparent,
                      )
                    : SystemUiOverlayStyle.dark.copyWith(
                        statusBarColor: Colors.transparent,
                        systemNavigationBarColor: Colors.transparent,
                      ),
                bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(16.0),
                    child: ValueListenableBuilder<int>(
                        valueListenable: _inPosition,
                        builder: (BuildContext context, int value, Widget? child) {
                          return Text('IN POSITION: $value', style: TextStyle(fontSize: _textFontSize / 2.8, color: _complement, fontFamily: 'Manrope'));
                        })),
                centerTitle: true,
                elevation: 0.0,
                backgroundColor: Colors.transparent,
                actions: <IconButton>[
                  IconButton(
                    icon: Icon(
                      (_medium == Colors.grey.shade900) ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                      color: _complement,
                    ),
                    onPressed: () => _changeTheme(),
                    tooltip: 'Change Theme',
                  ),
                ],
              ),
              floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
              floatingActionButton: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  SizedBox(
                    width: (_textFontSize * 1.2),
                    height: (_textFontSize * 1.2),
                    child: Container(
                      decoration: ShapeDecoration(
                        shape: const CircleBorder(),
                        shadows: <BoxShadow>[
                          BoxShadow(
                            blurRadius: 5.0,
                            color: _colors[_colorCnt].withOpacity(0.64),
                            blurStyle: BlurStyle.outer,
                          )
                        ],
                      ),
                      child: FloatingActionButton(
                        elevation: 0.0,
                        disabledElevation: 0.0,
                        focusElevation: 0.0,
                        highlightElevation: 0.0,
                        hoverElevation: 0.0,
                        heroTag: null,
                        onPressed: () => _changeColor(),
                        //backgroundColor: _medium,
                        backgroundColor: Colors.transparent,
                        foregroundColor: _colors[_colorCnt],
                        shape: CircleBorder(side: BorderSide(color: _colors[_colorCnt])),
                        tooltip: 'Change Color',
                        child: const Icon(Icons.color_lens_outlined, size: 42.0),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(_textFontSize / 5),
                    decoration: ShapeDecoration(
                      //color: _colors[_colorCnt],
                      shape: RoundedRectangleBorder(
                        borderRadius: const BorderRadius.all(Radius.circular(96.0)),
                        side: BorderSide(
                          color: _colors[_colorCnt],
                          width: 0.0,
                        ),
                      ),
                      shadows: <BoxShadow>[
                        BoxShadow(
                          blurRadius: 5.0,
                          color: _colors[_colorCnt].withOpacity(0.64),
                          blurStyle: BlurStyle.outer,
                        )
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.timer_outlined,
                          size: _textFontSize / 2,
                          //color: _complement,
                          color: _colors[_colorCnt],
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
                                    //color: _complement,
                                    color: _colors[_colorCnt],
                                    fontWeight: FontWeight.w600,
                                    /*shadows: <Shadow>[
                                      Shadow(
                                        color: Colors.black38,
                                        offset: Offset(0.0, (_textShadow / (1.5))),
                                        blurRadius: _textShadow,
                                      ),
                                    ],*/
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
                    child: Container(
                      decoration: ShapeDecoration(
                        shape: const CircleBorder(),
                        shadows: <BoxShadow>[
                          BoxShadow(
                            blurRadius: 5.0,
                            color: _colors[_colorCnt].withOpacity(0.64),
                            blurStyle: BlurStyle.outer,
                          )
                        ],
                      ),
                      child: FloatingActionButton(
                        elevation: 0.0,
                        disabledElevation: 0.0,
                        focusElevation: 0.0,
                        highlightElevation: 0.0,
                        hoverElevation: 0.0,
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
                                  backgroundColor: _medium,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(_radius)),
                                    side: BorderSide(color: _colors[_colorCnt]),
                                  ),
                                  content: SingleChildScrollView(
                                    child: Text('Do you want to restart?', textAlign: TextAlign.center, style: TextStyle(fontSize: 20.0, color: _complement)),
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
                                              primary: _complement,
                                              backgroundColor: _colors[_colorCnt],
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
                                              primary: _complement,
                                              backgroundColor: _colors[_colorCnt],
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
                        //backgroundColor: _medium,
                        backgroundColor: Colors.transparent,
                        foregroundColor: _colors[_colorCnt],
                        shape: CircleBorder(side: BorderSide(color: _colors[_colorCnt])),
                        tooltip: 'Restart',
                        child: const Icon(Icons.refresh_rounded, size: 42.0),
                      ),
                    ),
                  ),
                ],
              ),
              body: RepaintBoundary(
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
                                            width: _squareDimension,
                                            height: _squareDimension,
                                            decoration: ShapeDecoration(
                                              color: (value[2] == 1) ? _colors[_colorCnt] : Colors.transparent,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.all(Radius.circular(_squareRadius)),
                                                  side: BorderSide(
                                                    color: _colors[_colorCnt],
                                                    width: 0.0,
                                                  )),
                                              shadows: <BoxShadow>[
                                                BoxShadow(
                                                  blurRadius: 5.0,
                                                  color: _colors[_colorCnt].withOpacity(0.64),
                                                  blurStyle: BlurStyle.outer,
                                                )
                                              ],
                                            ),
                                            margin: EdgeInsets.fromLTRB(value[0].toDouble(), value[1].toDouble(), 0.0, 0.0),
                                            child: MouseRegion(
                                              onEnter: (PointerEnterEvent event) {
                                                _hoverSize[i][j].value = 2.0;
                                              },
                                              onExit: (PointerExitEvent event) {
                                                _hoverSize[i][j].value = 1.0;
                                              },
                                              child: Center(
                                                child: ValueListenableBuilder<double>(
                                                    valueListenable: _hoverSize[i][j],
                                                    builder: (BuildContext context, double value2, Widget? child) {
                                                      return AnimatedScale(
                                                        duration: const Duration(milliseconds: 300),
                                                        curve: (_inPosition.value != 15) ? Curves.linearToEaseOut : Curves.easeInOut,
                                                        scale: 1.0,
                                                        child: Text(
                                                          '${_items[i][j]}',
                                                          style: TextStyle(
                                                            fontSize: _textFontSize,
                                                            color: (value[2] == 1)
                                                                ? ((_medium == Colors.grey.shade900) ? Colors.grey.shade800 : _medium)
                                                                : _colors[_colorCnt],
                                                            shadows: <Shadow>[
                                                              Shadow(
                                                                color: (value[2] == 1) ? Colors.transparent : _colors[_colorCnt].withOpacity(0.5 * value2),
                                                                blurRadius: _textShadow * 6 /*2*/ /** value2*/,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    }),
                                              ),
                                            ),
                                          );
                                        },
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
            ),
          ),
        ),
      ],
    );
  }
}

class MyRoute extends MaterialPageRoute {
  MyRoute({dynamic builder}) : super(builder: builder);
  @override
  Duration get transitionDuration => const Duration(seconds: 1);
}
