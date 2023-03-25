import 'package:flutter/material.dart';
import 'package:my24app/core/widgets/drawers.dart';

import 'package:my24app/core/utils.dart';
import '../models/order/models.dart';

mixin PageMetaData {
  Future<OrderPageMetaData> getOrderPageMetaData(BuildContext context) async {
    int pageSize = await utils.getPageSize();
    String submodel = await utils.getUserSubmodel();
    bool hasBranches = await utils.getHasBranches();
    String memberPicture = await utils.getMemberPicture();

    OrderPageMetaData result = OrderPageMetaData(
        drawer: await getDrawerForUserWithSubmodel(context, submodel),
        submodel: submodel,
        firstName: await utils.getFirstName(),
        memberPicture: memberPicture,
        pageSize: 5,
        hasBranches: hasBranches
    );

    return result;
  }

}
