import 'package:flutter/material.dart';


class ChatWidget extends StatefulWidget {
  ChatWidget({
    Key key,
  }): super(key: key);

  @override
  State<StatefulWidget> createState() => new _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: SizedBox(height: 1),
    );
  }

}
