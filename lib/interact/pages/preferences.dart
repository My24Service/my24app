import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24_flutter_core/utils.dart';
import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_core/i18n.dart';
import 'package:my24_flutter_member_models/public/api.dart';
import 'package:my24_flutter_member_models/public/models.dart';

import 'package:my24app/common/widgets/drawers.dart';
import 'package:my24app/home/pages/home.dart';
import '../blocs/preferences/blocs.dart';
import '../blocs/preferences/states.dart';
import '../models.dart';
import '../widgets/preferences.dart';

class PreferencesPage extends StatelessWidget{
  final i18n = My24i18n(basePath: "interact.preferences");
  final PreferencesBloc bloc;
  final MemberListPublicApi memberApi = MemberListPublicApi();
  final CoreWidgets widgets = CoreWidgets();

  PreferencesBloc _initialBlocCall() {
    bloc.add(PreferencesEvent(status: PreferencesEventStatus.DO_ASYNC));
    bloc.add(PreferencesEvent(
      status: PreferencesEventStatus.FETCH,
    ));

    return bloc;
  }

  Future<PreferencesPageData> getPageData(BuildContext context) async {
    String? memberPicture = await coreUtils.getMemberPicture();
    String? submodel = await coreUtils.getUserSubmodel();
    Members members = await memberApi.list();

    PreferencesPageData result = PreferencesPageData(
        drawer: await getDrawerForUserWithSubmodel(context, submodel),
        memberPicture: memberPicture,
        members: members,
    );

    return result;
  }

  PreferencesPage({
    Key? key,
    required this.bloc,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PreferencesPageData>(
        future: getPageData(context),
        builder: (ctx, snapshot) {
          if (snapshot.hasData) {
            PreferencesPageData? pageData = snapshot.data;

            return BlocProvider<PreferencesBloc>(
                create: (context) => _initialBlocCall(),
                child: BlocConsumer<PreferencesBloc, PreferencesState>(
                    listener: (context, state) {
                      _handleListeners(context, state);
                    },
                    builder: (context, state) {
                      return Scaffold(
                          drawer: pageData!.drawer,
                          body: GestureDetector(
                            onTap: () {
                              FocusScope.of(context).requestFocus(FocusNode());
                            },
                            child: _getBody(context, state, pageData),
                          )
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
          return widgets.loadingNotice();
          }
      }
    );
  }

  void _handleListeners(BuildContext context, state) {
    if (state is PreferencesUpdatedState) {
      widgets.createSnackBar(context, i18n.$trans('snackbar_updated'));

      context.setLocale(coreUtils.lang2locale(state.preferredLanguageCode)!);

      Navigator.pushReplacement(context,
          new MaterialPageRoute(builder: (context) => My24App())
      );
    }
  }

  Widget _getBody(context, state, PreferencesPageData? pageData) {
    if (state is PreferencesInitialState) {
      return widgets.loadingNotice();
    }

    if (state is PreferencesLoadingState) {
      return widgets.loadingNotice();
    }

    if (state is PreferencesErrorState) {
      // return PreferencesErrorWidget(
      //     error: state.message,
      //     memberPicture: pageData.memberPicture
      // );
    }

    if (state is PreferencesLoadedState) {
      return PreferencesWidget(
        memberPicture: pageData!.memberPicture,
        members: pageData.members,
        formData: state.formData,
        widgetsIn: widgets,
        i18nIn: i18n,
      );
    }

    return widgets.loadingNotice();
  }
}
