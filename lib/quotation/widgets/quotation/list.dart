import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_core/models/models.dart';
import 'package:my24_flutter_core/widgets/slivers/base_widgets.dart';

import 'package:my24app/quotation/models/quotation/form_data.dart';
import 'package:my24app/quotation/models/quotation/models.dart';
import 'package:my24app/core/i18n_mixin.dart';
import 'package:my24app/quotation/blocs/quotation_bloc.dart';
import 'package:my24app/quotation/widgets/mixins.dart';

// ignore: must_be_immutable
class QuotationListWidget extends BaseSliverListStatelessWidget
    with i18nMixin, QuotationMixin {
  final Quotations? quotations;
  final QuotationEventStatus fetchStatus;
  final String? searchQuery;
  final String? submodel;
  final String? memberPicture;
  final PaginationInfo paginationInfo;
  final TabController tabController;
  final CoreWidgets widgetsIn;

  QuotationListWidget({
    Key? key,
    required this.quotations,
    required this.fetchStatus,
    required this.searchQuery,
    required this.paginationInfo,
    required this.memberPicture,
    required this.submodel,
    required this.tabController,
    required this.widgetsIn
  }) : super(
      key: key,
      paginationInfo: paginationInfo,
      memberPicture: memberPicture,
      widgets: widgetsIn
  );

  @override
  String getAppBarTitle(BuildContext context) {
    return 'quotations.app_bar_title'.tr();
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
              tabs: const <Widget>[
                Tab(
                  text: 'Quotation',
                ),
                Tab(
                  text: 'Preliminary quotation',
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
              onTap: () async {
                // _navDetailCustomer(context, customer.id);
              } // onTab
              ),
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
    final bloc = BlocProvider.of<QuotationBloc>(context);

    bloc.add(QuotationEvent(status: QuotationEventStatus.DO_ASYNC));
    bloc.add(QuotationEvent(
        status: QuotationEventStatus.UPDATE_FORM_DATA,
        formData: QuotationFormData.createFromModel(quotation)));
  }

  _showDeleteDialog(BuildContext context, Quotation quotation) {
    widgetsIn.showDeleteDialogWrapper(
        'quotations.delete_dialog_title'.tr(),
        'quotations.delete_dialog_content'.tr(),
        () => _doDelete(context, quotation),
        context);
  }

  Row _getButtonRow(BuildContext context, Quotation quotation) {
    Row row = Row();

    Widget deleteButton = widgetsIn.createElevatedButtonColored(
        'generic.action_delete'.tr(),
        () => _showDeleteDialog(context, quotation),
        backgroundColor: Colors.red);

    Widget acceptButton = widgetsIn.createElevatedButtonColored(
        'quotations.button_edit'.tr(), () => _doEdit(context, quotation));

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
          Text('orders.info_name'.tr(),
              style: TextStyle(fontWeight: FontWeight.bold)),
          Text('${quotation.quotationName}'),
        ]),
        TableRow(children: [
          Text('generic.info_city'.tr(),
              style: TextStyle(fontWeight: FontWeight.bold)),
          Text('${quotation.quotationCity}')
        ]),
        TableRow(children: [
          Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
          Text('${quotation.total}')
        ]),
        TableRow(children: [
          Text('Vat', style: TextStyle(fontWeight: FontWeight.bold)),
          Text('${quotation.vat}')
        ]),
        TableRow(children: [
          Text('Accepted', style: TextStyle(fontWeight: FontWeight.bold)),
          Text('${quotation.accepted}')
        ])
      ],
    );
  }

  Widget _createQuotationListSubtitle(Quotation quotation) {
    return Table(
      children: [
        TableRow(children: [
          Text('generic.info_email'.tr(),
              style: TextStyle(fontWeight: FontWeight.bold)),
          Text('${quotation.quotationEmail}')
        ]),
        TableRow(children: [
          Text('orders.info_tel'.tr(),
              style: TextStyle(fontWeight: FontWeight.bold)),
          Text('${quotation.quotationTel}')
        ]),
        TableRow(children: [
          Text('quotations.info_quotation_date'.tr(),
              style: TextStyle(fontWeight: FontWeight.bold)),
          Text('${quotation.created}')
        ])
      ],
    );
  }
}
