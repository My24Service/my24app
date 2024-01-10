import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my24app/core/utils.dart';

import 'package:my24app/quotation/blocs/quotation_bloc.dart';
import 'package:my24app/quotation/blocs/quotation_states.dart';
import 'package:my24app/quotation/widgets/list_preliminary.dart';
import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/core/widgets/drawers.dart';
import 'package:my24app/quotation/models/quotation/models.dart';

class PreliminaryQuotationListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _PreliminaryQuotationListPageState();
}

class _PreliminaryQuotationListPageState extends State<PreliminaryQuotationListPage> {
  final _scrollThreshold = 200.0;
  ScrollController? controller;
  List<Quotation>? quotationList = [];
  bool hasNextPage = false;
  int page = 1;
  bool inPaging = false;
  String? searchQuery = '';
  QuotationEventStatus fetchStatus = QuotationEventStatus.FETCH_PRELIMINARY;
  bool rebuild = true;
  bool inSearch = false;
  bool refresh = false;
  bool firstTime = true;

  _scrollListener() {
    // end reached
    final maxScroll = controller!.position.maxScrollExtent;
    final currentScroll = controller!.position.pixels;
    final bloc = BlocProvider.of<QuotationBloc>(context);

    if (hasNextPage && maxScroll - currentScroll <= _scrollThreshold) {
      bloc.add(QuotationEvent(status: QuotationEventStatus.DO_ASYNC));
      bloc.add(QuotationEvent(
        status: fetchStatus,
        page: ++page,
        query: searchQuery,
      ));
      inPaging = true;
    }
  }

  @override
  void initState() {
    controller = new ScrollController()..addListener(_scrollListener);
    super.initState();
  }

  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
  }

  QuotationBloc _initialCall() {
    final QuotationBloc bloc = QuotationBloc();

    if (firstTime) {
      bloc.add(QuotationEvent(status: QuotationEventStatus.DO_ASYNC));
      bloc.add(QuotationEvent(status: fetchStatus));

      firstTime = false;
    }

    return bloc;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => _initialCall(),
        child: FutureBuilder<String?>(
            future: utils.getUserSubmodel(),
            builder: (ctx, snapshot) {
              if (snapshot.data == null) {
                return loadingNotice();
              }

              final String? submodel = snapshot.data;

              return FutureBuilder<Widget?>(
                  future: getDrawerForUser(context),
                  builder: (ctx, snapshot) {
                    if (snapshot.data == null) {
                      return loadingNotice();
                    }

                    final Widget? drawer = snapshot.data;
                    final title = 'quotations.preliminary_list.app_bar_title'.tr();

                    return BlocConsumer<QuotationBloc, QuotationState>(
                        listener: _handleListeners,
                        builder: (context, state) {
                          return Scaffold(
                              appBar: AppBar(
                                title: Text(title),
                              ),
                              drawer: drawer,
                              body: _getBody(context, state, submodel)
                          );
                        }
                    );
                  }
              );
          }
      )
    );
  }

  void _handleListeners(context, state) {
    final bloc = BlocProvider.of<QuotationBloc>(context);

    if (state is QuotationDeletedState) {
      if (state.result == true) {
        createSnackBar(
            context, 'quotations.snackbar_deleted'.tr());

        bloc.add(QuotationEvent(status: QuotationEventStatus.DO_REFRESH));
        bloc.add(QuotationEvent(status: QuotationEventStatus.DO_ASYNC));
        bloc.add(QuotationEvent(status: fetchStatus));

        setState(() {});
      } else {
        displayDialog(context,
            'generic.error_dialog_title'.tr(),
            'quotations.error_deleting_dialog_content'.tr()
        );
      }
    }
  }

  Widget _getBody(context, state, submodel) {
    final bloc = BlocProvider.of<QuotationBloc>(context);

    if (state is QuotationInitialState) {
      return loadingNotice();
    }

    if (state is QuotationLoadingState) {
      return loadingNotice();
    }

    if (state is QuotationErrorState) {
      return errorNoticeWithReload(
          state.message!,
          bloc,
          QuotationEvent(status: fetchStatus)
      );
    }

    if (state is QuotationRefreshState) {
      // reset vars on refresh
      quotationList = [];
      page = 1;
      inPaging = false;
      refresh = true;
    }

    if (state is QuotationSearchState) {
      // reset vars on search
      quotationList = [];
      inSearch = true;
      page = 1;
      inPaging = false;
      refresh = true;
    }

    if (state is QuotationsPreliminaryLoadedState) {
      if (rebuild || refresh || (inSearch && !inPaging)) {
        // set search string and orderList
        searchQuery = state.query;
        quotationList = state.quotations!.results;
      } else {
        // only merge on widget build, paging and search
        if (inPaging || searchQuery != null) {
          hasNextPage = state.quotations!.next != null;
          quotationList = new List.from(quotationList!)..addAll(state.quotations!.results!);
          rebuild = false;
        }
      }

      return QuotationListPreliminaryWidget(
        quotationList: quotationList,
        controller: controller,
        fetchStatus: fetchStatus,
        searchQuery: searchQuery,
        submodel: submodel,
      );
    }

    return loadingNotice();
  }
}
