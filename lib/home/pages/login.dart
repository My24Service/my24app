import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24_flutter_core/i18n.dart';
import 'package:my24_flutter_core/utils.dart';
import 'package:my24_flutter_equipment/blocs/equipment_bloc.dart';
import 'package:my24_flutter_member_models/public/models.dart';
import 'package:my24app/home/pages/home.dart';

import 'package:my24app/home/widgets/login.dart';
import 'package:my24app/common/widgets/widgets.dart';
import 'package:my24app/home/blocs/home_bloc.dart';
import 'package:my24app/home/blocs/home_states.dart';
import 'package:my24app/common/utils.dart';
import 'package:my24app/company/models/models.dart';
import 'package:my24app/equipment/pages/detail.dart';

class PageData {
  final BaseUser? user;
  final Member? member;
  final String title;

  PageData({
    required this.user,
    required this.member,
    required this.title
  });

}

class LoginPage extends StatelessWidget {
  final My24i18n i18n = My24i18n(basePath: "login");
  final HomeBloc bloc;
  final String? initialMode;
  final HomeDoLoginState? loginState;
  final Member? memberFromHome;
  final CoreUtils coreUtils = CoreUtils();
  final Utils utils = Utils();
  final String languageCode;
  final String? equipmentUuid;
  final EquipmentBloc? equipmentBloc; // only here for testability
  final bool isLoggedIn;

  LoginPage({
    super.key,
    required this.bloc,
    this.initialMode,
    this.loginState,
    this.memberFromHome,
    required this.languageCode,
    this.equipmentUuid,
    this.equipmentBloc,
    required this.isLoggedIn
  });

  HomeBloc _initialCall() {
    if (initialMode == null) {
      bloc.add(HomeEvent(
        status: HomeEventStatus.getPreferences,
        memberFromHome: memberFromHome
      ));
    } else if (initialMode == "login") {
      bloc.add(HomeEvent(
          status: HomeEventStatus.doLogin,
          doLoginState: loginState
      ));
    }

    return bloc;
  }

  Future<PageData> getPageData() async {
    final title = isLoggedIn ? i18n.$trans('app_bar_title_logged_in') : i18n.$trans('app_bar_title');
    final BaseUser? user = await utils.getUserInfo();
    Member? member = memberFromHome != null ? memberFromHome! : await utils.fetchMember();

    return PageData(user: user, member: member, title: title);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PageData>(
        future: getPageData(),
        builder: (context, dynamic snapshot) {
          if (!snapshot.hasData) {
            return loadingNotice();
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                  i18n.$trans("error_arg", pathOverride: "generic",
                      namedArgs: {"error": "${snapshot.error}"}
                  )
              )
          );
        } else {
            PageData pageData = snapshot.data;

            return BlocProvider<HomeBloc>(
                create: (context) => _initialCall(),
                child: BlocConsumer<HomeBloc, HomeBaseState>(
                    listener: (context, state) {
                      _handleListeners(context, state);
                    },
                    builder: (context, state) {
                      return Scaffold(
                        appBar: AppBar(
                          title: Text(pageData.title),
                          centerTitle: true,
                        ),
                        body: _getBody(context, state, pageData),
                      );
                    }
                )
            );
          }
        }
    );
  }

  void _handleListeners(BuildContext context, state) {
    if (state is HomeMemberClearedState) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) =>
            My24App()
          )
      );
    }

    if (state is HomeLoggedInState && equipmentUuid != null) {
      createSnackBar(context, i18n.$trans('snackbar_logged_in'));

      Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) =>
              EquipmentDetailPage(
                bloc: equipmentBloc != null ? equipmentBloc! : EquipmentBloc(),
                uuid: equipmentUuid,
              )
          )
      );
    }

    if (state is HomeLoginErrorState) {
      createSnackBar(context, i18n.$trans('snackbar_error_logging_in'));
    }
  }

  Widget _getBody(context, state, PageData pageData) {
    if (state is HomeState) {
      return LoginWidget(
        user: pageData.user,
        member: pageData.member,
        i18n: i18n,
        languageCode: languageCode,
        equipmentUuid: equipmentUuid,
      );
    }

    if (state is HomeLoggedInState) {
      return LoginWidget(
        user: state.user,
        member: state.member,
        i18n: i18n,
        languageCode: languageCode,
        equipmentUuid: equipmentUuid,
      );
    }

    if (state is HomeLoginErrorState) {
      return LoginWidget(
        user: null,
        member: state.member,
        i18n: i18n,
        languageCode: languageCode,
        equipmentUuid: equipmentUuid,
      );
    }

    return loadingNotice();
  }
}
