import 'package:flutter/material.dart';
import 'package:stream_video_flutter/stream_video_flutter.dart';

class CallScreen extends StatefulWidget {
  final Call call;
  final String callId;

  const CallScreen({
    Key? key,
    required this.call,
    required this.callId,
  }) : super(key: key);

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  bool isWhiteboardActive = false;
  List<Offset?> points = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
      StreamCallContainer(
        call: widget.call,
        callContentBuilder: (BuildContext context,
            Call call,
            CallState callState,) {
          return StreamCallContent(
            call: call,
            callState: callState,
            callControlsBuilder: (BuildContext context,
                Call call,
                CallState callState,) {
              final localParticipant = callState.localParticipant!;
              return StreamCallControls(
                options: [
                  ToggleScreenShareOption(
                    call: call,
                    localParticipant: localParticipant,
                    screenShareConstraints: const ScreenShareConstraints(
                      useiOSBroadcastExtension: true,
                    ),
                    disabledScreenShareIcon: Icons.stop_screen_share_outlined,
                  ),
                  CallControlOption(
                    icon: const Icon(Icons.chat_outlined),
                    onPressed: () {
                      // Open your chat window
                    },
                  ),
                  FlipCameraOption(
                    call: call,
                    localParticipant: localParticipant,
                  ),
                  AddReactionOption(
                    call: call,
                    localParticipant: localParticipant,
                  ),
                  ToggleMicrophoneOption(
                    call: call,
                    localParticipant: localParticipant,
                  ),
                  ToggleCameraOption(
                    call: call,
                    localParticipant: localParticipant,
                  ),
                ],
              );
            },
          );
        },
      ),


    );
  }

}