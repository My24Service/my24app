import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:my24app/order/models/order/models.dart';

import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/core/utils.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderInfoWidget extends StatelessWidget {
  final Order order;
  final bool isCustomer;

  OrderInfoWidget({
    Key key,
    @required this.order,
    @required this.isCustomer,
  }): super(key: key);

  @override
  Widget build(BuildContext context) {
    return _showMainView(context);
  }

  Widget _showMainView(BuildContext context) {
    return Align(
        alignment: Alignment.topRight,
        child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              createHeader('orders.info_order'.tr()),
              buildOrderInfoCard(context, order),
              getMy24Divider(context),
              _createAssignedInfoSection(context),
              _createOrderlinesSection(context),
              if (!this.isCustomer)
                _createInfolinesSection(context),
              _buildDocumentsSection(context),
              _buildWorkorderDocumentsSection(context),
              _createStatusSection(context),
              getMy24Divider(context),
              _createWorkorderWidget(),
            ]
        )
    );
  }

  Widget _createWorkorderWidget() {
    Widget result;

    if(order.workorderPdfUrl != null && order.workorderPdfUrl != '') {
      result = createElevatedButtonColored(
        'orders.button_open_workorder'.tr(),
        () => utils.launchURL(order.workorderPdfUrl)
      );
    } else {
      result = Text('orders.button_no_workorder'.tr(),
          style: TextStyle(
            fontSize: 18,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.bold
          ),
      );
    }

    return Center(
        child: result
    );
  }

  Widget _createAssignedInfoSection(BuildContext context) {
    return buildItemsSection(
        context,
        'orders.header_assigned_users_info'.tr(),
        order.assignedUserInfo,
        (item) {
          String value = item.fullName;
          if (item.licensePlate != null && item.licensePlate != "") {
            value = "$value (${'orders.info_license_plate'.tr()}: ${item.licensePlate})";
          }
          return buildItemListKeyValueList('generic.info_name'.tr(), value);
        },
        (item) {
          return <Widget>[];
        },
        noResultsString: 'assigned_orders.detail.info_no_one_else_assigned'.tr()
    );
  }

  // order lines
  Widget _createOrderlinesSection(BuildContext context) {
    return buildItemsSection(
      context,
      'orders.header_orderlines'.tr(),
      order.orderLines,
      (item) {
        String equipmentLocationTitle = "${'generic.info_equipment'.tr()} / ${'generic.info_location'.tr()}";
        String equipmentLocationValue = "${item.product?? '-'} / ${item.location?? '-'}";
        return <Widget>[
          ...buildItemListKeyValueList(equipmentLocationTitle, equipmentLocationValue),
          if (item.remarks != null && item.remarks != "")
            ...buildItemListKeyValueList('generic.info_remarks'.tr(), item.remarks)
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
      'orders.header_infolines'.tr(),
      order.infoLines,
      (item) {
        return buildItemListKeyValueList('orders.info_infoline'.tr(), item.info);
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
      'orders.header_documents'.tr(),
      order.documents,
      (item) {
        String nameDescKey = "${'generic.info_name'.tr()}";
        String nameDescValue = item.name;
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
                  launchUrl(Uri.parse(url.replaceAll('/api', '')));
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
      'orders.header_workorder_documents'.tr(),
      order.workorderDocuments,
      (item) {
        return <Widget>[
          ...buildItemListKeyValueList('generic.info_name'.tr(), item.name),
          ...buildItemListKeyValueList('generic.info_document'.tr(), item.file.split('/').last),
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
                  launchUrl(Uri.parse(url.replaceAll('/api', '')));
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
        'orders.header_status_history'.tr(),
        order.statuses,
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
