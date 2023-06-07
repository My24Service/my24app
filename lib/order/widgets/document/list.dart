import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my24app/core/utils.dart';

import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/order/blocs/document_bloc.dart';
import 'package:my24app/core/widgets/slivers/base_widgets.dart';
import 'package:my24app/order/models/document/models.dart';
import 'package:my24app/core/models/models.dart';
import 'package:my24app/core/i18n_mixin.dart';
import 'mixins.dart';


class OrderDocumentListWidget extends BaseSliverListStatelessWidget with OrderDocumentMixin, i18nMixin {
  final String basePath = "orders.documents";
  final OrderDocuments? orderDocuments;
  final int? orderId;
  final PaginationInfo paginationInfo;
  final String? memberPicture;
  final String? searchQuery;

  OrderDocumentListWidget({
    Key? key,
    required this.orderDocuments,
    required this.orderId,
    required this.paginationInfo,
    required this.memberPicture,
    required this.searchQuery
  }) : super(
      key: key,
      paginationInfo: paginationInfo,
      memberPicture: memberPicture
  ) {
    searchController.text = searchQuery?? '';
  }

  @override
  String getAppBarSubtitle(BuildContext context) {
    return $trans('app_bar_subtitle',
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
                ...buildItemListKeyValueList($trans('name'),
                    document.name),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    createViewButton(
                        () async {
                          String url = await utils.getUrl(document.url);
                          url = url.replaceAll('/api', '');

                          Map<String, dynamic> openResult = await utils.openDocument(url);
                          if (!openResult['result']) {
                            createSnackBar(
                              context,
                              $trans('error_arg', namedArgs: {'error': openResult['message']}, pathOverride: 'generic'));
                          }
                        }
                    ),
                    SizedBox(width: 10),
                    createDeleteButton(
                        $trans("button_delete"),
                        () { _showDeleteDialog(context, document); }
                    ),
                    SizedBox(width: 8),
                    createEditButton(
                        () => { _doEdit(context, document) }
                    )
                  ],
                ),
                if (index < orderDocuments!.results!.length-1)
                  getMy24Divider(context)
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
    showDeleteDialogWrapper(
        $trans('delete_dialog_title'),
        $trans('delete_dialog_content'),
        () => _doDelete(context, document),
        context
    );
  }
}
