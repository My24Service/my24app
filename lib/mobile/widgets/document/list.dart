import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_core/i18n.dart';
import 'package:my24_flutter_core/widgets/slivers/base_widgets.dart';
import 'package:my24_flutter_core/models/models.dart';

import 'package:my24app/mobile/blocs/document_bloc.dart';
import 'package:my24app/mobile/models/document/models.dart';
import 'mixins.dart';

class DocumentListWidget extends BaseSliverListStatelessWidget with DocumentMixin {
  final AssignedOrderDocuments? documents;
  final int? assignedOrderId;
  final PaginationInfo paginationInfo;
  final String? memberPicture;
  final String? searchQuery;
  final CoreWidgets widgetsIn;
  final My24i18n i18nIn;

  DocumentListWidget({
    Key? key,
    required this.documents,
    required this.assignedOrderId,
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
      namedArgs: {'count': "${documents!.count}"}
    );
  }

  @override
  SliverList getSliverList(BuildContext context) {
    return SliverList(
        delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              AssignedOrderDocument document = documents!.results![index];
              String? value = document.name;
              if (document.description != null && document.description != "") {
                value = "$value (${document.description})";
              }

              return Column(
                children: [
                  SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _createColumnItem(My24i18n.tr('generic.info_document'), value),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      widgetsIn.createDeleteButton(
                        () { _showDeleteDialog(context, document); }
                      ),
                      SizedBox(width: 8),
                      widgetsIn.createEditButton(
                        () => { _doEdit(context, document) }
                      )
                    ],
                  ),
                  if (index < documents!.results!.length-1)
                    widgetsIn.getMy24Divider(context)
                ],
              );
            },
            childCount: documents!.results!.length,
        )
    );
  }

  // private methods
  Widget _createColumnItem(String key, String? val) {
    double width = 160;
    return Container(
      alignment: AlignmentDirectional.topStart,
      width: width,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: widgetsIn.buildItemListKeyValueList(key, val)
      ),
    );
  }

  _doDelete(BuildContext context, AssignedOrderDocument document) {
    final bloc = BlocProvider.of<DocumentBloc>(context);

    bloc.add(DocumentEvent(status: DocumentEventStatus.DO_ASYNC));
    bloc.add(DocumentEvent(
        status: DocumentEventStatus.DELETE,
        pk: document.id,
        assignedOrderId: assignedOrderId
    ));
  }

  _doEdit(BuildContext context, AssignedOrderDocument document) {
    final bloc = BlocProvider.of<DocumentBloc>(context);

    bloc.add(DocumentEvent(status: DocumentEventStatus.DO_ASYNC));
    bloc.add(DocumentEvent(
        status: DocumentEventStatus.FETCH_DETAIL,
        pk: document.id
    ));
  }

  _showDeleteDialog(BuildContext context, AssignedOrderDocument document) {
    widgetsIn.showDeleteDialogWrapper(
       i18nIn.$trans('delete_dialog_title'),
       i18nIn.$trans('delete_dialog_content'),
      () => _doDelete(context, document),
      context
    );
  }
}
