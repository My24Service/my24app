import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:my24app/order/models/models.dart';

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
              Divider(),
              _createAssignedInfoSection(),
              Divider(),
              _createOrderlinesSection(),
              Divider(),
              if (!this.isCustomer)
                _createInfolinesSection(),
              if (!this.isCustomer)
                Divider(),
              _buildDocumentsSection(),
              Divider(),
              _buildWorkorderDocumentsSection(),
              Divider(),
              _createStatusSection(),
              Divider(),
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
      result = Text('orders.button_no_workorder'.tr());
    }

    return Center(child: result);
  }

  Widget _createAssignedInfoSection() {
    return buildItemsSection(
        'orders.header_assigned_users_info'.tr(),
        order.assignedUserInfo,
        (item) {
          List<Widget> items = [];

          items.add(buildItemListTile('generic.info_name'.tr(), item.fullName));
          items.add(buildItemListTile('orders.info_license_plate'.tr(), item.licensePlate));

          return items;
        },
        (item) {
          List<Widget> items = [];
          return items;
        },
        noResultsString: 'assigned_orders.detail.info_no_one_else_assigned'.tr()
    );
  }

  // order lines
  Widget _createOrderlinesSection() {
    return buildItemsSection(
      'orders.header_orderlines'.tr(),
      order.orderLines,
      (item) {
        List<Widget> items = [];

        items.add(buildItemListTile('generic.info_equipment'.tr(), item.product));
        items.add(buildItemListTile('generic.info_location'.tr(), item.location));
        items.add(buildItemListTile('generic.info_remarks'.tr(), item.remarks));

        return items;
      },
      (item) {
        List<Widget> items = [];
        return items;
      },
    );
  }

  // info lines
  Widget _createInfolinesSection() {
    return buildItemsSection(
      'orders.header_infolines'.tr(),
      order.infoLines,
      (item) {
        List<Widget> items = [];

        items.add(buildItemListTile('orders.info_infoline'.tr(), item.info));

        return items;
      },
      (item) {
        List<Widget> items = [];
        return items;
      },
    );
  }

  // documents
  Widget _buildDocumentsSection() {
    return buildItemsSection(
      'orders.header_documents'.tr(),
      order.documents,
      (item) {
        List<Widget> items = [];

        items.add(buildItemListTile('generic.info_name'.tr(), item.name));
        items.add(buildItemListTile('generic.info_description'.tr(), item.description));
        items.add(buildItemListTile('generic.info_document'.tr(), item.file.split('/').last));

        return items;
      },
      (item) {
        List<Widget> items = [];

        items.add(buildItemListViewDocumentButton(
            item,
            (item) async {
              String url = await utils.getUrl(item.url);
              launchUrl(Uri.parse(url.replaceAll('/api', '')));
            }
        ));

        return items;
      },
    );
  }

  // workorder documents
  Widget _buildWorkorderDocumentsSection() {
    return buildItemsSection(
      'orders.header_workorder_documents'.tr(),
      order.workorderDocuments,
      (item) {
        List<Widget> items = [];

        items.add(buildItemListTile('generic.info_name'.tr(), item.name));
        items.add(buildItemListTile('generic.info_document'.tr(), item.file.split('/').last));

        return items;
      },
      (item) {
        List<Widget> items = [];

        items.add(buildItemListViewDocumentButton(
            item,
            (item) async {
              String url = await utils.getUrl(item.url);
              launchUrl(Uri.parse(url.replaceAll('/api', '')));
            }
        ));

        return items;
      },
    );
  }

  Widget _createStatusSection() {
    return buildItemsSection(
        'orders.header_status_history'.tr(),
        order.statusses,
        (item) {
          List<Widget> items = [];

          items.add(buildItemListTile('generic.info_date'.tr(), item.created));
          items.add(buildItemListTile('generic.info_status'.tr(), item.status));

          return items;
        },
        (item) {
          List<Widget> items = [];
          return items;
        },
    );
  }
}
