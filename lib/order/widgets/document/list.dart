import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my24_flutter_core/utils.dart';
import 'package:my24app/common/utils.dart';

import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_core/i18n.dart';
import 'package:my24_flutter_core/widgets/slivers/base_widgets.dart';
import 'package:my24_flutter_core/models/models.dart';

import 'package:my24app/order/blocs/document_bloc.dart';
import 'package:my24app/order/models/document/models.dart';
import 'mixins.dart';

class OrderDocumentListWidget extends BaseSliverListStatelessWidget with OrderDocumentMixin {
  final OrderDocuments? orderDocuments;
  final int? orderId;
  final PaginationInfo paginationInfo;
  final String? memberPicture;
  final String? searchQuery;
  final CoreWidgets widgetsIn;
  final My24i18n i18nIn;

  OrderDocumentListWidget({
    Key? key,
    required this.orderDocuments,
    required this.orderId,
    required this.paginationInfo,
    required this.memberPicture,
    required this.searchQuery,
    required this.widgetsIn,
    required this.i18nIn,
  }) : super(
      key: key,
      paginationInfo: paginationInfo,
      memberPicture: memberPicture,
      widgets: widgetsIn,
      i18n: i18nIn
  ) {
    searchController.text = searchQuery?? '';
  }

  @override
  String getAppBarSubtitle(BuildContext context) {
    return i18nIn.$trans('app_bar_subtitle',
        namedArgs: {'count': "${orderDocuments!.count}"}
    );
  }

  @override
  SliverList getSliverList(BuildContext context) {
    return SliverList(
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            OrderDocument document = orderDocuments!.results![index];

            return Column(
              children: [
                ...widgetsIn.buildItemListKeyValueList(i18nIn.$trans('name'),
                    document.name),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    widgetsIn.createViewButton(
                        () async {
                          String url = await utils.getUrl(document.url);
                          url = url.replaceAll('/api', '');

                          Map<String, dynamic> openResult = await coreUtils.openDocument(url);
                          if (!openResult['result']) {
                            widgetsIn.createSnackBar(
                              context,
                              i18nIn.$trans('error_arg', namedArgs: {'error': openResult['message']}, pathOverride: 'generic'));
                          }
                        }
                    ),
                    SizedBox(width: 10),
                    widgetsIn.createDeleteButton(
                        () { _showDeleteDialog(context, document); }
                    ),
                    SizedBox(width: 8),
                    widgetsIn.createEditButton(
                        () => { _doEdit(context, document) }
                    )
                  ],
                ),
                if (index < orderDocuments!.results!.length-1)
                  widgetsIn.getMy24Divider(context)
              ],
            );
          },
          childCount: orderDocuments!.results!.length,
        )
    );
  }

  // private methods
  _doDelete(BuildContext context, OrderDocument document) {
    final bloc = BlocProvider.of<OrderDocumentBloc>(context);

    bloc.add(OrderDocumentEvent(status: OrderDocumentEventStatus.DO_ASYNC));
    bloc.add(OrderDocumentEvent(
        status: OrderDocumentEventStatus.DELETE,
        pk: document.id,
        orderId: orderId
    ));
  }

  _doEdit(BuildContext context, OrderDocument document) {
    final bloc = BlocProvider.of<OrderDocumentBloc>(context);

    bloc.add(OrderDocumentEvent(status: OrderDocumentEventStatus.DO_ASYNC));
    bloc.add(OrderDocumentEvent(
        status: OrderDocumentEventStatus.FETCH_DETAIL,
        pk: document.id
    ));
  }

  _showDeleteDialog(BuildContext context, OrderDocument document) {
    widgetsIn.showDeleteDialogWrapper(
        i18nIn.$trans('delete_dialog_title'),
        i18nIn.$trans('delete_dialog_content'),
        () => _doDelete(context, document),
        context
    );
  }
}
