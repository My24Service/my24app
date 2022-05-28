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
  DocumentBloc bloc = DocumentBloc();

  DocumentBloc _initialBlocCall() {
    bloc.add(DocumentEvent(status: DocumentEventStatus.DO_ASYNC));
    bloc.add(DocumentEvent(
        status: DocumentEventStatus.FETCH_ALL, orderPk: widget.orderPk));

    return bloc;
  }

  @override
  Widget build(BuildContext context) {
      return BlocConsumer(
          bloc: _initialBlocCall(),
          builder: (context, state) {
            return Scaffold(
                appBar: AppBar(
                    title: Text('orders.documents.app_bar_title'.tr())),
                body: GestureDetector(
                  onTap: () {
                    FocusScope.of(context).requestFocus(new FocusNode());
                  },
                  child: _getBody(state),
                )
            );
          },
          listener: (context, state) {
            _handleListener(context, state);
          }
      );
  }

  void _handleListener(BuildContext context, state) {
    if (state is DocumentDeletedState) {
      final DocumentBloc bloc = BlocProvider.of<DocumentBloc>(context);

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

  Widget _getBody(state) {
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
}
