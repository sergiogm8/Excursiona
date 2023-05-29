import 'package:audioplayers/audioplayers.dart' as player;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:excursiona/enums/message_type.dart';
import 'package:excursiona/model/message.dart';
import 'package:excursiona/shared/constants.dart';
import 'package:excursiona/shared/utils.dart';
import 'package:excursiona/widgets/account_avatar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class OtherChatBubble extends StatefulWidget {
  const OtherChatBubble(this.message, {super.key});
  final Message message;

  @override
  State<OtherChatBubble> createState() => _OtherChatBubbleState();
}

class _OtherChatBubbleState extends State<OtherChatBubble> {
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
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
          minWidth: MediaQuery.of(context).size.width * 0.4,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            widget.message.senderPic.isNotEmpty
                ? CircleAvatar(
                    backgroundImage:
                        CachedNetworkImageProvider(widget.message.senderPic),
                    radius: 15,
                  )
                : AccountAvatar(radius: 15, name: widget.message.senderName),
            const SizedBox(width: 5),
            Flexible(
              fit: FlexFit.loose,
              child: Container(
                margin: const EdgeInsets.only(top: 10),
                child: Card(
                  elevation: 5,
                  color: Constants.aliceBlue,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
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
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              getNameAbbreviation(widget.message.senderName),
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Constants.indigoDye,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 5),
                            widget.message.type == MessageType.text
                                ? Text(
                                    widget.message.text,
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  )
                                : Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      IconButton(
                                          splashRadius: 20,
                                          onPressed: () {
                                            _isPlayingAudio
                                                ? _audioPlayer.pause()
                                                : _audioPlayer.play(
                                                    player.UrlSource(
                                                        widget.message.text));
                                            setState(() {
                                              _isPlayingAudio =
                                                  !_isPlayingAudio;
                                            });
                                          },
                                          icon: _isPlayingAudio
                                              ? const Icon(Icons.pause,
                                                  color: Constants.lapisLazuli,
                                                  size: 34)
                                              : const Icon(Icons.play_arrow,
                                                  color: Constants.lapisLazuli,
                                                  size: 34),
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
                                              await _audioPlayer.seek(Duration(
                                                  seconds: value.toInt()));
                                            },
                                            value:
                                                position.inSeconds.toDouble(),
                                            thumbColor: Constants.lapisLazuli,
                                            inactiveColor: Colors.white,
                                            activeColor: Constants.lapisLazuli,
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
                              DateFormat("HH:mm")
                                  .format(widget.message.timeSent),
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Constants.lapisLazuli,
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
          ],
        ),
      ),
    );
  }
}
