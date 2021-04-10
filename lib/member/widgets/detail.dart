import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/core/utils.dart';
import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/member/models/models.dart';
import 'package:my24app/member/blocs/fetch_bloc.dart';
import 'package:my24app/member/blocs/fetch_states.dart';
import 'package:my24app/home/pages/home.dart';


// ignore: must_be_immutable
class ShowMainView extends StatelessWidget {
  final bool doSkip;
  ElevatedButton _goToOrdersButton;

  ShowMainView({
    Key key,
    @required this.doSkip,
  }) : super(key: key);

  void _navAssignedOrders() {
    // Navigator.push(context, new MaterialPageRoute(
    //     builder: (context) => AssignedOrdersListPage())
    // );
  }

  void _navOrders() {
    // Navigator.push(context, new MaterialPageRoute(
    //     builder: (context) => OrderListPage())
    // );
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

  Widget _getButton(bool loggedIn, String submodel) {
    if (loggedIn == true) {
      if (submodel == 'engineer') {
        return createBlueElevatedButton(
            'member_detail.button_go_to_orders'.tr(), _navAssignedOrders);
      }

      return createBlueElevatedButton(
          'member_detail.button_go_to_orders'.tr(), _navOrders);
    }

    return Container(
        child: Center(child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Colors.blue, // background
              onPrimary: Colors.white, // foreground
            ),
            child: new Text('member_detail.button_login'.tr()),
            onPressed: () {
              // Navigator.push(context,
              //     new MaterialPageRoute(
              //         builder: (context) => LoginPageWidget())
              // );
            }
        ))
    );
  }

  Widget _showMainView(MemberPublic member, bool loggedIn, String submodel, BuildContext context) {
    return Center(
        child: Column(
            children: [
              Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLogo(member),
                    Flexible(
                        child: buildMemberInfoCard(member)
                    )
                  ]
              ),
              _getButton(loggedIn, submodel),
              Spacer(),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red, // background
                    onPrimary: Colors.white, // foreground
                  ),
                  child: new Text('member_detail.button_member_list'.tr()),
                  onPressed: () async {
                    SharedPreferences prefs = await SharedPreferences.getInstance();

                    prefs.remove('skip_member_list');
                    prefs.remove('prefered_member_pk');
                    prefs.remove('prefered_companycode');

                    Navigator.pushReplacement(context,
                        new MaterialPageRoute(builder: (context) => My24App())
                    );
                  }
              )
            ]
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: utils.isLoggedInSlidingToken(),
      builder: (ctx, snapshot) {
        bool isLoggedIn = snapshot.data; //     final String submodel = await utils.getUserSubmodel();

        return FutureBuilder<String>(
          future: utils.getUserSubmodel(),
          builder: (ctx, snapshot) {
            String submodel = snapshot.data;

            FetchMemberBloc createBloc = FetchMemberBloc(
              MemberFetchInitialState())..add(FetchMemberEvent(status: MemberEventStatus.FETCH_MEMBER_PREF)
            );

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
                    return errorNotice();
                  }

                  if (state is MemberFetchLoadedByPrefState) {
                    return _showMainView(state.member, isLoggedIn, submodel, context);
                  }

                  return errorNotice();
                }
              )
            );
          }
        );
      },
    );
  }

}
