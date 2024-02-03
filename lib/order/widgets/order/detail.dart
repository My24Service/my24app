import 'package:flutter/material.dart';

import 'package:my24_flutter_core/widgets/slivers/base_widgets.dart';
import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24app/core/utils.dart';
import 'package:my24app/core/i18n_mixin.dart';
import 'package:my24app/order/models/order/models.dart';

class OrderDetailWidget extends BaseSliverPlainStatelessWidget with i18nMixin {
  final String basePath = "orders";
  final OrderPageMetaData orderPageMetaData;
  final Order? order;

  OrderDetailWidget({
    Key? key,
    required this.order,
    required this.orderPageMetaData,
  }) : super(
      key: key,
      memberPicture: orderPageMetaData.memberPicture
  );

  @override
  String getAppBarTitle(BuildContext context) {
    return $trans('detail.app_bar_title');
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
            // createHeader($trans('info_order')),
            buildOrderInfoCard(context, order!),
            getMy24Divider(context),
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
    Widget result = createViewWorkOrderButton(order!.workorderPdfUrl, context);

    return Center(
        child: result
    );
  }

  Widget _createAssignedInfoSection(BuildContext context) {
    return buildItemsSection(
        context,
        $trans('header_assigned_users_info'),
        order!.assignedUserInfo,
        (item) {
          String? value = item.fullName;
          if (item.licensePlate != null && item.licensePlate != "") {
            value = "$value (${$trans('info_license_plate')}: ${item.licensePlate})";
          }
          return buildItemListKeyValueList($trans('info_name', pathOverride: 'generic'), value);
        },
        (item) {
          return <Widget>[];
        },
        noResultsString: $trans('info_no_one_else_assigned', pathOverride: 'assigned_orders.detail')
    );
  }

  // order lines
  Widget _createOrderlinesSection(BuildContext context) {
    return buildItemsSection(
      context,
      $trans('header_orderlines'),
      order!.orderLines,
      (item) {
        String equipmentLocationTitle = "${$trans('info_equipment', pathOverride: 'generic')} / ${$trans('info_location', pathOverride: 'generic')}";
        String equipmentLocationValue = "${item.product?? '-'} / ${item.location?? '-'}";
        return <Widget>[
          ...buildItemListKeyValueList(equipmentLocationTitle, equipmentLocationValue),
          if (item.remarks != null && item.remarks != "")
            ...buildItemListKeyValueList($trans('info_remarks', pathOverride: 'generic'), item.remarks)
        ];
      },
      (item) {
        return <Widget>[];
      },
    );
  }

  // info lines
  Widget _createInfolinesSection(BuildContext context) {
    return buildItemsSection(
      context,
      $trans('header_infolines'),
      order!.infoLines,
      (item) {
        return buildItemListKeyValueList($trans('info_infoline'), item.info);
      },
      (item) {
        return <Widget>[];
      },
    );
  }

  // documents
  Widget _buildDocumentsSection(BuildContext context) {
    return buildItemsSection(
      context,
      $trans('header_documents'),
      order!.documents,
      (item) {
        String nameDescKey = $trans('info_name', pathOverride: 'generic');
        String? nameDescValue = item.name;
        if (item.description != null && item.description != "") {
          nameDescValue = "$nameDescValue (${item.description})";
        }

        return buildItemListKeyValueList(nameDescKey, nameDescValue);
      },
      (item) {
        return <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              createViewButton(
                  () async {
                    String url = await utils.getUrl(item.url);
                    url = url.replaceAll('/api', '');
                    Map<String, dynamic> openResult = await utils.openDocument(url);
                    if (!openResult['result']) {
                      createSnackBar(
                        context,
                        $trans('error_arg', namedArgs: {'error': openResult['message']}, pathOverride: 'generic'));
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
    return buildItemsSection(
      context,
      $trans('header_workorder_documents'),
      order!.workorderDocuments,
      (WorkOrderDocument item) {
        return <Widget>[
          ...buildItemListKeyValueList($trans('info_name', pathOverride: 'generic'), item.name),
        ];
      },
      (item) {
        return <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              createViewButton(
                () async {
                    String url = await utils.getUrl(item.url);
                    url = url.replaceAll('/api', '');
                    Map<String, dynamic> openResult = await utils.openDocument(url);
                    if (!openResult['result']) {
                      createSnackBar(
                        context,
                        $trans('error_arg', namedArgs: {'error': openResult['message']}, pathOverride: 'generic')
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
    return buildItemsSection(
        context,
        $trans('header_status_history'),
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
