import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my24app/login/pages/login.dart';
import 'package:my24app/order/pages/list.dart';
import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24app/member/models/models.dart';
import 'package:my24app/member/models/public/models.dart';
import 'package:my24app/home/pages/home.dart';
import 'package:my24app/mobile/pages/assigned.dart';
import 'package:my24app/company/blocs/workhours_bloc.dart';
import 'package:my24app/company/pages/workhours.dart';
import 'package:my24app/mobile/blocs/assignedorder_bloc.dart';
import 'package:my24app/order/blocs/order_bloc.dart';

// ignore: must_be_immutable
class MemberDetailWidget extends StatelessWidget {
  final MemberDetailData detailData;

  MemberDetailWidget({
    Key? key,
    required this.detailData,
  }) : super(key: key);

  void _navAssignedOrders(BuildContext context) {
    final page = AssignedOrdersPage(
      bloc: AssignedOrderBloc(),
    );

    Navigator.push(context, MaterialPageRoute(
        builder: (context) => page
    ));
  }

  void _navOrders(BuildContext context) {
    Navigator.push(context, new MaterialPageRoute(
        builder: (context) => OrderListPage(
          bloc: OrderBloc(),
        ))
    );
  }

  void _navWorkhours(BuildContext context) {
    Navigator.push(context, new MaterialPageRoute(
        builder: (context) => UserWorkHoursPage(
          bloc: UserWorkHoursBloc(),
        ))
    );
  }

  Widget _buildLogo(Member? member) => SizedBox(
      width: 100,
      height: 210,
      child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (member != null)
              Image.network(member.companylogoUrl!,
                  cacheWidth: 100),
          ]
      )
  );

  Widget _getButton(String? submodel, BuildContext context) {
    // do nothing when no value yet
    if (detailData.isLoggedIn == null) {
      return SizedBox(height: 1);
    }

    if (detailData.isLoggedIn == true) {
      if (submodel == 'engineer') {
        return createDefaultElevatedButton(
            'member_detail.button_go_to_orders'.tr(),
            () => _navAssignedOrders(context)
        );
      }

      if (submodel == 'branch_employee_user') {
        return createDefaultElevatedButton(
            'member_detail.button_go_to_orders'.tr(),
                () => _navOrders(context)
        );
      }

      if (submodel == 'employee_user') {
        return createDefaultElevatedButton(
            'member_detail.button_go_to_workhours'.tr(),
                () => _navWorkhours(context)
        );
      }

      return createDefaultElevatedButton(
          'member_detail.button_go_to_orders'.tr(),
          () => _navOrders(context)
      );
    }

    return Container(
        child: Center(
            child: createDefaultElevatedButton(
                'member_detail.button_login'.tr(),
                () {
                  Navigator.push(context,
                      new MaterialPageRoute(
                          builder: (context) => LoginPage())
                  );
                }
            )
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
            children: [
              Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLogo(detailData.member),
                    Flexible(
                        child: buildMemberInfoCard(context, detailData.member)
                    )
                  ]
              ),
              _getButton(detailData.submodel, context),
              Spacer(),
              createElevatedButtonColored(
                  'member_detail.button_member_list'.tr(),
                  () async {
                    SharedPreferences prefs = await SharedPreferences.getInstance();

                    prefs.remove('skip_member_list');
                    prefs.remove('prefered_member_pk');
                    prefs.remove('preferred_member_pk');
                    prefs.remove('prefered_companycode');
                    prefs.remove('preferred_companycode');

                    Navigator.pushReplacement(context,
                        new MaterialPageRoute(builder: (context) => My24App())
                    );
                  },
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.red
              ),
            ]
        )
    );
  }
}
