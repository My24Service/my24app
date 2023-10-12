import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/core/utils.dart';
import 'package:my24app/quotation/blocs/part_bloc.dart';
import 'package:my24app/quotation/blocs/part_states.dart';
import 'package:my24app/quotation/pages/preliminary_detail.dart';
import 'package:my24app/quotation/widgets/part_form.dart';
import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/core/widgets/drawers.dart';

class PartFormPage extends StatefulWidget {
  final int? quotationPk;
  final int? quotationPartPk;

  PartFormPage({
    Key? key,
    this.quotationPk,
    this.quotationPartPk,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _PartFormPageState();
}

class _PartFormPageState extends State<PartFormPage> {
  bool firstTime = true;

  QuotationPartBloc _initialBlocCall() {
    QuotationPartBloc bloc = QuotationPartBloc();

    if (firstTime) {
      if (widget.quotationPartPk != null) {
        bloc.add(QuotationPartEvent(status: QuotationPartEventStatus.DO_ASYNC));
        bloc.add(QuotationPartEvent(
            status: QuotationPartEventStatus.FETCH_DETAIL, pk: widget.quotationPartPk));
      } else {
        bloc.add(QuotationPartEvent(
            status: QuotationPartEventStatus.NEW));
      }

      firstTime = false;
    }

    return bloc;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => _initialBlocCall(),
        child: FutureBuilder<Widget?>(
          future: getDrawerForUser(context),
          builder: (ctx, snapshot) {
            final Widget? drawer = snapshot.data;

            return FutureBuilder<String?>(
                future: utils.getUserSubmodel(),
                builder: (ctx, snapshot) {
                  if (!snapshot.hasData) {
                    return Scaffold(
                        appBar: AppBar(title: Text('')),
                        body: Container()
                    );
                  }

                  return BlocConsumer<QuotationPartBloc, QuotationPartState>(
                      listener: (context, state) {
                        _partListener(context, state);
                      },
                      builder: (context, state) {
                        return Scaffold(
                          appBar: AppBar(title: Text(
                              'quotations.parts.app_bar_title'.tr())
                          ),
                          drawer: drawer,
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
              );
            }
        )
    );
  }

  void _partListener(context, state) {
    final QuotationPartBloc bloc = BlocProvider.of<QuotationPartBloc>(context);

    if (state is QuotationPartDeletedState) {
      if (state.result!) {
        createSnackBar(context, 'quotations.parts.snackbar_deleted'.tr());

        final page = PreliminaryDetailPage(quotationPk: widget.quotationPk);

        Navigator.pop(context);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => page)
        );
      } else {
        displayDialog(context,
            'generic.error_dialog_title'.tr(),
            'quotations.parts.error_deleting_dialog_content'.tr()
        );
      }
    }

    if (state is QuotationPartInsertedState) {
      if (state.part != null) {
        createSnackBar(context, 'quotations.parts.snackbar_created'.tr());
        bloc.add(QuotationPartEvent(status: QuotationPartEventStatus.DO_ASYNC));
        bloc.add(QuotationPartEvent(
            status: QuotationPartEventStatus.FETCH_DETAIL, pk: state.part!.id));
      } else {
        displayDialog(context,
            'generic.error_dialog_title'.tr(),
            'quotations.parts.error_inserting_dialog_content'.tr()
        );
        bloc.add(QuotationPartEvent(
            status: QuotationPartEventStatus.NEW)
        );
      }
    }

    if (state is QuotationPartEditedState) {
      if (state.result!) {
        createSnackBar(context, 'quotations.parts.snackbar_updated'.tr());
      } else {
        displayDialog(context,
            'generic.error_dialog_title'.tr(),
            'quotations.parts.error_updating_dialog_content'.tr()
        );
      }
      bloc.add(QuotationPartEvent(status: QuotationPartEventStatus.DO_ASYNC));
      bloc.add(QuotationPartEvent(
          status: QuotationPartEventStatus.FETCH_DETAIL, pk: state.quotationPartPk));
    }
  }

  Widget _getBody(context, state) {
    final QuotationPartBloc bloc = BlocProvider.of<QuotationPartBloc>(context);

    if (state is QuotationPartErrorState) {
      return errorNoticeWithReload(
          state.message!,
          bloc,
          QuotationPartEvent(
              status: QuotationPartEventStatus.FETCH_DETAIL,
              pk: widget.quotationPartPk
          )
      );
    }

    if (state is QuotationPartLoadedState) {
      return PartFormWidget(
        quotationPk: widget.quotationPk,
        part: state.part,
      );
    }

    if (state is QuotationPartNewState) {
      return PartFormWidget(
        quotationPk: widget.quotationPk,
      );
    }

    return loadingNotice();
  }
}
