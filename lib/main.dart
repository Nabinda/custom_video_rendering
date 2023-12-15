import 'dart:async';

import 'package:custom_video_player/video_progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(useMaterial3: true),
      home: const MyHomePage(title: 'Video Player Customization'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late VideoPlayerController _controller;
  bool isFullScreen = false;

  double volume = 0.75;
  bool hideControllers = false;
  Timer? timer;
  bool isBuffering = false;
  activateTimer() {
    if (timer?.isActive ?? false) {
      timer?.cancel();
    }
    timer = Timer.periodic(const Duration(milliseconds: 3500), (t) {
      setState(() {
        hideControllers = true;
      });
    });
  }

  showControlls() {
    if (hideControllers) {
      setState(() {
        hideControllers = false;
      });
    }
    activateTimer();
  }

  videoControllListener() {
    if (_controller.value.isBuffering) {
      setState(() {
        isBuffering = true;
      });
    } else {
      setState(() {
        isBuffering = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp],
    );

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values); // to re-show bars
    _controller = VideoPlayerController.networkUrl(Uri.parse(
        'https://rr4---sn-fapo3ox25a-3uhk.googlevideo.com/videoplayback?expire=1702636086&ei=1tV7ZdGGDcGw9fwPs5KI8AM&ip=27.34.65.54&id=o-AFO1oxzRmpOvl3pF3CZFWrQzNIa6fTLNLDculwUDhWO-&itag=22&source=youtube&requiressl=yes&xpc=EgVo2aDSNQ%3D%3D&mh=W_&mm=31%2C26&mn=sn-fapo3ox25a-3uhk%2Csn-cvh7knsz&ms=au%2Conr&mv=m&mvi=4&pl=24&initcwndbps=1000000&vprv=1&mime=video%2Fmp4&cnr=14&ratebypass=yes&dur=5087.817&lmt=1695309724114501&mt=1702614101&fvip=4&fexp=24007246&c=ANDROID_TESTSUITE&txp=7208224&sparams=expire%2Cei%2Cip%2Cid%2Citag%2Csource%2Crequiressl%2Cxpc%2Cvprv%2Cmime%2Ccnr%2Cratebypass%2Cdur%2Clmt&sig=AJfQdSswRQIhALwulhhNshndZhCWCYvcJraXQ6ZEaip9UL5SdR_O1gjIAiBxb8I-jhJ6i1SmvTfkdLCuWr5NMeuaNIAgRO889XCRSQ%3D%3D&lsparams=mh%2Cmm%2Cmn%2Cms%2Cmv%2Cmvi%2Cpl%2Cinitcwndbps&lsig=AAO5W4owRQIhAIEE8FgTJc8VGV5wB4Bm-T3WA9a4G_ZzdKtOhZTLBqKdAiBry8AXSETjmY4N2CP3skTlPEJndSkjDDA6Fx2H_Sf-Ew%3D%3D'))
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
        _controller.setVolume(volume);
        activateTimer();
      });

    _controller.addListener(() {
      videoControllListener();
    });
  }

  void exitFullScreenVideo() {
    SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp],
    );

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values); // to re-show bars

    setState(() {
      isFullScreen = false;
    });
  }

  void pushFullScreenVideo() {
    SystemChrome.setPreferredOrientations(
      [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight],
    );
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom]);
    setState(() {
      isFullScreen = true;
    });
  }

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp],
    );

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values); // to re-show bars
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: isFullScreen
          ? null
          : AppBar(
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              centerTitle: true,
              title: Text(widget.title),
            ),
      body: _controller.value.isInitialized
          ? GestureDetector(
              onTap: () {
                if (!hideControllers) {
                  setState(() {
                    hideControllers = true;
                  });
                } else {
                  showControlls();
                }
              },
              child: Container(
                color: Colors.black,
                alignment: Alignment.topCenter,
                height: MediaQuery.sizeOf(context).width *
                    (1 / _controller.value.aspectRatio),
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          child: VideoPlayer(_controller)),
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 800),
                        opacity: hideControllers ? 0 : 1,
                        child: Container(color: Colors.black.withOpacity(0.35)),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onDoubleTap: () {
                              _controller.seekTo(Duration(
                                  microseconds: _controller
                                          .value.position.inMicroseconds -
                                      10000000));
                              showControlls();
                            },
                            child: AbsorbPointer(
                              child: Container(
                                width: MediaQuery.sizeOf(context).width * 0.25,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onDoubleTap: () {
                              _controller.seekTo(Duration(
                                  microseconds: _controller
                                          .value.position.inMicroseconds +
                                      10000000));
                              showControlls();
                            },
                            child: AbsorbPointer(
                              child: Container(
                                width: MediaQuery.sizeOf(context).width * 0.25,
                              ),
                            ),
                          )
                        ],
                      ),
                      CustomVideoProgressIndicator(
                        controller: _controller,
                        isFullScreen: isFullScreen,
                        hideControllers: hideControllers,
                        toggleFullScreen: () {
                          isFullScreen
                              ? exitFullScreenVideo()
                              : pushFullScreenVideo();
                        },
                      ),
                      Center(
                        child: Visibility(
                          visible: isBuffering,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 800),
                        opacity: hideControllers ? 0 : 1,
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Visibility(
                                visible: isFullScreen,
                                child: Expanded(
                                    flex: 1,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 24),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            height: MediaQuery.sizeOf(context)
                                                    .width *
                                                (1 /
                                                    _controller
                                                        .value.aspectRatio) *
                                                0.32,
                                            width: 5,
                                            color: Colors.red,
                                          ),
                                          const SizedBox(height: 6),
                                          Image.asset(
                                            'assets/speaker.png',
                                            height: 16,
                                            width: 16,
                                          )
                                        ],
                                      ),
                                    )),
                              ),
                              Expanded(
                                flex: 3,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        if (!hideControllers) {
                                          _controller.seekTo(Duration(
                                              microseconds: _controller.value
                                                      .position.inMicroseconds -
                                                  10000000));
                                        } else {
                                          showControlls();
                                        }
                                      },
                                      child: AbsorbPointer(
                                        child: Image.asset(
                                          'assets/reverse.png',
                                          height: isFullScreen ? 64 : 32,
                                          width: isFullScreen ? 64 : 32,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        if (!hideControllers) {
                                          _controller.value.isPlaying
                                              ? _controller.pause()
                                              : _controller.play();
                                        } else {
                                          showControlls();
                                        }
                                      },
                                      child: AbsorbPointer(
                                        child: isBuffering
                                            ? SizedBox(
                                                height: isFullScreen ? 64 : 32,
                                                width: isFullScreen ? 64 : 32,
                                              )
                                            : Image.asset(
                                                _controller.value.isPlaying
                                                    ? 'assets/pause.png'
                                                    : 'assets/play.png',
                                                height: isFullScreen ? 64 : 32,
                                                width: isFullScreen ? 64 : 32,
                                              ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        if (!hideControllers) {
                                          _controller.seekTo(Duration(
                                              microseconds: _controller.value
                                                      .position.inMicroseconds +
                                                  10000000));
                                        } else {
                                          showControlls();
                                        }
                                      },
                                      child: AbsorbPointer(
                                        child: Image.asset(
                                          'assets/forward.png',
                                          height: isFullScreen ? 64 : 32,
                                          width: isFullScreen ? 64 : 32,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Visibility(
                                visible: isFullScreen,
                                child: const Expanded(
                                    flex: 1, child: SizedBox.shrink()),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : Container(),
    );
  }
}
