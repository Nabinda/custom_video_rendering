import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class LinearProgressPointer extends CustomPainter {
  final double progress;
  final double buffer;
  LinearProgressPointer(
      {required this.color, required this.buffer, required this.progress});

  final VideoProgressColors color;
  @override
  void paint(Canvas canvas, Size size) {
    Paint total = Paint()
      ..style = PaintingStyle.stroke
      ..color = color.backgroundColor
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.height;
    Paint progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = color.playedColor
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.height;
    Paint bufferPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = color.bufferedColor
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.height;
    Paint whitePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.white
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.height;
    Paint whitePaintProgress = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.white
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.height * 1.4;
    canvas.drawLine(
        Offset(0, size.height), Offset(size.width, size.height), total);
    canvas.drawLine(Offset(0, size.height),
        Offset(buffer * size.width, size.height), bufferPaint);

    canvas.drawLine(Offset(0, size.height),
        Offset(progress * size.width, size.height), whitePaintProgress);
    canvas.drawLine(Offset(0, size.height),
        Offset(progress * size.width, size.height), progressPaint);
    canvas.drawCircle(Offset(progress * size.width, size.height),
        size.height * 0.83, whitePaint);
    canvas.drawCircle(Offset(progress * size.width, size.height),
        size.height * 0.65, progressPaint);
  }

  @override
  bool shouldRepaint(oldDelegate) {
    return true;
  }
}

class CustomVideoProgressIndicator extends StatefulWidget {
  final VideoPlayerController controller;
  final Function() toggleFullScreen;
  final bool isFullScreen;
  final bool hideControllers;

  const CustomVideoProgressIndicator(
      {super.key,
      required this.controller,
      required this.hideControllers,
      required this.toggleFullScreen,
      required this.isFullScreen});

  @override
  State<CustomVideoProgressIndicator> createState() =>
      _CustomVideoProgressIndicatorState();
}

class _CustomVideoProgressIndicatorState
    extends State<CustomVideoProgressIndicator> {
  bool _controllerWasPlaying = false;

  Duration videoPosition = Duration.zero;

  VideoPlayerController get controller => widget.controller;

  bool get hideControllers => widget.hideControllers;
  bool get isFullScreen => widget.isFullScreen;

  controllerListener() {
    if (controller.value.isPlaying) {
      setState(() {
        videoPosition = controller.value.position;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      controllerListener();
    });
  }

  @override
  Widget build(BuildContext context) {
    int duration = controller.value.duration.inMilliseconds;
    int position = controller.value.position.inMilliseconds;
    int maxBuffering = 0;
    for (final DurationRange range in controller.value.buffered) {
      final int end = range.end.inMilliseconds;
      if (end > maxBuffering) {
        maxBuffering = end;
      }
    }

    void seekToRelativePosition(Offset globalPosition) {
      final RenderBox box = context.findRenderObject()! as RenderBox;
      final Offset tapPos = box.globalToLocal(globalPosition);
      final double relative = tapPos.dx / box.size.width;
      final Duration position = controller.value.duration * relative;
      controller.seekTo(position);
      setState(() {});
    }

    return AnimatedOpacity(
      opacity: hideControllers ? 0 : 1,
      duration: const Duration(milliseconds: 800),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Visibility(
              visible: true,
              child: Row(
                children: [
                  Image.asset(
                    'assets/live.png',
                    height: 20,
                    fit: BoxFit.fitHeight,
                  ),
                  const SizedBox(width: 12),
                ],
              ),
            ),
            Expanded(
              child: LayoutBuilder(builder: (context, constraints) {
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onHorizontalDragStart: (DragStartDetails details) {
                    if (!hideControllers) {
                      if (!controller.value.isInitialized) {
                        return;
                      }
                      _controllerWasPlaying = controller.value.isPlaying;
                      if (_controllerWasPlaying) {
                        controller.pause();
                      }
                    }
                  },
                  onHorizontalDragUpdate: (DragUpdateDetails details) {
                    if (!hideControllers) {
                      if (!controller.value.isInitialized) {
                        return;
                      }
                      seekToRelativePosition(details.globalPosition);
                    }
                  },
                  onHorizontalDragEnd: (DragEndDetails details) {
                    if (!hideControllers) {
                      if (_controllerWasPlaying &&
                          controller.value.position !=
                              controller.value.duration) {
                        controller.play();
                      }
                    }
                  },
                  onTapDown: (TapDownDetails details) {
                    if (!hideControllers) {
                      if (!widget.controller.value.isInitialized) {
                        return;
                      }
                      seekToRelativePosition(details.globalPosition);
                    }
                  },
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      SizedBox(
                        height: 40,
                        width: constraints.maxWidth,
                      ),
                      Positioned(
                        bottom: 20,
                        child: CustomPaint(
                            painter: LinearProgressPointer(
                                color: const VideoProgressColors(
                                    backgroundColor: Colors.grey,
                                    playedColor: Colors.blue,
                                    bufferedColor: Colors.black),
                                progress: position / duration,
                                buffer: maxBuffering / duration),
                            child: SizedBox(
                              height: 4,
                              width: constraints.maxWidth,
                            )),
                      ),
                      Positioned(
                        top: 0,
                        width: constraints.maxWidth,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _printDuration(videoPosition),
                              style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  height: 17 / 14,
                                  letterSpacing: -0.3),
                            ),
                            Text(
                              _printDuration(controller.value.duration),
                              style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  height: 17 / 14,
                                  letterSpacing: -0.3),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                );
              }),
            ),
            // SizedBox(
            //   width: isFullScreen ? 14 : 1,
            // ),
            // Padding(
            //   padding: EdgeInsets.all(isFullScreen ? 14.0 : 7),
            //   child: Image.asset(
            //     'assets/setting.png',
            //     height: 20,
            //     color: Colors.white,
            //     fit: BoxFit.fitHeight,
            //   ),
            // ),
            GestureDetector(
              onTap: () {
                if (!hideControllers) {
                  widget.toggleFullScreen();
                }
              },
              behavior: HitTestBehavior.translucent,
              child: Padding(
                padding: EdgeInsets.all(isFullScreen ? 8 : 1),
                child: Image.asset(
                  widget.isFullScreen
                      ? 'assets/minimize_screen.png'
                      : 'assets/full_screen.png',
                  height: 32,
                  fit: BoxFit.fitHeight,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _printDuration(Duration duration) {
  String negativeSign = duration.isNegative ? '-' : '';
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60).abs());
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60).abs());
  return '$negativeSign${twoDigits(duration.inHours)}' == '00'
      ? '$twoDigitMinutes:$twoDigitSeconds'
      : "$negativeSign${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
}
