import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my24app/core/utils.dart';

import 'package:my24app/quotation/blocs/quotation_bloc.dart';
import 'package:my24app/quotation/blocs/quotation_states.dart';
import 'package:my24app/quotation/widgets/list.dart';
import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/core/widgets/drawers.dart';
import 'package:my24app/quotation/models/models.dart';

enum listModes {
  ALL,
  UNACCEPTED
}

class QuotationListPage extends StatefulWidget {
  final listModes mode;
  
  QuotationListPage({
    @required this.mode,
  });
  
  @override
  State<StatefulWidget> createState() => new _QuotationListPageState();
}

class _QuotationListPageState extends State<QuotationListPage> {
  final _scrollThreshold = 200.0;
  ScrollController controller;
  QuotationBloc bloc = QuotationBloc(QuotationInitialState());
  List<QuotationView> quotationList = [];
  bool hasNextPage = false;
  int page = 1;
  bool inPaging = false;
  String searchQuery = '';
  QuotationEventStatus fetchStatus = QuotationEventStatus.FETCH_ALL;

  _scrollListener() {
    // end reached
    final maxScroll = controller.position.maxScrollExtent;
    final currentScroll = controller.position.pixels;
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
    if (widget.mode == listModes.UNACCEPTED) {
      fetchStatus = QuotationEventStatus.FETCH_UNACCEPTED;
    }
    
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool rebuild = true;
    List<QuotationView> quotationList = [];
    bool inSearch = false;
    bool refresh = false;
    inPaging = false;

    _initialCall() {
      QuotationBloc bloc = QuotationBloc(QuotationInitialState());
      bloc.add(QuotationEvent(status: QuotationEventStatus.DO_ASYNC));
      bloc.add(QuotationEvent(status: fetchStatus));

      return bloc;
    }

    return BlocProvider(
        create: (BuildContext context) => _initialCall(),
        child: FutureBuilder<String>(
            future: utils.getUserSubmodel(),
            builder: (ctx, snapshot) {
              if (snapshot.data == null) {
                return loadingNotice();
              }

              final String submodel = snapshot.data;

              return FutureBuilder<Widget>(
                future: getDrawerForUser(context),
                builder: (ctx, snapshot) {
                    final Widget drawer = snapshot.data;
                    final title = widget.mode == listModes.ALL ? 'quotations.app_bar_title'.tr() : 'quotations.unaccepted.app_bar_title'.tr();
                    bloc = BlocProvider.of<QuotationBloc>(ctx);

                    return Scaffold(
                      appBar: AppBar(
                        title: Text(title),
                      ),
                      drawer: drawer,
                      body: BlocListener<QuotationBloc, QuotationState>(
                          listener: (context, state) {
                            if (state is QuotationAcceptedState) {
                              if (state.result == true) {
                                createSnackBar(context, 'quotations.snackbar_accepted'.tr());

                                bloc.add(QuotationEvent(status: QuotationEventStatus.DO_REFRESH));
                                bloc.add(QuotationEvent(status: QuotationEventStatus.DO_ASYNC));
                                bloc.add(QuotationEvent(status: fetchStatus));

                                setState(() {});
                              } else {
                                displayDialog(context,
                                    'generic.error_dialog_title'.tr(),
                                    'quotations.error_accepting'.tr());
                              }
                            }

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
                          },
                          child: BlocBuilder<QuotationBloc, QuotationState>(
                              builder: (context, state) {
                                if (state is QuotationInitialState) {
                                  return loadingNotice();
                                }

                                if (state is QuotationLoadingState) {
                                  return loadingNotice();
                                }

                                if (state is QuotationErrorState) {
                                  return errorNoticeWithReload(
                                      state.message,
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

                                if (state is QuotationsLoadedState) {
                                  if (refresh || (inSearch && !inPaging)) {
                                    // set search string and orderList
                                    searchQuery = state.query;
                                    quotationList = state.quotations.results;
                                  } else {
                                    // only merge on widget build, paging and search
                                    if (rebuild || inPaging || searchQuery != null) {
                                      hasNextPage = state.quotations.next != null;
                                      quotationList = new List.from(quotationList)..addAll(state.quotations.results);
                                      rebuild = false;
                                    }
                                  }

                                  return QuotationListWidget(
                                    quotationList: quotationList,
                                    controller: controller,
                                    fetchStatus: fetchStatus,
                                    searchQuery: searchQuery,
                                    submodel: submodel,
                                  );
                                }

                                if (state is QuotationsUnacceptedLoadedState) {
                                  if (refresh || (inSearch && !inPaging)) {
                                    // set search string and orderList
                                    searchQuery = state.query;
                                    quotationList = state.quotations.results;
                                  } else {
                                    // only merge on widget build, paging and search
                                    if (rebuild || inPaging || searchQuery != null) {
                                      hasNextPage = state.quotations.next != null;
                                      quotationList = new List.from(quotationList)..addAll(state.quotations.results);
                                      rebuild = false;
                                    }
                                  }

                                  return QuotationListWidget(
                                    quotationList: quotationList,
                                    controller: controller,
                                    fetchStatus: fetchStatus,
                                    searchQuery: searchQuery,
                                    submodel: submodel,
                                  );
                                }

                                return loadingNotice();
                              }
                          )
                      )
                  );
                }
              );
            }
        )
    );
  }
}
