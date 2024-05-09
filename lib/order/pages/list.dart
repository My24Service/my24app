import 'package:flutter/material.dart';

import 'package:my24_flutter_orders/pages/list.dart';

import './function_types.dart';

class OrderListPage extends BaseOrderListPage {
  OrderListPage({
    super.key,
    required super.bloc,
    required super.fetchMode,
  }) : super(
      navFormFunction: navFormFunction,
      navDetailFunction: navDetailFunction
  );

  @override
  Future<Widget?> getDrawerForUserWithSubmodel(BuildContext context, String? submodel) async {
    return await getDrawerForUserWithSubmodel(context, submodel);
  }
}
