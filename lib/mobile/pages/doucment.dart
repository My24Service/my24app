import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/mobile/blocs/document_bloc.dart';
import 'package:my24app/mobile/blocs/document_states.dart';
import 'package:my24app/mobile/widgets/document.dart';


class DocumentPage extends StatefulWidget {
  final int assignedOrderPk;

  DocumentPage({
    Key key,
    this.assignedOrderPk
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _DocumentPageState();
}

class _DocumentPageState extends State<DocumentPage> {
  DocumentBloc bloc = DocumentBloc();

  @override
  Widget build(BuildContext context) {
    _initalBlocCall() {
      final bloc = DocumentBloc();
      bloc.add(DocumentEvent(status: DocumentEventStatus.DO_ASYNC));
      bloc.add(DocumentEvent(
          status: DocumentEventStatus.FETCH_ALL,
          value: widget.assignedOrderPk
      ));

      return bloc;
    }

    return BlocProvider(
        create: (BuildContext context) => _initalBlocCall(),
        child: Scaffold(
            appBar: AppBar(
              title: new Text('assigned_orders.documents.app_bar_title'.tr()),
            ),
            body: GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(FocusNode());
              },
              child: BlocListener<DocumentBloc, DocumentState>(
                listener: (context, state) async {
                  if (state is DocumentInsertedState) {
                    createSnackBar(context, 'generic.snackbar_added_document'.tr());

                    bloc.add(DocumentEvent(
                        status: DocumentEventStatus.FETCH_ALL,
                        value: widget.assignedOrderPk
                    ));
                  }

                  if (state is DocumentDeletedState) {
                    if (state.result == true) {
                      createSnackBar(context, 'generic.snackbar_deleted_document'.tr());

                      bloc.add(DocumentEvent(
                          status: DocumentEventStatus.FETCH_ALL,
                          value: widget.assignedOrderPk
                      ));

                      setState(() {});
                    } else {
                      displayDialog(context,
                          'generic.error_dialog_title'.tr(),
                          'assigned_orders.documents.error_dialog_content_delete'.tr()
                      );
                      setState(() {});
                    }
                  }
                },
                child: BlocBuilder<DocumentBloc, DocumentState>(
                    builder: (context, state) {
                      bloc = BlocProvider.of<DocumentBloc>(context);

                      if (state is DocumentInitialState) {
                        return loadingNotice();
                      }

                      if (state is DocumentLoadingState) {
                        return loadingNotice();
                      }

                      if (state is DocumentErrorState) {
                        return errorNotice(state.message);
                      }

                      if (state is DocumentsLoadedState) {
                        return DocumentWidget(
                            documents: state.documents,
                            assignedOrderPk: widget.assignedOrderPk,
                        );
                      }

                      return loadingNotice();
                    }
                )
            )
          )
        )
    );
  }
}
