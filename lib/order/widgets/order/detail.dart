import 'package:flutter/material.dart';
import 'package:my24_flutter_core/utils.dart';

import 'package:my24_flutter_core/widgets/slivers/base_widgets.dart';
import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_core/i18n.dart';

import 'package:my24app/common/utils.dart';
import 'package:my24app/order/models/order/models.dart';

class OrderDetailWidget extends BaseSliverPlainStatelessWidget {
  final OrderPageMetaData orderPageMetaData;
  final Order? order;
  final CoreWidgets widgetsIn;
  final My24i18n i18nIn = My24i18n(basePath: "orders");

  OrderDetailWidget({
    Key? key,
    required this.order,
    required this.orderPageMetaData,
    required this.widgetsIn,
  }) : super(
      key: key,
      mainMemberPicture: orderPageMetaData.memberPicture,
      widgets: widgetsIn,
      i18n: My24i18n(basePath: "orders")
  );

  @override
  String getAppBarTitle(BuildContext context) {
    return i18nIn.$trans('detail.app_bar_title');
  }

  @override
  String getAppBarSubtitle(BuildContext context) {
    return "${order!.orderId} ${order!.orderName} ${order!.orderDate}";
  }

  @override
  Widget getBottomSection(BuildContext context) {
    return SizedBox(height: 1);
  }

  @override
  Widget getContentWidget(BuildContext context) {
    return Column(
        children: [
            // createHeader(i18nIn.$trans('info_order')),
            widgetsIn.buildOrderInfoCard(context, order!),
            widgetsIn.getMy24Divider(context),
            _createAssignedInfoSection(context),
            _createOrderlinesSection(context),
            if (!this._isCustomerOrBranch())
              _createInfolinesSection(context),
            _buildDocumentsSection(context),
            _buildWorkorderDocumentsSection(context),
            _createStatusSection(context),
            _createWorkorderWidget(context),
          ]
    );
  }

  bool _isCustomerOrBranch() {
    return orderPageMetaData.submodel == 'customer_user' || orderPageMetaData.hasBranches!;
  }

  Widget _createWorkorderWidget(BuildContext context) {
    Widget result = widgetsIn.createViewWorkOrderButton(order!.workorderPdfUrl, context);

    return Center(
        child: result
    );
  }

  Widget _createAssignedInfoSection(BuildContext context) {
    return widgetsIn.buildItemsSection(
        context,
        i18nIn.$trans('header_assigned_users_info'),
        order!.assignedUserInfo,
        (item) {
          String? value = item.fullName;
          if (item.licensePlate != null && item.licensePlate != "") {
            value = "$value (${i18nIn.$trans('info_license_plate')}: ${item.licensePlate})";
          }
          return widgetsIn.buildItemListKeyValueList(i18nIn.$trans('info_name', pathOverride: 'generic'), value);
        },
        (item) {
          return <Widget>[];
        },
        noResultsString: i18nIn.$trans('info_no_one_else_assigned', pathOverride: 'assigned_orders.detail')
    );
  }

  // order lines
  Widget _createOrderlinesSection(BuildContext context) {
    return widgetsIn.buildItemsSection(
      context,
      i18nIn.$trans('header_orderlines'),
      order!.orderLines,
      (item) {
        String equipmentLocationTitle = "${i18nIn.$trans('info_equipment', pathOverride: 'generic')} / ${i18nIn.$trans('info_location', pathOverride: 'generic')}";
        String equipmentLocationValue = "${item.product?? '-'} / ${item.location?? '-'}";
        return <Widget>[
          ...widgetsIn.buildItemListKeyValueList(equipmentLocationTitle, equipmentLocationValue),
          if (item.remarks != null && item.remarks != "")
            ...widgetsIn.buildItemListKeyValueList(i18nIn.$trans('info_remarks', pathOverride: 'generic'), item.remarks)
        ];
      },
      (item) {
        return <Widget>[];
      },
    );
  }

  // info lines
  Widget _createInfolinesSection(BuildContext context) {
    return widgetsIn.buildItemsSection(
      context,
      i18nIn.$trans('header_infolines'),
      order!.infoLines,
      (item) {
        return widgetsIn.buildItemListKeyValueList(i18nIn.$trans('info_infoline'), item.info);
      },
      (item) {
        return <Widget>[];
      },
    );
  }

  // documents
  Widget _buildDocumentsSection(BuildContext context) {
    return widgetsIn.buildItemsSection(
      context,
      i18nIn.$trans('header_documents'),
      order!.documents,
      (item) {
        String nameDescKey = i18nIn.$trans('info_name', pathOverride: 'generic');
        String? nameDescValue = item.name;
        if (item.description != null && item.description != "") {
          nameDescValue = "$nameDescValue (${item.description})";
        }

        return widgetsIn.buildItemListKeyValueList(nameDescKey, nameDescValue);
      },
      (item) {
        return <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              widgetsIn.createViewButton(
                  () async {
                    String url = await utils.getUrl(item.url);
                    url = url.replaceAll('/api', '');
                    Map<String, dynamic> openResult = await coreUtils.openDocument(url);
                    if (!openResult['result']) {
                      widgetsIn.createSnackBar(
                        context,
                        i18nIn.$trans('error_arg', namedArgs: {'error': openResult['message']}, pathOverride: 'generic'));
                    }
                  }
              ),
            ],
          )
        ];
      },
    );
  }

  // workorder documents
  Widget _buildWorkorderDocumentsSection(BuildContext context) {
    return widgetsIn.buildItemsSection(
      context,
      i18nIn.$trans('header_workorder_documents'),
      order!.workorderDocuments,
      (WorkOrderDocument item) {
        return <Widget>[
          ...widgetsIn.buildItemListKeyValueList(i18nIn.$trans('info_name', pathOverride: 'generic'), item.name),
        ];
      },
      (item) {
        return <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              widgetsIn.createViewButton(
                () async {
                    String url = await utils.getUrl(item.url);
                    url = url.replaceAll('/api', '');
                    Map<String, dynamic> openResult = await coreUtils.openDocument(url);
                    if (!openResult['result']) {
                      widgetsIn.createSnackBar(
                        context,
                        i18nIn.$trans('error_arg', namedArgs: {'error': openResult['message']}, pathOverride: 'generic')
                      );
                    }
                  }
              ),
            ],
          )
        ];
      },
    );
  }

  Widget _createStatusSection(BuildContext context) {
    return widgetsIn.buildItemsSection(
        context,
        i18nIn.$trans('header_status_history'),
        order!.statuses,
        (item) {
          return <Widget>[Text("${item.created} ${item.status}")];
        },
        (item) {
          return <Widget>[];
        },
        withDivider: false
    );
  }
}
