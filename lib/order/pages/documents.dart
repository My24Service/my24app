import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/order/blocs/document_bloc.dart';
import 'package:my24app/order/blocs/document_states.dart';
import 'package:my24app/order/widgets/documents.dart';
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
  bool firstTime = true;

  DocumentBloc _initialBlocCall() {
    DocumentBloc bloc = DocumentBloc();

    if (firstTime) {
      bloc.add(DocumentEvent(status: DocumentEventStatus.DO_ASYNC));
      bloc.add(DocumentEvent(
          status: DocumentEventStatus.FETCH_ALL, orderPk: widget.orderPk));

      firstTime = false;
    }

    return bloc;
  }

  @override
  Widget build(BuildContext context) {
      return BlocProvider(
          create: (context) => _initialBlocCall(),
          child: BlocConsumer<DocumentBloc, DocumentState>(
            builder: (context, state) {
              return Scaffold(
                  appBar: AppBar(
                      title: Text('orders.documents.app_bar_title'.tr())),
                  body: GestureDetector(
                    onTap: () {
                      FocusScope.of(context).requestFocus(new FocusNode());
                    },
                    child: _getBody(context, state),
                  )
              );
            },
            listener: (context, state) {
              _handleListener(context, state);
            }
        )
      );
  }

  void _handleListener(BuildContext context, state) {
    final bloc = BlocProvider.of<DocumentBloc>(context);

    if (state is DocumentDeletedState) {
      if (state.result == true) {
        createSnackBar(
            context, 'generic.snackbar_deleted_document'.tr());

        bloc.add(DocumentEvent(
            status: DocumentEventStatus.DO_ASYNC));
        bloc.add(DocumentEvent(
            status: DocumentEventStatus.FETCH_ALL,
            orderPk: widget.orderPk));

        setState(() {});
      } else {
        displayDialog(context,
            'generic.error_dialog_title'.tr(),
            'orders.documents.error_dialog_content_delete'.tr()
        );
      }
    }
  }

  Widget _getBody(context, state) {
    final bloc = BlocProvider.of<DocumentBloc>(context);

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
}
