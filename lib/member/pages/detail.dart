import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:my24app/member/widgets/detail.dart';

class MemberPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MemberPageState();
  }
}

class _MemberPageState extends State<MemberPage> {
  @override
  Widget build(BuildContext context) {
    String _appBarTitleText = 'member_detail.app_bar_title'.tr();

    return Scaffold(
        appBar: AppBar(
          title: Text('$_appBarTitleText'),
        ),
        body: Padding(
            padding: EdgeInsets.all(15.0),
            child: showMainView()
        )
    );
  }
}
