import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_core/i18n.dart';
import 'package:my24_flutter_core/models/models.dart';
import 'package:my24_flutter_core/widgets/slivers/base_widgets.dart';

import 'package:my24app/quotation/models/quotation/form_data.dart';
import 'package:my24app/quotation/models/quotation/models.dart';
import 'package:my24app/quotation/blocs/quotation_bloc.dart';
import 'package:my24app/quotation/widgets/mixins.dart';
import 'package:my24app/quotation/pages/form.dart';

class QuotationListWidget extends BaseSliverListStatelessWidget
    with QuotationMixin {
  final Quotations? quotations;
  final QuotationEventStatus fetchStatus;
  final String? searchQuery;
  final String? submodel;
  final String? memberPicture;
  final PaginationInfo paginationInfo;
  final TabController tabController;
  final CoreWidgets widgetsIn;
  final My24i18n i18nIn;

  QuotationListWidget({
    Key? key,
    required this.quotations,
    required this.fetchStatus,
    required this.searchQuery,
    required this.paginationInfo,
    required this.memberPicture,
    required this.submodel,
    required this.tabController,
    required this.widgetsIn,
    required this.i18nIn,
  }) : super(
            key: key,
            paginationInfo: paginationInfo,
            memberPicture: memberPicture,
            widgets: widgetsIn,
            i18n: i18nIn);

  @override
  String getAppBarTitle(BuildContext context) {
    return i18nIn.$trans('app_bar_subtitle',
        namedArgs: {'count': "${paginationInfo.count}"});
  }

  @override
  SliverPersistentHeader makeTabHeader(BuildContext context) {
    return SliverPersistentHeader(
        pinned: true,
        delegate: SliverAppBarDelegate(
          minHeight: 30.0,
          maxHeight: 30.0,
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: tabController,
              tabs: <Widget>[
                Tab(
                  text: i18nIn.$trans('tab_quotations'),
                ),
                Tab(
                  text: i18nIn.$trans('tab_preliminary'),
                )
              ],
              onTap: (int value) {
                if (value == 0) {
                  doRefresh(context);
                } else {
                  _loadPreliminaryQuotations(context);
                }
              },
            ),
          ),
        ));
  }

  @override
  SliverList getSliverList(BuildContext context) {
    return SliverList(
        delegate: SliverChildBuilderDelegate(
      (BuildContext context, int index) {
        Quotation quotation = quotations!.results![index];

        return Column(children: [
          ListTile(
              title: _createQuotationListHeader(quotation),
              subtitle: _createQuotationListSubtitle(quotation),
              onTap: () {
                _doEdit(context, quotation);
              }),
          SizedBox(height: 10),
          _getButtonRow(context, quotation),
          SizedBox(height: 10)
        ]);
      },
      childCount: quotations!.results!.length,
    ));
  }

  _loadPreliminaryQuotations(BuildContext context) {
    final bloc = BlocProvider.of<QuotationBloc>(context);

    bloc.add(QuotationEvent(status: QuotationEventStatus.DO_ASYNC));
    bloc.add(QuotationEvent(status: QuotationEventStatus.FETCH_PRELIMINARY));
  }

  doRefresh(BuildContext context) {
    final bloc = BlocProvider.of<QuotationBloc>(context);

    bloc.add(QuotationEvent(status: QuotationEventStatus.DO_REFRESH));
    bloc.add(QuotationEvent(status: QuotationEventStatus.FETCH_ALL));
  }

  _doDelete(BuildContext context, Quotation quotation) async {
    final bloc = BlocProvider.of<QuotationBloc>(context);

    bloc.add(QuotationEvent(status: QuotationEventStatus.DO_ASYNC));
    bloc.add(
        QuotationEvent(status: QuotationEventStatus.DELETE, pk: quotation.id));
  }

  _doEdit(BuildContext context, Quotation quotation) async {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => QuotationForm(
                  memberPicture: memberPicture,
                  formData: QuotationFormData.createFromModel(quotation),
                  fetchStatus: fetchStatus,
                  widgetsIn: widgets,
                  i18nIn: i18nIn,
                )));
  }

  _showDeleteDialog(BuildContext context, Quotation quotation) {
    widgetsIn.showDeleteDialogWrapper(
        i18nIn.$trans('delete_dialog_title'),
        i18nIn.$trans('delete_dialog_content'),
        () => _doDelete(context, quotation),
        context);
  }

  Row _getButtonRow(BuildContext context, Quotation quotation) {
    Row row = Row();

    Widget deleteButton = widgetsIn.createDeleteButton(
      () => _showDeleteDialog(context, quotation),
    );

    Widget acceptButton = widgetsIn.createElevatedButtonColored(
        i18nIn.$trans('button_accept'), () => _doEdit(context, quotation));

    if (submodel == 'engineer') {
      row = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [deleteButton],
      );
    } else if (submodel == 'planning_user' || submodel == 'sales_user') {
      row = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [acceptButton, SizedBox(width: 10), deleteButton],
      );
    } else if (submodel == 'customer_user') {
      row = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [deleteButton],
      );
    }

    return row;
  }

  Widget _createQuotationListHeader(Quotation quotation) {
    return Table(
      children: [
        TableRow(children: [
          Text(My24i18n.tr('generic.info_name'),
              style: TextStyle(fontWeight: FontWeight.bold)),
          Text('${quotation.quotationName}'),
        ]),
        TableRow(children: [
          Text(My24i18n.tr('generic.info_city'),
              style: TextStyle(fontWeight: FontWeight.bold)),
          Text('${quotation.quotationCity}')
        ]),
        TableRow(children: [
          Text(i18nIn.$trans('info_total'),
              style: TextStyle(fontWeight: FontWeight.bold)),
          Text('${quotation.total}')
        ]),
        TableRow(children: [
          Text(i18nIn.$trans('info_vat'),
              style: TextStyle(fontWeight: FontWeight.bold)),
          Text('${quotation.vat}')
        ]),
        TableRow(children: [
          Text(i18nIn.$trans('info_accepted'),
              style: TextStyle(fontWeight: FontWeight.bold)),
          Text('${quotation.accepted}')
        ])
      ],
    );
  }

  Widget _createQuotationListSubtitle(Quotation quotation) {
    return Table(
      children: [
        TableRow(children: [
          Text(My24i18n.tr('generic.info_email'),
              style: TextStyle(fontWeight: FontWeight.bold)),
          Text('${quotation.quotationEmail}')
        ]),
        TableRow(children: [
          Text(My24i18n.tr('generic.info_tel'),
              style: TextStyle(fontWeight: FontWeight.bold)),
          Text('${quotation.quotationTel}')
        ]),
        TableRow(children: [
          Text(i18nIn.$trans('info_quotation_date'),
              style: TextStyle(fontWeight: FontWeight.bold)),
          Text('${quotation.created}')
        ])
      ],
    );
  }
}
