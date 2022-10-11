import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/core/utils.dart';
import 'package:my24app/quotation/blocs/line_bloc.dart';
import 'package:my24app/quotation/blocs/line_states.dart';
import 'package:my24app/quotation/pages/part_form.dart';
import 'package:my24app/quotation/widgets/line_form.dart';
import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/core/widgets/drawers.dart';

class PartLineFormPage extends StatefulWidget {
  final int quotationPk;
  final int quotationPartPk;
  final int partLinePk;

  PartLineFormPage({
    Key key,
    this.quotationPk,
    this.quotationPartPk,
    this.partLinePk,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _PartLineFormPageState();
}

class _PartLineFormPageState extends State<PartLineFormPage> {
  bool firstTime = true;
  bool isEdit = false;

  PartLineBloc _initialBlocCall(int pk) {
    PartLineBloc bloc = PartLineBloc();

    if (pk != null) {
      bloc.add(PartLineEvent(status: PartLineEventStatus.DO_ASYNC));
      bloc.add(PartLineEvent(
          status: PartLineEventStatus.FETCH_DETAIL, pk: pk));
    } else {
      bloc.add(PartLineEvent(status: PartLineEventStatus.NEW));
    }

    return bloc;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => _initialBlocCall(widget.partLinePk),
        child: FutureBuilder<String>(
              future: utils.getUserSubmodel(),
              builder: (ctx, snapshot) {
                if (!snapshot.hasData) {
                  return Scaffold(
                      appBar: AppBar(title: Text('')),
                      body: Container()
                  );
                }

                return BlocConsumer<PartLineBloc, PartLineState>(
                    listener: (context, state) {
                      _listeners(context, state);
                    },
                    builder: (context, state) {
                      return Scaffold(
                        appBar: AppBar(title: Text(
                            'quotations.part_lines.app_bar_title'.tr())
                        ),
                        body: GestureDetector(
                            onTap: () {
                              FocusScope.of(context).requestFocus(
                                  new FocusNode());
                            },
                            child: _getBody(context, state)
                        )
                    );
                  }
                );
            }
        )
    );
  }

  _listeners(BuildContext context, state) {
    if (state is PartLineDeletedState) {
      if (state.result) {
        createSnackBar(context, 'quotations.part_lines.snackbar_deleted'.tr());

        final page = PartFormPage(
            quotationPk: widget.quotationPk,
            quotationPartPk: widget.quotationPartPk
        );

        Navigator.pop(context);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => page)
        );
      } else {
        displayDialog(context,
            'generic.error_dialog_title'.tr(),
            'quotations.part_lines.error_deleting_dialog_content'.tr()
        );
      }
    }

    if (state is PartLineInsertedState) {
      if (state.line != null) {
        createSnackBar(context, 'quotations.part_lines.snackbar_created'.tr());

        final page = PartFormPage(
            quotationPk: widget.quotationPk,
            quotationPartPk: widget.quotationPartPk
        );

        Navigator.pop(context);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => page)
        );
      } else {
        displayDialog(context,
            'generic.error_dialog_title'.tr(),
            'quotations.part_lines.error_inserting_dialog_content'.tr()
        );
      }
    }

    if (state is PartLineEditedState) {
      if (state.result) {
        createSnackBar(context, 'quotations.part_lines.snackbar_updated'.tr());

        final page = PartFormPage(
            quotationPk: widget.quotationPk,
            quotationPartPk: widget.quotationPartPk
        );

        Navigator.pop(context);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => page)
        );
      } else {
        displayDialog(context,
            'generic.error_dialog_title'.tr(),
            'quotations.part_lines.error_updating_dialog_content'.tr()
        );
      }
    }
  }

  Widget _getBody(BuildContext context, state) {
    final PartLineBloc bloc = BlocProvider.of<PartLineBloc>(context);

    if (state is PartLineErrorState) {
      return errorNoticeWithReload(
          state.message,
          bloc,
          PartLineEvent(
              status: PartLineEventStatus.FETCH_DETAIL,
              pk: widget.partLinePk
          )
      );
    }

    if (state is PartLineNewState) {
      return PartLineFormWidget(
        quotationPk: widget.quotationPk,
        quotatonPartId: widget.quotationPartPk,
      );
    }

    if (state is PartLineLoadedState) {
      return PartLineFormWidget(
        line: state.line,
        quotationPk: widget.quotationPk,
        quotatonPartId: widget.quotationPartPk,
      );
    }

    return loadingNotice();
  }
}
