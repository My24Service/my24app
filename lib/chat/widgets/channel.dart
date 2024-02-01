import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

import 'package:my24app/chat/pages/chat.dart';
import '../pages/members.dart';

class ChannelWidget extends StatefulWidget {
  final int? initialScrollIndex;
  final double? initialAlignment;
  final bool highlightInitialMessage;
  final InitData initData;
  final Channel? directMessageChannel;

  const ChannelWidget({
    required this.initData,
    Key? key,
    this.initialScrollIndex,
    this.initialAlignment,
    this.highlightInitialMessage = false,
    this.directMessageChannel,
  }) : super(key: key);

  @override
  _ChannelWidgetState createState() => _ChannelWidgetState();
}

class _ChannelWidgetState extends State<ChannelWidget> {
  late FocusNode _focusNode;
  StreamMessageInputController _messageInputController =
      StreamMessageInputController();

  @override
  void initState() {
    _focusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _reply(Message message) {
    _messageInputController.quotedMessage = message;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _focusNode.requestFocus();
    });
  }

  void _navMembersPage(Channel channel, InitData initData) {
    final page = MembersPage(channel: channel, initData: initData);

    Navigator.push(context,
        MaterialPageRoute(
            builder: (context) => page)
    );
  }

  @override
  Widget build(BuildContext context) {
    final channel = widget.directMessageChannel != null ? widget.directMessageChannel : widget.initData.channel;

    return StreamChannel(
        channel: channel!,
        child: Builder(
          builder: (context) {
            return Scaffold(
              backgroundColor: StreamChatTheme
                  .of(context)
                  .colorTheme
                  .appBg,
              appBar: StreamChannelHeader(
                // showBackButton: false,
                // leading: StreamBackButton(
                //   showUnreads: false,
                // ),
                onTitleTap: () => {
                  _navMembersPage(widget.initData.channel, widget.initData)
                },
                showTypingIndicator: false,
              ),
              body: Column(
                children: <Widget>[
                  Expanded(
                    child: Stack(
                      children: <Widget>[
                        StreamMessageListView(
                          initialScrollIndex: widget.initialScrollIndex,
                          initialAlignment: widget.initialAlignment,
                          highlightInitialMessage: widget
                              .highlightInitialMessage,
                          onMessageSwiped: _reply,
                          // messageFilter: defaultFilter,
                          messageBuilder: (context, details, messages,
                              defaultMessage) {
                            return defaultMessage.copyWith(
                              onReplyTap: _reply,
                            );
                          },
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            alignment: Alignment.centerLeft,
                            color: StreamChatTheme
                                .of(context)
                                .colorTheme
                                .appBg
                                .withOpacity(.9),
                            child: StreamTypingIndicator(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              style: StreamChatTheme
                                  .of(context)
                                  .textTheme
                                  .footnote
                                  .copyWith(
                                  color: StreamChatTheme
                                      .of(context)
                                      .colorTheme
                                      .textLowEmphasis),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  StreamMessageInput(
                    showCommandsButton: false,
                    disableAttachments: true,
                    focusNode: _focusNode,
                    messageInputController: _messageInputController,
                  ),
                ],
              ),
            );
          },
        ),
      );
    }

  // bool defaultFilter(Message m) {
  //   var _currentUser = StreamChat.of(context).currentUser;
  //   final isMyMessage = m.user?.id == _currentUser?.id;
  //   final isDeletedOrShadowed = m.isDeleted == true || m.shadowed == true;
  //   if (isDeletedOrShadowed && !isMyMessage) return false;
  //   return true;
  // }
}
