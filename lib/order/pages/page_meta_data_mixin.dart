import 'package:flutter/material.dart';
import 'package:my24_flutter_core/utils.dart';
import 'package:my24app/common/widgets/drawers.dart';

import 'package:my24app/common/utils.dart';
import '../models/order/models.dart';

mixin PageMetaData {
  final Utils utils = Utils();

  Future<OrderPageMetaData> getOrderPageMetaData(BuildContext context) async {
    String? submodel = await coreUtils.getUserSubmodel();
    bool? hasBranches = await this.utils.getHasBranches();
    String? memberPicture = await coreUtils.getMemberPicture();

    OrderPageMetaData result = OrderPageMetaData(
        drawer: await getDrawerForUserWithSubmodel(context, submodel),
        submodel: submodel,
        firstName: await coreUtils.getFirstName(),
        memberPicture: memberPicture,
        pageSize: 20,
        hasBranches: hasBranches
    );

    return result;
  }

}
