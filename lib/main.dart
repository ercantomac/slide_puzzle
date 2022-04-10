import 'dart:html';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:slide_puzzle_by_ercan/picselector.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slide_puzzle_by_ercan/numbermode.dart';
import 'package:slide_puzzle_by_ercan/experimentmode.dart';

//import 'package:google_mobile_ads/google_mobile_ads.dart';
//import 'package:slide_puzzle_by_ercan/ad_helper.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Paint.enableDithering = true;
  SystemChrome.setPreferredOrientations(<DeviceOrientation>[DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  //MobileAds.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ValueNotifier<EdgeInsetsGeometry> _margin1 = ValueNotifier<EdgeInsetsGeometry>(const EdgeInsets.fromLTRB(16.0, 16.0, 8.0, 16.0));
  final ValueNotifier<EdgeInsetsGeometry> _margin2 = ValueNotifier<EdgeInsetsGeometry>(const EdgeInsets.fromLTRB(8.0, 16.0, 16.0, 16.0));
  late int _bestScore = -1;

  /*late InterstitialAd? _interstitialAd;
  late bool _isInterstitialAdReady = false;
  late int _numInterstitialLoadAttempts = 0;*/

  /*void _loadInterstitialAd(bool shouldShow) {
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _numInterstitialLoadAttempts = 0;
          _interstitialAd = ad;
          ad.fullScreenContentCallback = FullScreenContentCallback<InterstitialAd>(
            onAdShowedFullScreenContent: (InterstitialAd ad) => print('$ad onAdShowedFullScreenContent.'),
            onAdDismissedFullScreenContent: (InterstitialAd ad) {
              print('$ad onAdDismissedFullScreenContent.');
              ad.dispose();
              //_isInterstitialAdReady = false; //??
              //_interstitialAd = null; // ??
              _loadInterstitialAd(false); // ??
            },
            onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
              print('$ad onAdFailedToShowFullScreenContent: $error');
              ad.dispose();
              //_isInterstitialAdReady = false; //??
              //_interstitialAd = null; // ??
              _loadInterstitialAd(false); // ??
            },
            onAdImpression: (InterstitialAd ad) => print('$ad impression occurred.'),
          );
          _isInterstitialAdReady = true;
          //_interstitialAd?.setImmersiveMode(true); // ??
          if (shouldShow) {
            _interstitialAd?.show();
            _isInterstitialAdReady = false; // ??
            _interstitialAd = null; // ??
          }
        },
        onAdFailedToLoad: (LoadAdError err) {
          print('Failed to load an interstitial ad: ${err.message}');
          _isInterstitialAdReady = false;
          _interstitialAd = null; // ??
          _numInterstitialLoadAttempts++; // ??
          if (_numInterstitialLoadAttempts < 4) {
            _loadInterstitialAd(true); // ??
          }
        },
      ),
    );
  }

  void _displayAd() {
    if (!_isInterstitialAdReady) {
      print('ad not ready');
      _loadInterstitialAd(true);
    } else {
      print('ad ready');
      _interstitialAd?.show();
      _isInterstitialAdReady = false; // ??
      _interstitialAd = null; // ??
    }
  }*/
  void _displayAd() {}

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((SharedPreferences _sp) {
      if (_sp.getInt('_bestScore') != null) {
        _bestScore = _sp.getInt('_bestScore')!;
      }
      setState(() {});
    });
    /*if (!kIsWeb) {
      _loadInterstitialAd(false);
    }*/
  }

  /*@override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
  }*/

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Slide Puzzle by Ercan',
      color: Colors.grey.shade900,
      //scrollBehavior: const ScrollBehavior(androidOverscrollIndicator: AndroidOverscrollIndicator.stretch),
      darkTheme: ThemeData(
        fontFamily: 'Manrope',
        brightness: Brightness.dark,
        textTheme: const TextTheme().apply(fontFamily: 'Manrope'),
        pageTransitionsTheme: const PageTransitionsTheme(builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.windows: ZoomPageTransitionsBuilder(),
          TargetPlatform.fuchsia: ZoomPageTransitionsBuilder(),
          TargetPlatform.linux: ZoomPageTransitionsBuilder(),
          TargetPlatform.macOS: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
        }),
      ),
      themeMode: ThemeMode.dark,
      home: Builder(builder: (BuildContext context) {
        return Scaffold(
          backgroundColor: Colors.grey.shade900,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            title: const Text('SLIDE PUZZLE'),
            centerTitle: true,
            systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: Colors.transparent,
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            heroTag: 'experiment',
            onPressed: () {
              Navigator.of(context).push(MyRoute(builder: (BuildContext context) => ExperimentMode(_displayAd))).then((value) {
                SharedPreferences.getInstance().then((SharedPreferences _sp) {
                  if (_sp.getInt('_bestScore') != null) {
                    _bestScore = _sp.getInt('_bestScore')!;
                  }
                  setState(() {});
                });
              });
              document.documentElement?.requestFullscreen();
            },
            icon: const Icon(CupertinoIcons.lab_flask_solid),
            label: const Text(
              'EXPERIMENTAL MODE\n(You may experience low performance)',
              textAlign: TextAlign.center,
            ),
            extendedTextStyle: const TextStyle(letterSpacing: 0.0),
          ),
          body: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Expanded>[
              Expanded(
                child: ValueListenableBuilder<EdgeInsetsGeometry>(
                  valueListenable: _margin1,
                  builder: (BuildContext context, EdgeInsetsGeometry value, Widget? child) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOutCubic,
                      margin: value,
                      decoration: ShapeDecoration(
                        color: (value == const EdgeInsets.fromLTRB(48.0, 48.0, 24.0, 48.0)) ? Colors.black.withOpacity(0.05) : Colors.white.withOpacity(0.05),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular((value == const EdgeInsets.fromLTRB(48.0, 48.0, 24.0, 48.0)) ? 12.0 : 24.0)),
                          side: BorderSide(color: (value == const EdgeInsets.fromLTRB(48.0, 48.0, 24.0, 48.0)) ? Colors.white12 : Colors.transparent),
                          //side: BorderSide(color: (value == const EdgeInsets.fromLTRB(48.0, 48.0, 24.0, 48.0)) ? Colors.transparent : Colors.white30),
                        ),
                      ),
                      child: InkWell(
                        borderRadius: const BorderRadius.all(Radius.circular(24.0)),
                        onTap: () {
                          Navigator.of(context).push(MyRoute(builder: (BuildContext context) => NumberMode(_displayAd))).then((value) {
                            SharedPreferences.getInstance().then((SharedPreferences _sp) {
                              if (_sp.getInt('_bestScore') != null) {
                                _bestScore = _sp.getInt('_bestScore')!;
                              }
                              setState(() {});
                            });
                          });
                          document.documentElement?.requestFullscreen();
                        },
                        onHover: (bool a) {
                          if (a) {
                            _margin2.value = const EdgeInsets.fromLTRB(24.0, 48.0, 48.0, 48.0);
                            _margin1.value = const EdgeInsets.fromLTRB(8.0, 8.0, 4.0, 8.0);
                          } else {
                            _margin2.value = const EdgeInsets.fromLTRB(8.0, 16.0, 16.0, 16.0);
                            _margin1.value = const EdgeInsets.fromLTRB(16.0, 16.0, 8.0, 16.0);
                          }
                        },
                        child: Stack(
                          alignment: Alignment.center,
                          children: <Widget>[
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <AnimatedDefaultTextStyle>[
                                AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOutCubic,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Manrope',
                                    color: Colors.white,
                                    fontSize: (sqrt(MediaQuery.of(context).size.width) * sqrt(MediaQuery.of(context).size.height)) / 16,
                                    letterSpacing: (value == const EdgeInsets.fromLTRB(8.0, 8.0, 4.0, 8.0))
                                        ? 4.0
                                        : (value == const EdgeInsets.fromLTRB(48.0, 48.0, 24.0, 48.0))
                                            ? -3.0
                                            : 0.0,
                                    shadows: const <Shadow>[
                                      Shadow(
                                        color: Colors.black45,
                                        offset: Offset(2.0, 2.0),
                                        blurRadius: 2.0,
                                      ),
                                    ],
                                  ),
                                  child: const Text(
                                    'Play\nNumber\nMode',
                                  ),
                                ),
                              ],
                            ),
                            Positioned(
                              bottom: 12.0,
                              child: Align(alignment: Alignment.bottomCenter, child: Text('Best score: ${(_bestScore == -1) ? ('-') : _bestScore}')),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                child: ValueListenableBuilder<EdgeInsetsGeometry>(
                  valueListenable: _margin2,
                  builder: (BuildContext context, EdgeInsetsGeometry value, Widget? child) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOutCubic,
                      margin: value,
                      decoration: ShapeDecoration(
                        color: (value == const EdgeInsets.fromLTRB(24.0, 48.0, 48.0, 48.0)) ? Colors.black.withOpacity(0.05) : Colors.white.withOpacity(0.05),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular((value == const EdgeInsets.fromLTRB(24.0, 48.0, 48.0, 48.0)) ? 12.0 : 24.0)),
                          side: BorderSide(color: (value == const EdgeInsets.fromLTRB(24.0, 48.0, 48.0, 48.0)) ? Colors.white12 : Colors.transparent),
                          //side: BorderSide(color: (value == const EdgeInsets.fromLTRB(24.0, 48.0, 48.0, 48.0)) ? Colors.transparent : Colors.white30),
                        ),
                      ),
                      child: InkWell(
                        borderRadius: const BorderRadius.all(Radius.circular(24.0)),
                        onTap: () => Navigator.of(context).push(MyRoute(builder: (BuildContext context) => PicSelector(_displayAd))),
                        onHover: (bool a) {
                          if (a) {
                            _margin1.value = const EdgeInsets.fromLTRB(48.0, 48.0, 24.0, 48.0);
                            _margin2.value = const EdgeInsets.fromLTRB(4.0, 8.0, 8.0, 8.0);
                          } else {
                            _margin1.value = const EdgeInsets.fromLTRB(16.0, 16.0, 8.0, 16.0);
                            _margin2.value = const EdgeInsets.fromLTRB(8.0, 16.0, 16.0, 16.0);
                          }
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <AnimatedDefaultTextStyle>[
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOutCubic,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                color: Colors.white,
                                fontSize: (sqrt(MediaQuery.of(context).size.width) * sqrt(MediaQuery.of(context).size.height)) / 16,
                                letterSpacing: (value == const EdgeInsets.fromLTRB(4.0, 8.0, 8.0, 8.0))
                                    ? 4.0
                                    : (value == const EdgeInsets.fromLTRB(24.0, 48.0, 48.0, 48.0))
                                        ? -3.0
                                        : 0.0,
                                shadows: const <Shadow>[
                                  Shadow(
                                    color: Colors.black45,
                                    offset: Offset(2.0, 2.0),
                                    blurRadius: 2.0,
                                  ),
                                ],
                              ),
                              child: const Text(
                                'Play\nPicture\nMode',
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class MyRoute extends MaterialPageRoute {
  MyRoute({dynamic builder}) : super(builder: builder);

  @override
  Duration get transitionDuration => const Duration(seconds: 1);
}
