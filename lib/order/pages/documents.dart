import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/order/blocs/document_bloc.dart';
import 'package:my24app/order/blocs/document_states.dart';
import 'package:my24app/order/widgets/document_list.dart';
import 'package:my24app/core/widgets/widgets.dart';

class OrderDocumentsPage extends StatefulWidget {
  final dynamic orderPk;

  OrderDocumentsPage({
    Key key,
    @required this.orderPk,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _OrderDocumentsPageState();
}

class _OrderDocumentsPageState extends State<OrderDocumentsPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (BuildContext context) => DocumentBloc(DocumentInitialState()),
        child: Builder(
            builder: (BuildContext context) {
              final DocumentBloc bloc = BlocProvider.of<DocumentBloc>(context);

              bloc.add(DocumentEvent(status: DocumentEventStatus.DO_FETCH));
              bloc.add(DocumentEvent(
                  status: DocumentEventStatus.FETCH_ALL, orderPk: widget.orderPk));

              return Scaffold(
                  appBar: AppBar(
                      title: Text('orders.documents.app_bar_title'.tr())),
                  body: GestureDetector(
                    onTap: () {
                      FocusScope.of(context).requestFocus(new FocusNode());
                    },
                    child:_getBody(bloc),
                  )
              );
            }
        )
    );
  }

  Widget _getBody(DocumentBloc bloc) {
    return BlocListener<DocumentBloc, DocumentState>(
        listener: (context, state) {
          if (state is DocumentInsertedState) {
            if(state.document != null) {
              createSnackBar(context, 'generic.snackbar_added_document'.tr());

              bloc.add(DocumentEvent(
                  status: DocumentEventStatus.DO_FETCH));
              bloc.add(DocumentEvent(
                  status: DocumentEventStatus.FETCH_ALL,
                  orderPk: widget.orderPk));
            } else {
              displayDialog(context,
                  'generic.error_dialog_title'.tr(),
                  'generic.error_adding_document'.tr()
              );
            }
          }

          if (state is DocumentDeletedState) {
            if (state.result == true) {
              createSnackBar(context, 'generic.snackbar_deleted_document'.tr());

              bloc.add(DocumentEvent(
                  status: DocumentEventStatus.DO_FETCH));
              bloc.add(DocumentEvent(
                  status: DocumentEventStatus.FETCH_ALL,
                  orderPk: widget.orderPk));
            } else {
              displayDialog(context,
                  'generic.error_dialog_title'.tr(),
                  'orders.documents.error_dialog_content_delete'.tr()
              );
            }
          }
        },
        child: BlocBuilder<DocumentBloc, DocumentState>(
            builder: (context, state) {
              if (state is DocumentInitialState) {
                return loadingNotice();
              }

              if (state is DocumentLoadingState) {
                return loadingNotice();
              }

              if (state is DocumentErrorState) {
                return errorNoticeWithReload(
                    state.message,
                    bloc,
                    DocumentEvent(
                        status: DocumentEventStatus.FETCH_ALL,
                        orderPk: widget.orderPk
                    )
                );
              }

              if (state is DocumentsLoadedState) {
                return DocumentListWidget(documents: state.documents, orderPk: widget.orderPk);
              }

              return loadingNotice();
            }
        )
    );
  }
}
