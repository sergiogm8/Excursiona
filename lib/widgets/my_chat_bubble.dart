import 'package:audioplayers/audioplayers.dart' as player;
import 'package:excursiona/enums/message_type.dart';
import 'package:excursiona/model/message.dart';
import 'package:excursiona/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class MyChatBubble extends StatefulWidget {
  const MyChatBubble(this.message, {super.key});
  final Message message;

  @override
  State<MyChatBubble> createState() => _MyChatBubbleState();
}

class _MyChatBubbleState extends State<MyChatBubble> {
  Message get message => widget.message;
  player.AudioPlayer _audioPlayer = player.AudioPlayer();
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  bool _isPlayingAudio = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer.onPlayerStateChanged.listen((event) {
      if (event == player.PlayerState.completed) {
        setState(() {
          _isPlayingAudio = false;
        });
      }
    });

    _audioPlayer.onDurationChanged.listen((event) {
      setState(() {
        duration = event;
      });
    });

    _audioPlayer.onPositionChanged.listen((event) {
      setState(() {
        position = event;
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
          minWidth: MediaQuery.of(context).size.width * 0.4,
        ),
        child: Card(
          elevation: 5,
          color: Constants.lapisLazuli,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20))),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 10,
                  bottom: 24,
                ),
                child: Column(
                  children: [
                    widget.message.type == MessageType.text
                        ? Text(
                            widget.message.text,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                            ),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              IconButton(
                                  splashRadius: 20,
                                  onPressed: () {
                                    _isPlayingAudio
                                        ? _audioPlayer.pause()
                                        : _audioPlayer.play(
                                            player.UrlSource(message.text));
                                    setState(() {
                                      _isPlayingAudio = !_isPlayingAudio;
                                    });
                                  },
                                  icon: _isPlayingAudio
                                      ? const Icon(Icons.pause,
                                          color: Colors.white, size: 34)
                                      : const Icon(Icons.play_arrow,
                                          color: Colors.white, size: 34),
                                  iconSize: 34,
                                  color: Colors.white),
                              Expanded(
                                child: SliderTheme(
                                  data: const SliderThemeData(
                                    trackHeight: 2,
                                    thumbShape: RoundSliderThumbShape(
                                      enabledThumbRadius: 5,
                                    ),
                                  ),
                                  child: Slider(
                                    min: 0,
                                    max: duration.inSeconds.toDouble(),
                                    onChanged: (value) async {
                                      await _audioPlayer.seek(
                                          Duration(seconds: value.toInt()));
                                    },
                                    value: position.inSeconds.toDouble(),
                                    thumbColor: Colors.white,
                                    inactiveColor: Colors.white,
                                    activeColor: Color(0xFF7EC1FF),
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ],
                ),
              ),
              Positioned(
                bottom: 8,
                right: 10,
                child: Row(
                  children: [
                    Text(
                      DateFormat("HH:mm").format(widget.message.timeSent),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white,
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
