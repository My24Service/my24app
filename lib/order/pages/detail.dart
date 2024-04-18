import 'package:flutter/material.dart';
import 'package:my24_flutter_orders/pages/detail.dart';

class OrderDetailPage<OrderBloc> extends BaseOrderDetailPage {
  OrderDetailPage({
    super.key,
    required super.bloc,
    required super.orderId,
  });

  @override
  Future<Widget?> getDrawerForUserWithSubmodel(BuildContext context, String? submodel) async {
    return null;
  }

}
