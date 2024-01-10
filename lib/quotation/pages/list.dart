import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my24app/core/utils.dart';
import 'package:my24app/core/i18n_mixin.dart';

import 'package:my24app/core/models/models.dart';
import 'package:my24app/quotation/blocs/quotation_bloc.dart';
import 'package:my24app/quotation/blocs/quotation_states.dart';
import 'package:my24app/quotation/widgets/quotation/list.dart';
import 'package:my24app/quotation/widgets/quotation/form.dart';
import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/core/widgets/drawers.dart';
import 'package:my24app/quotation/models/quotation/models.dart';

enum ListModes { ALL, UNACCEPTED }

class QuotationListPage extends StatefulWidget {
  final ListModes mode;

  QuotationListPage({
    required this.mode,
  });

  @override
  State<StatefulWidget> createState() => new _QuotationListPageState();
}

class _QuotationListPageState extends State<QuotationListPage>
    with i18nMixin, TickerProviderStateMixin {
  String? searchQuery = '';
  QuotationEventStatus fetchStatus = QuotationEventStatus.FETCH_ALL;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<QuotationPageMetaData> getPageData(BuildContext context) async {
    String? submodel = await utils.getUserSubmodel();
    String? memberPicture = await utils.getMemberPicture();

    QuotationPageMetaData result = QuotationPageMetaData(
        drawer: await getDrawerForUser(context),
        submodel: submodel,
        memberPicture: memberPicture);

    return result;
  }

  QuotationBloc _initialCall() {
    final QuotationBloc bloc = QuotationBloc();

    bloc.add(QuotationEvent(status: QuotationEventStatus.DO_ASYNC));
    bloc.add(QuotationEvent(status: fetchStatus));

    return bloc;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => _initialCall(),
        child: BlocConsumer<QuotationBloc, QuotationState>(
            listener: (context, state) {
          _handleListeners(context, state);
        }, builder: (context, state) {
          return FutureBuilder<QuotationPageMetaData?>(
              future: getPageData(context),
              builder: (ctx, snapshot) {
                if (snapshot.hasData) {
                  return Scaffold(
                      drawer: snapshot.data!.drawer,
                      body: _getBody(context, state, snapshot.data!.submodel,
                          snapshot.data!.memberPicture));
                } else if (snapshot.hasError) {
                  return Center(
                      child: Text($trans("error_arg",
                          pathOverride: "generic",
                          namedArgs: {"error": "${snapshot.error}"})));
                } else {
                  return Scaffold(body: loadingNotice());
                }
              });
        }));
  }

  void _handleListeners(context, state) {
    final bloc = BlocProvider.of<QuotationBloc>(context);

    if (state is QuotationAcceptedState) {
      if (state.result == true) {
        createSnackBar(context, 'quotations.snackbar_accepted'.tr());

        bloc.add(QuotationEvent(status: QuotationEventStatus.DO_REFRESH));
        bloc.add(QuotationEvent(status: QuotationEventStatus.DO_ASYNC));
        bloc.add(QuotationEvent(status: fetchStatus));

        setState(() {});
      } else {
        displayDialog(context, 'generic.error_dialog_title'.tr(),
            'quotations.error_accepting'.tr());
      }
    }

    if (state is QuotationInsertedState) {
      createSnackBar(context, 'quotations.new.snackbar_created'.tr());
      bloc.add(QuotationEvent(status: QuotationEventStatus.DO_ASYNC));
      bloc.add(QuotationEvent(
          status: QuotationEventStatus.UPDATE_FORM_DATA,
          formData: state.formData));
    }

    if (state is QuotationDeletedState) {
      if (state.result == true) {
        createSnackBar(context, 'quotations.snackbar_deleted'.tr());

        bloc.add(QuotationEvent(status: QuotationEventStatus.DO_REFRESH));
        bloc.add(QuotationEvent(status: QuotationEventStatus.DO_ASYNC));
        bloc.add(QuotationEvent(status: fetchStatus));

        setState(() {});
      } else {
        displayDialog(context, 'generic.error_dialog_title'.tr(),
            'quotations.error_deleting_dialog_content'.tr());
      }
    }

    if (state is QuotationsPreliminaryLoadedState) {
      setState(() {
        fetchStatus = QuotationEventStatus.FETCH_PRELIMINARY;
      });
    } else if (state is QuotationsLoadedState) {
      setState(() {
        fetchStatus = QuotationEventStatus.FETCH_ALL;
      });
    }
  }

  Widget _getBody(context, state, submodel, memberPicture) {
    final bloc = BlocProvider.of<QuotationBloc>(context);

    if (state is QuotationInitialState) {
      return loadingNotice();
    }

    if (state is QuotationLoadingState) {
      return loadingNotice();
    }

    if (state is QuotationErrorState) {
      return errorNoticeWithReload(
          state.message!, bloc, QuotationEvent(status: fetchStatus));
    }

    if (state is QuotationsLoadedState ||
        state is QuotationsPreliminaryLoadedState) {
      PaginationInfo paginationInfo = PaginationInfo(
          count: state.quotations!.count,
          next: state.quotations!.next,
          previous: state.quotations!.previous,
          currentPage: state.page != null ? state.page : 1,
          pageSize: 20);

      return QuotationListWidget(
          paginationInfo: paginationInfo,
          memberPicture: memberPicture,
          quotations: state.quotations,
          fetchStatus: fetchStatus,
          searchQuery: searchQuery,
          submodel: submodel,
          tabController: _tabController);
    }

    if (state is QuotationNewState || state is QuotationUpdateState) {
      return QuotationFormWidget(
          memberPicture: memberPicture, formData: state.formData);
    }

    return loadingNotice();
  }
}
