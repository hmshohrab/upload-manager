import 'dart:async';
import 'dart:io';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_sound_platform_interface/flutter_sound_recorder_platform_interface.dart';
import 'package:flutter_utils_project/flutter_utils_project.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../utils/color_resources.dart';
import '../../../../utils/extensions.dart';
import '../../../core/values/app_values.dart';
import '../../../core/values/text_styles.dart';
import '../model/Audio.dart';

typedef _Fn = void Function();

const theSource = AudioSource.microphone;

/// Example app.
class SimpleRecorder extends StatefulWidget {
  String beatId;

  SimpleRecorder(this.beatId);

  @override
  _SimpleRecorderState createState() => _SimpleRecorderState();
}

class _SimpleRecorderState extends State<SimpleRecorder> {
  Codec _codec = Codec.pcm16WAV;
  String _mPath = '';
  FlutterSoundPlayer? _mPlayer = FlutterSoundPlayer();
  FlutterSoundRecorder? _mRecorder = FlutterSoundRecorder();
  bool _mPlayerIsInited = false;
  bool _mRecorderIsInited = false;
  bool _mplaybackReady = false;
  Timer? _timer;
  bool isRecordTimeCompleted = false;
  Directory? tempDir;

  @override
  void initState() {
    getTemp();
    _mPlayer!.openPlayer().then((value) {
      setState(() {
        _mPlayerIsInited = true;
      });
    });

    openTheRecorder().then((value) {
      setState(() {
        _mRecorderIsInited = true;
      });
    });
    super.initState();
  }

  getTemp() async {
    tempDir = await getTemporaryDirectory();
  }

  @override
  void dispose() {
    _mPlayer!.closePlayer();
    _mPlayer = null;

    _mRecorder!.closeRecorder();
    _mRecorder = null;
    super.dispose();
  }

  Future<void> openTheRecorder() async {
    if (!kIsWeb) {
      var status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        throw RecordingPermissionException('Microphone permission not granted');
      }
    }
    await _mRecorder!.openRecorder();
    if (!await _mRecorder!.isEncoderSupported(_codec) && kIsWeb) {
      _codec = Codec.opusWebM;
      _mPath = 'tau_file.webm';
      if (!await _mRecorder!.isEncoderSupported(_codec) && kIsWeb) {
        _mRecorderIsInited = true;
        return;
      }
    }
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
      avAudioSessionCategoryOptions:
          AVAudioSessionCategoryOptions.allowBluetooth |
              AVAudioSessionCategoryOptions.defaultToSpeaker,
      avAudioSessionMode: AVAudioSessionMode.spokenAudio,
      avAudioSessionRouteSharingPolicy:
          AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: const AndroidAudioAttributes(
        contentType: AndroidAudioContentType.speech,
        flags: AndroidAudioFlags.none,
        usage: AndroidAudioUsage.voiceCommunication,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ));

    _mRecorderIsInited = true;
  }

  // ----------------------  Here is the code for recording and playback -------

  void record() {
    fitTimeBoom();
    _mRecorder!
        .startRecorder(
      toFile: getCustomFileName(widget.beatId), //_mPath,
      codec: _codec,
      audioSource: theSource,
    )
        .then((value) {
      setState(() {});
    });
  }

  void stopRecorder() async {
    fitTimeBoom();
    await _mRecorder!.stopRecorder().then((value) {
      setState(() {
        //var url = value;
        _mplaybackReady = true;
      });
    });
  }

  ///data/user/0/com.example.apps_cidms.dev/cache/tau_file.mp4

  void play() {
    assert(_mPlayerIsInited &&
        _mplaybackReady &&
        _mRecorder!.isStopped &&
        _mPlayer!.isStopped);
    _mPlayer!
        .startPlayer(
            fromURI: getCustomFileName(widget.beatId), //_mPath,
            //codec: kIsWeb ? Codec.opusWebM : Codec.aacADTS,
            whenFinished: () {
              setState(() {});
            })
        .then((value) {
      setState(() {});
    });
  }

  void stopPlayer() {
    _mPlayer!.stopPlayer().then((value) {
      setState(() {});
    });
  }

// ----------------------------- UI --------------------------------------------

  _Fn? getRecorderFn() {
    if (!_mRecorderIsInited || !_mPlayer!.isStopped) {
      return null;
    }
    return _mRecorder!.isStopped ? record : stopRecorder;
  }

  _Fn? getPlaybackFn() {
    if (!_mPlayerIsInited || !_mplaybackReady || !_mRecorder!.isStopped) {
      return null;
    }
    return _mPlayer!.isStopped ? play : stopPlayer;
  }

  @override
  Widget build(BuildContext context) {
    Widget makeBody() {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Record Audio",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ).flexible(),
          15.height,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.mic, size: 20),
                label: Text(
                  "Start Record",
                  style: whiteText16,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // Background color
                ),
                onPressed: (_mRecorder!.isRecording) ? null : getRecorderFn(),
              ).withHeight(40).flexible(),
              const SizedBox(width: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // Background color
                ),
                onPressed: (_mRecorder!.isRecording && isRecordTimeCompleted)
                    ? getRecorderFn()
                    : null,
                child: Text(
                  'Stop Record',
                  style: whiteText16,
                ),
              ).withHeight(40).flexible(),
            ],
          ).flexible(),
          10.height,
          Text(_mRecorder!.isRecording
              ? 'Recording in progress...'
              : 'Recorder is stopped'),
          10.height,
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            ElevatedButton(
              onPressed: getPlaybackFn(),
              //color: Colors.white,
              //disabledColor: Colors.grey,
              child: Text(_mPlayer!.isPlaying ? 'Stop' : 'Play',style: whiteText16,),
            ).widthAndHeight(width: 150, height: 40),
            SizedBox(
              width: 20,
            ),
            Text(_mPlayer!.isPlaying
                ? 'Playback in progress...'
                : 'Player is stopped'),
          ]).visible(_mplaybackReady),
          10.height,
          /*  TextFormField(
                  decoration: const InputDecoration(
                    hintText: "Audio.mp3",
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(2),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(2),
                      ),
                    ),
                  ),
                ).paddingAll(Dimensions.paddingSizeSmall),*/
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: () {
                  stopRecorder();
                  stopPlayer();
                  // getRecorderFn();
                  // getPlaybackFn();
                  Get.back();
                },
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.0))),
                ),
                child: const Text(
                  "Back ",
                  style: TextStyle(fontSize: 18),
                ),
              )
                  .paddingRight(AppValues.smallPadding)
                  .expand(),
              OutlinedButton(
                style: OutlinedButton.styleFrom(backgroundColor: ColorResources.kPrimaryColor),
                onPressed: () async {
                  //  final cacheDir = await getTemporaryDirectory();
                  // showSnackBar(Get.context!, cacheDir.path);
                  if (_mplaybackReady) {
                    // await File("data/user/0/com.example.apps_cidms.dev/cache/tau_file.mp4").rename("Pathpro");
                    Get.back(
                        result:
                            Audio(name: _mPath, content: "", format: "wav"));
                  } else {
                    /* ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('This is a SnackBar.'),
                      ),
                    );*/
                    showSnackBar(context, "Please record your voice statement");
                  }
                  // showSnackBar(Get.context!,  await getFilePath());
                },
                child: const Text(
                  "OK ",
                  style: TextStyle(fontSize: 18,color: Colors.white),
                ),
              ).paddingLeft(AppValues.smallPadding).expand(),
            ],
          ).flexible(),
        ],
      ) ;
    }

    return makeBody();
  }

/*  Future<String> getFilePath() async {
    Directory appDocumentsDirectory = await getApplicationDocumentsDirectory(); // 1
    String appDocumentsPath = appDocumentsDirectory.path; // 2
    String filePath = '$appDocumentsPath/$_mPath'; // 3

    return filePath;
  }*/

  String getCustomFileName(String beatId) {
    if (_mPath.isEmpty) {
      _mPath =
          "${tempDir?.path}/${beatId}_${DateTime.now().millisecondsSinceEpoch}${ext[_codec.index]}";
    }
    return _mPath;
  }

  fitTimeBoom() {
    isRecordTimeCompleted = false;
    if (isRecordTimeCompleted) {
      if (_timer != null) {
        _timer!.cancel();
      }
    }
    if (_mRecorder!.isStopped) {
      if (_timer != null) {
        _timer!.cancel();
      }

      _timer = Timer(const Duration(seconds: 2), () {
        setState(() {
          isRecordTimeCompleted = true;
        });
      });
    }
  }
}
