import 'package:flutter/material.dart';

import 'package:my24_flutter_orders/pages/list.dart';
import 'package:my24app/common/widgets/drawers.dart' as drawers;

import './function_types.dart';

class OrderListPage extends BaseOrderListPage {
  OrderListPage({
    super.key,
    required super.bloc,
    required super.fetchMode,
  }) : super(
      navFormFunction: navFormFunction,
      navDetailFunction: navDetailFunction,
      navAssignFunction: navAssignOrder
  );

  @override
  Future<Widget?> getDrawerForUserWithSubmodel(
      BuildContext context, String? submodel) async {
    return await drawers.getDrawerForUserWithSubmodel(context, submodel);
  }
}
