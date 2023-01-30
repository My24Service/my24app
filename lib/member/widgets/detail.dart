import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:my24app/login/pages/login.dart';
import 'package:my24app/order/pages/list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/core/utils.dart';
import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/member/models/models.dart';
import 'package:my24app/member/blocs/fetch_bloc.dart';
import 'package:my24app/member/blocs/fetch_states.dart';
import 'package:my24app/home/pages/home.dart';
import 'package:my24app/mobile/pages/assigned_list.dart';

import '../../company/pages/workhours_list.dart';

// ignore: must_be_immutable
class MemberDetailWidget extends StatelessWidget {
  final bool isLoggedIn;

  MemberDetailWidget(this.isLoggedIn);

  void _navAssignedOrders(BuildContext context) {
    final page = AssignedOrderListPage();

    Navigator.push(context, MaterialPageRoute(
        builder: (context) => page
    ));
  }

  void _navOrders(BuildContext context) {
    Navigator.push(context, new MaterialPageRoute(
        builder: (context) => OrderListPage())
    );
  }

  void _navWorkhours(BuildContext context) {
    Navigator.push(context, new MaterialPageRoute(
        builder: (context) => UserWorkHoursListPage())
    );
  }

  Widget _buildLogo(MemberPublic member) => SizedBox(
      width: 100,
      height: 210,
      child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (member != null)
              Image.network(member.companylogoUrl,
                  cacheWidth: 100),
          ]
      )
  );

  Widget _getButton(String submodel, BuildContext context) {
    // do nothing when no value yet
    if (this.isLoggedIn == null) {
      return SizedBox(height: 1);
    }

    if (this.isLoggedIn == true) {
      if (submodel == 'engineer') {
        return createDefaultElevatedButton(
            'member_detail.button_go_to_orders'.tr(),
            () => _navAssignedOrders(context)
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

  Widget _showMainView(MemberPublic member, String submodel, BuildContext context) {
    return Center(
        child: Column(
            children: [
              Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLogo(member),
                    Flexible(
                        child: buildMemberInfoCard(context, member)
                    )
                  ]
              ),
              _getButton(submodel, context),
              Spacer(),
              createElevatedButtonColored(
                  'member_detail.button_member_list'.tr(),
                  () async {
                    SharedPreferences prefs = await SharedPreferences.getInstance();

                    prefs.remove('skip_member_list');
                    prefs.remove('prefered_member_pk');
                    prefs.remove('prefered_companycode');

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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
        future: utils.getUserSubmodel(),
        builder: (ctx, snapshot) {
          String submodel = snapshot.data;

          FetchMemberBloc createBloc = FetchMemberBloc()..add(FetchMemberEvent(status: MemberEventStatus.FETCH_MEMBER_PREF));

          return BlocProvider(
            create: (BuildContext context) => createBloc,
            child: BlocBuilder<FetchMemberBloc, MemberFetchState>(
              builder: (context, state) {
                if (state is MemberFetchInitialState) {
                  return loadingNotice();
                }

                if (state is MemberFetchLoadingState) {
                  return loadingNotice();
                }

                if (state is MemberFetchErrorState) {
                  return errorNotice(state.message);
                }

                if (state is MemberFetchLoadedByPrefState) {
                  return _showMainView(state.member, submodel, context);
                }

                return errorNotice('generic.error'.tr());
              }
            )
          );
        }
    );
  }
}
