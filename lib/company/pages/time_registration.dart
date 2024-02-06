import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_core/i18n.dart';
import 'package:my24_flutter_core/models/models.dart';

import 'package:my24app/common/utils.dart';
import 'package:my24app/company/blocs/time_registration_bloc.dart';
import 'package:my24app/company/blocs/time_registration_states.dart';
import 'package:my24app/company/widgets/time_registration/list.dart';
import 'package:my24app/company/widgets/time_registration/error.dart';
import 'package:my24app/company/models/time_registration/models.dart';
import 'package:my24app/common/widgets/drawers.dart';


String? initialLoadMode;
int? userId;
DateTime? startDate;
String? mode;

class TimeRegistrationPage extends StatelessWidget {
  final TimeRegistrationBloc bloc;
  final Utils utils = Utils();
  final CoreWidgets widgets = CoreWidgets();
  final i18n = My24i18n(basePath: "company.time_registration");

  Future<TimeRegistrationPageData> getPageData(BuildContext context) async {
    String? memberPicture = await this.utils.getMemberPicture();
    String? submodel = await this.utils.getUserSubmodel();

    TimeRegistrationPageData result = TimeRegistrationPageData(
        drawer: await getDrawerForUserWithSubmodel(context, submodel),
        memberPicture: memberPicture,
        isPlanning: submodel == 'planning_user'
    );

    return result;
  }

  TimeRegistrationPage({
    Key? key,
    required this.bloc,
    int? pk,
    DateTime? startDateIn,
    String? modeIn,
  }) : super(key: key) {
    userId = pk;
    startDate = startDateIn;
    mode = modeIn;
  }

  TimeRegistrationBloc _initialBlocCall() {
    bloc.add(TimeRegistrationEvent(status: TimeRegistrationEventStatus.DO_ASYNC));
    bloc.add(TimeRegistrationEvent(
        status: TimeRegistrationEventStatus.FETCH_ALL,
        userId: userId,
        mode: mode,
        startDate: startDate
    ));

    return bloc;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<TimeRegistrationPageData>(
        future: getPageData(context),
        builder: (ctx, snapshot) {
          if (snapshot.hasData) {
            TimeRegistrationPageData? pageData = snapshot.data;

            return BlocProvider<TimeRegistrationBloc>(
                create: (context) => _initialBlocCall(),
                child: BlocConsumer<TimeRegistrationBloc, TimeRegistrationState>(
                    listener: (context, state) {
                    },
                    builder: (context, state) {
                      return Scaffold(
                          drawer: pageData!.drawer,
                          body: _getBody(context, state, pageData),
                      );
                    }
                )
            );
          } else if (snapshot.hasError) {
            return Center(
                child: Text(
                    i18n.$trans("error_arg", pathOverride: "generic",
                        namedArgs: {"error": "${snapshot.error}"}
                    )
                )
            );
          } else {
            return Scaffold(
                body: widgets.loadingNotice()
            );
          }
        }
    );

  }

  Widget _getBody(context, state, TimeRegistrationPageData? pageData) {
    if (state is TimeRegistrationInitialState) {
      return widgets.loadingNotice();
    }

    if (state is TimeRegistrationLoadingState) {
      return widgets.loadingNotice();
    }

    if (state is TimeRegistrationErrorState) {
      return TimeRegistrationListErrorWidget(
          error: state.message,
          memberPicture: pageData!.memberPicture,
          widgetsIn: widgets,
          i18nIn: i18n,
      );
    }

    if (state is TimeRegistrationModeSwitchState) {
      PaginationInfo paginationInfo = PaginationInfo(
          count: 0,
          next: null,
          previous: null,
          currentPage: 1,
          pageSize: 20
      );

      return TimeRegistrationListWidget(
        timeRegistration: state.timeRegistrationData,
        paginationInfo: paginationInfo,
        memberPicture: pageData!.memberPicture,
        mode: state.mode!,
        startDate: state.startDate!,
        isPlanning: pageData.isPlanning,
        userId: state.userId,
        widgetsIn: widgets,
        i18nIn: i18n,
      );
    }

    if (state is TimeRegistrationLoadedState) {
      final String mode = state.mode == null ? 'week' : state.mode!;

      PaginationInfo paginationInfo = PaginationInfo(
          count: 0,
          next: null,
          previous: null,
          currentPage: 1,
          pageSize: 20
      );

      return TimeRegistrationListWidget(
        timeRegistration: state.timeRegistrationData,
        paginationInfo: paginationInfo,
        memberPicture: pageData!.memberPicture,
        mode: mode,
        startDate: state.startDate!,
        isPlanning: pageData.isPlanning,
        userId: state.userId,
        widgetsIn: widgets,
        i18nIn: i18n,
      );
    }

    return widgets.loadingNotice();
  }
}
