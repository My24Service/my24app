import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/core/utils.dart';
import 'package:my24app/order/blocs/order_bloc.dart';
import 'package:my24app/order/blocs/order_states.dart';
import 'package:my24app/order/widgets/order_list.dart';
import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/core/widgets/drawers.dart';

class NotYetAcceptedListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _NotYetAcceptedListPageState();
}

class _NotYetAcceptedListPageState extends State<NotYetAcceptedListPage> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: new Text('orders.not_yet_accepted.app_bar_title'.tr()),
        centerTitle: true,
      ),
      // body: LoginView(),
    );
  }
}
