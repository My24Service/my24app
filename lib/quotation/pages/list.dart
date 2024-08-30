import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24_flutter_core/models/models.dart';
import 'package:my24_flutter_core/utils.dart';
import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_core/i18n.dart';

import 'package:my24app/quotation/blocs/quotation_bloc.dart';
import 'package:my24app/quotation/blocs/quotation_states.dart';
import 'package:my24app/quotation/widgets/quotation/list.dart';
import 'package:my24app/common/widgets/drawers.dart';
import 'package:my24app/quotation/models/quotation/models.dart';
import 'package:my24app/quotation/pages/form.dart';
import 'package:my24app/quotation/models/quotation/form_data.dart';

enum ListModes { ALL, UNACCEPTED }

class QuotationListPage extends StatefulWidget {
  final i18n = My24i18n(basePath: "quotations");
  final ListModes mode;

  QuotationListPage({
    required this.mode,
  });

  @override
  State<StatefulWidget> createState() => new _QuotationListPageState();
}

class _QuotationListPageState extends State<QuotationListPage>
    with TickerProviderStateMixin {
  String? searchQuery = '';
  QuotationEventStatus fetchStatus = QuotationEventStatus.FETCH_ALL;
  late final TabController _tabController;
  final CoreWidgets widgets = CoreWidgets();
  String? loadedMemberPicture;

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
    String? submodel = await coreUtils.getUserSubmodel();
    String? memberPicture = await coreUtils.getMemberPicture();

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
                  loadedMemberPicture = snapshot.data!.memberPicture;
                  return Scaffold(
                      drawer: snapshot.data!.drawer,
                      body: _getBody(context, state, snapshot.data!.submodel,
                          loadedMemberPicture));
                } else if (snapshot.hasError) {
                  return Center(
                      child: Text(widget.i18n.$trans("error_arg",
                          pathOverride: "generic",
                          namedArgs: {"error": "${snapshot.error}"})));
                } else {
                  return Scaffold(body: widgets.loadingNotice());
                }
              });
        }));
  }

  void _handleListeners(context, state) {
    final bloc = BlocProvider.of<QuotationBloc>(context);

    if (state is QuotationNewState) {
      bloc.add(QuotationEvent(status: QuotationEventStatus.DO_ASYNC));
      bloc.add(QuotationEvent(status: fetchStatus));
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => QuotationForm(
                    memberPicture: loadedMemberPicture,
                    formData: QuotationFormData.createEmpty(),
                    fetchStatus: fetchStatus,
                    widgetsIn: widgets,
                    i18nIn: widget.i18n,
                  )));
    }

    if (state is QuotationAcceptedState) {
      widgets.createSnackBar(context, widget.i18n.$trans('snackbar_accepted'));

      bloc.add(QuotationEvent(status: QuotationEventStatus.DO_REFRESH));
      bloc.add(QuotationEvent(status: QuotationEventStatus.DO_ASYNC));
      bloc.add(QuotationEvent(status: fetchStatus));
    }

    if (state is QuotationDeletedState) {
      widgets.createSnackBar(context, widget.i18n.$trans('snackbar_deleted'));

      bloc.add(QuotationEvent(status: QuotationEventStatus.DO_REFRESH));
      bloc.add(QuotationEvent(status: QuotationEventStatus.DO_ASYNC));
      bloc.add(QuotationEvent(status: fetchStatus));
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
      return widgets.loadingNotice();
    }

    if (state is QuotationLoadingState) {
      return widgets.loadingNotice();
    }

    if (state is QuotationErrorState) {
      return widgets.errorNoticeWithReload(
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
        tabController: _tabController,
        widgetsIn: widgets,
        i18nIn: widget.i18n,
      );
    }

    return widgets.loadingNotice();
  }
}
