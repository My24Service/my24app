import 'package:flutter/material.dart';
import 'package:my24app/core/widgets/drawers.dart';

import 'package:my24app/core/utils.dart';
import '../models/order/models.dart';

mixin PageMetaData {
  final Utils utils = Utils();

  Future<OrderPageMetaData> getOrderPageMetaData(BuildContext context) async {
    String submodel = await this.utils.getUserSubmodel();
    bool hasBranches = await this.utils.getHasBranches();
    String memberPicture = await this.utils.getMemberPicture();

    OrderPageMetaData result = OrderPageMetaData(
        drawer: await getDrawerForUserWithSubmodel(context, submodel),
        submodel: submodel,
        firstName: await utils.getFirstName(),
        memberPicture: memberPicture,
        pageSize: 20,
        hasBranches: hasBranches
    );

    return result;
  }

}
