import 'package:excursiona/shared/constants.dart';
import 'package:excursiona/shared/utils.dart';
import 'package:excursiona/widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class BottomChatComponent extends StatefulWidget {
  final Function sendTextMessage;
  final Function sendAudioMessage;
  const BottomChatComponent(
      {super.key,
      required this.sendTextMessage,
      required this.sendAudioMessage});

  @override
  State<BottomChatComponent> createState() => _BottomChatComponentState();
}

class _BottomChatComponentState extends State<BottomChatComponent> {
  final TextEditingController _messageController = TextEditingController();
  final _audioRecorder = FlutterSoundRecorder();
  bool _isRecordingAudio = false;
  bool _uploadingAudio = false;

  @override
  void initState() {
    super.initState();
    _initAudioRecorder();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _audioRecorder.closeRecorder();
    super.dispose();
  }

  _initAudioRecorder() async {
    final status = await Permission.microphone.request();

    if (status != PermissionStatus.granted) {
      showSnackBar(context, Constants.indigoDye,
          "No se han otorgado permisos para grabar audio");
    }

    await _audioRecorder.openRecorder();
  }

  _recordAudio() async {
    var tempDir = await getTemporaryDirectory();
    var path = '${tempDir.path}/audio.aac';
    await _audioRecorder.startRecorder(toFile: path);
  }

  _sendAudio() async {
    var path = await _audioRecorder.stopRecorder();
    setState(() {
      _uploadingAudio = true;
    });
    var result = await widget.sendAudioMessage(path);
    setState(() {
      _uploadingAudio = false;
      _isRecordingAudio = false;
    });
    if (!result) {
      showSnackBar(context, Colors.red, "Hubo un error al enviar el audio");
    }
  }

  _cancelAudio() async {
    await _audioRecorder.stopRecorder();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      height: 70,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: _isRecordingAudio
                ? _uploadingAudio
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          children: [
                            const SizedBox(
                                height: 25, width: 25, child: Loader()),
                            const SizedBox(width: 10),
                            Text(
                              "Enviando audio...",
                              textAlign: TextAlign.left,
                              style: GoogleFonts.inter(
                                  fontSize: 16, fontWeight: FontWeight.w300),
                            ),
                          ],
                        ),
                      )
                    : Row(
                        children: [
                          const Icon(Icons.mic, color: Constants.redColor),
                          const SizedBox(width: 5),
                          Text(
                            "Grabando audio...",
                            textAlign: TextAlign.left,
                            style: GoogleFonts.inter(
                                fontSize: 16, fontWeight: FontWeight.w300),
                          ),
                        ],
                      )
                : TextFormField(
                    controller: _messageController,
                    onChanged: (value) {
                      setState(() {});
                    },
                    minLines: 1,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: "Escribe algo aquí...",
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 10),
                      enabledBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Constants.darkGrey),
                          borderRadius: BorderRadius.circular(10)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: Constants.steelBlue, width: 2),
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
          ),
          if (_isRecordingAudio)
            IconButton(
                splashRadius: 20.0,
                onPressed: () async {
                  setState(() {
                    _isRecordingAudio = false;
                  });
                  await _cancelAudio();
                },
                icon: const Icon(Icons.close, color: Constants.redColor)),
          const SizedBox(width: 5),
          Container(
            decoration: const BoxDecoration(
                color: Constants.lapisLazuli, shape: BoxShape.circle),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              transitionBuilder: (child, animation) {
                return ScaleTransition(
                  scale: animation,
                  child: child,
                );
              },
              child: _messageController.text.isEmpty
                  ? IconButton(
                      key: const ValueKey("mic"),
                      splashRadius: 20.0,
                      onPressed: () async {
                        if (_audioRecorder.isRecording) {
                          await _sendAudio();
                          setState(() {
                            _isRecordingAudio = false;
                          });
                          return;
                        }
                        setState(() {
                          _isRecordingAudio = true;
                        });
                        await _recordAudio();
                      },
                      icon: Icon(_isRecordingAudio ? Icons.stop : Icons.mic,
                          color: Colors.white),
                    )
                  : IconButton(
                      key: const ValueKey("send"),
                      splashRadius: 20.0,
                      onPressed: () {
                        switch (_isRecordingAudio) {
                          case true:
                            setState(() {
                              _isRecordingAudio = false;
                            });
                            break;
                          case false:
                            if (_messageController.text.trim().isEmpty) return;
                            widget.sendTextMessage(
                                _messageController.text.trim());
                            setState(() {
                              _messageController.clear();
                            });
                            break;
                        }
                      },
                      icon: const Icon(Icons.send),
                      color: Colors.white,
                    ),
            ),
          )
        ],
      ),
    );
  }
}
