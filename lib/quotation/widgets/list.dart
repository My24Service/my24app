import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/quotation/models/models.dart';
import 'package:my24app/quotation/blocs/quotation_bloc.dart';

// ignore: must_be_immutable
class QuotationListWidget extends StatelessWidget {
  final ScrollController controller;
  final List<Quotation> quotationList;
  final QuotationEventStatus fetchStatus;
  final String searchQuery;
  final String submodel;

  var _searchController = TextEditingController();

  bool _inAsyncCall = false;

  QuotationListWidget({
    Key key,
    @required this.controller,
    @required this.quotationList,
    @required this.fetchStatus,
    @required this.searchQuery,
    @required this.submodel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    _searchController.text = searchQuery ?? '';

    return ModalProgressHUD(
        child: Column(
            children: [
              _showSearchRow(context),
              SizedBox(height: 20),
              Expanded(child: _buildList(context)),
            ]
        ), inAsyncCall: _inAsyncCall
    );
  }

  _doDelete(BuildContext context, Quotation quotation) async {
    final bloc = BlocProvider.of<QuotationBloc>(context);

    bloc.add(QuotationEvent(status: QuotationEventStatus.DO_ASYNC));
    bloc.add(QuotationEvent(
        status: QuotationEventStatus.DELETE, value: quotation.id));
  }

  _doAccept(BuildContext context, Quotation quotation) async {
    final bloc = BlocProvider.of<QuotationBloc>(context);

    bloc.add(QuotationEvent(status: QuotationEventStatus.DO_ASYNC));
    bloc.add(QuotationEvent(
        status: QuotationEventStatus.ACCEPT, value: quotation.id));
  }

  _showDeleteDialog(BuildContext context, Quotation quotation) {
    showDeleteDialogWrapper(
        'quotations.delete_dialog_title'.tr(),
        'quotations.delete_dialog_content'.tr(),
        () => _doDelete(context, quotation));
  }

  Row _showSearchRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(width: 220, child:
        TextField(
          controller: _searchController,
        ),
        ),
        createElevatedButtonColored(
            'generic.action_search'.tr(),
                () => _doSearch(context, _searchController.text)
        ),
      ],
    );
  }

  Row _getButtonRow(BuildContext context, Quotation quotation) {
    Row row;

    Widget deleteButton = createElevatedButtonColored(
        'generic.action_delete'.tr(),
        () => _showDeleteDialog(context, quotation),
        foregroundColor: Colors.red);

    Widget acceptButton = createElevatedButtonColored(
        'quotations.button_accept'.tr(),
        () => _doAccept(context, quotation));

    if (fetchStatus == QuotationEventStatus.FETCH_UNACCEPTED) {
      if (submodel == 'engineer') {
        row = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            deleteButton
          ],
        );
      }

      if (submodel == 'planning_user') {
        row = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            acceptButton,
            SizedBox(width: 10),
            deleteButton
          ],
        );
      }

      if (submodel == 'customer_user') {
        row = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            deleteButton
          ],
          );
      }
    } else {
      row = Row();
    }

    return row;
  }

  _doSearch(BuildContext context, String query) async {
    final bloc = BlocProvider.of<QuotationBloc>(context);

    controller.animateTo(
      controller.position.minScrollExtent,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 10),
    );

    await Future.delayed(Duration(milliseconds: 100));

    bloc.add(QuotationEvent(status: QuotationEventStatus.DO_ASYNC));
    bloc.add(QuotationEvent(status: QuotationEventStatus.DO_SEARCH));
    bloc.add(QuotationEvent(status: fetchStatus, query: query));

  }

  doRefresh(BuildContext context) {
    final bloc = BlocProvider.of<QuotationBloc>(context);

    bloc.add(QuotationEvent(status: QuotationEventStatus.DO_REFRESH));
    bloc.add(QuotationEvent(status: fetchStatus));
  }

  Widget _buildList(BuildContext context) {
    return RefreshIndicator(
      child: ListView.builder(
          controller: controller,
          key: PageStorageKey<String>('quotationList'),
          scrollDirection: Axis.vertical,
          physics: AlwaysScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: EdgeInsets.all(8),
          itemCount: quotationList.length,
          itemBuilder: (BuildContext context, int index) {
            Quotation quotation = quotationList[index];

            return Column(
              children: [
                ListTile(
                    title: createQuotationListHeader(quotation),
                    subtitle: createQuotationListSubtitle(quotation),
                    onTap: () async {
                      // navigate to detail page
                      // final page = OrderInfoPage(orderPk: order.id);
                      //
                      // Navigator.push(context,
                      //     MaterialPageRoute(
                      //         builder: (context) => page)
                      // );
                    } // onTab
                ),
                SizedBox(height: 10),
                _getButtonRow(context, quotation),
                SizedBox(height: 10)
              ],
            );
          } // itemBuilder
      ),
      onRefresh: () async {
        Future.delayed(
            Duration(milliseconds: 5),
                () {
              doRefresh(context);
            });
      },
    );
  }

  Widget createQuotationListHeader(Quotation quotation) {
    return Table(
      children: [
        TableRow(
            children: [
              Text('quotations.info_quotation_date'.tr(), style: TextStyle(fontWeight: FontWeight.bold)),
              Text('${quotation.created}')
            ]
        ),
        TableRow(
            children: [
              Text('generic.info_email'.tr(), style: TextStyle(fontWeight: FontWeight.bold)),
              Text('${quotation.quotationEmail}')
            ]
        ),
        TableRow(
            children: [
              Text('orders.info_tel'.tr(), style: TextStyle(fontWeight: FontWeight.bold)),
              Text('${quotation.quotationTel}')
            ]
        ),
        TableRow(
            children: [
              SizedBox(height: 10),
              Text(''),
            ]
        )
      ],
    );
  }

  Widget createQuotationListSubtitle(Quotation quotation) {
    return Table(
      children: [
        TableRow(
            children: [
              Text('orders.info_name'.tr(), style: TextStyle(fontWeight: FontWeight.bold)),
              Text('${quotation.quotationName}'),
            ]
        ),
        TableRow(
            children: [
              Text('orders.info_postal'.tr(), style: TextStyle(fontWeight: FontWeight.bold)),
              Text('${quotation.quotationPostal}'),
            ]
        ),
        TableRow(
            children: [
              Text('generic.info_city'.tr(), style: TextStyle(fontWeight: FontWeight.bold)),
              Text('${quotation.quotationCity}')
            ]
        )
      ],
    );
  }
}
