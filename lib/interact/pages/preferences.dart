import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/core/i18n_mixin.dart';
import 'package:my24app/core/utils.dart';
import 'package:my24app/core/widgets/drawers.dart';
import 'package:my24app/member/api/member_api.dart';
import 'package:my24app/member/models/models.dart';
import '../../home/pages/home.dart';
import '../blocs/preferences/blocs.dart';
import '../blocs/preferences/states.dart';
import '../models.dart';
import '../widgets/preferences.dart';

class PreferencesPage extends StatelessWidget with i18nMixin {
  final String basePath = "interact.preferences";
  final Utils utils = Utils();
  final PreferencesBloc bloc;

  PreferencesBloc _initialBlocCall() {
    bloc.add(PreferencesEvent(status: PreferencesEventStatus.DO_ASYNC));
    bloc.add(PreferencesEvent(
      status: PreferencesEventStatus.FETCH,
    ));

    return bloc;
  }

  Future<PreferencesPageData> getPageData(BuildContext context) async {
    String memberPicture = await this.utils.getMemberPicture();
    String submodel = await this.utils.getUserSubmodel();
    Members members = await memberApi.fetchMembers();

    PreferencesPageData result = PreferencesPageData(
        drawer: await getDrawerForUserWithSubmodel(context, submodel),
        memberPicture: memberPicture,
        members: members,
    );

    return result;
  }

  PreferencesPage({
    Key key,
    @required this.bloc,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PreferencesPageData>(
        future: getPageData(context),
        builder: (ctx, snapshot) {
          if (snapshot.hasData) {
            PreferencesPageData pageData = snapshot.data;

            return BlocProvider<PreferencesBloc>(
                create: (context) => _initialBlocCall(),
                child: BlocConsumer<PreferencesBloc, PreferencesState>(
                    listener: (context, state) {
                      _handleListeners(context, state);
                    },
                    builder: (context, state) {
                      return Scaffold(
                          drawer: pageData.drawer,
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
                      $trans("error_arg", pathOverride: "generic",
                          namedArgs: {"error": snapshot.error}))
              );
          } else {
          return loadingNotice();
          }
      }
    );
  }

  void _handleListeners(BuildContext context, state) {
    if (state is PreferencesUpdatedState) {
      createSnackBar(context, $trans('snackbar_updated'));

      context.setLocale(utils.lang2locale(state.preferedLanguageCode));

      Navigator.pushReplacement(context,
          new MaterialPageRoute(builder: (context) => My24App())
      );
    }
  }

  Widget _getBody(context, state, PreferencesPageData pageData) {
    if (state is PreferencesInitialState) {
      return loadingNotice();
    }

    if (state is PreferencesLoadingState) {
      return loadingNotice();
    }

    if (state is PreferencesErrorState) {
      // return PreferencesErrorWidget(
      //     error: state.message,
      //     memberPicture: pageData.memberPicture
      // );
    }

    if (state is PreferencesLoadedState) {
      return PreferencesWidget(
        memberPicture: pageData.memberPicture,
        members: pageData.members,
        formData: state.formData,
      );
    }

    return loadingNotice();
  }
}
