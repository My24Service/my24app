import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/core/utils.dart';
import 'package:my24app/quotation/blocs/quotation_bloc.dart';
import 'package:my24app/quotation/blocs/quotation_states.dart';
import 'package:my24app/quotation/widgets/part_form.dart';
import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/core/widgets/drawers.dart';

class PartFormPage extends StatefulWidget {
  final int quotationPartPk;

  PartFormPage({
    Key key,
    @required this.quotationPartPk,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _PartFormPageState();
}

class _PartFormPageState extends State<PartFormPage> {
  bool firstTime = true;

  QuotationBloc _initialBlocCall(int quotationPartPk) {
    QuotationBloc bloc = QuotationBloc();

    if (firstTime) {
      bloc.add(QuotationEvent(status: QuotationEventStatus.DO_ASYNC));
      bloc.add(QuotationEvent(
          status: QuotationEventStatus.FETCH_PART_DETAIL, value: quotationPartPk));

      firstTime = false;
    }

    return bloc;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => _initialBlocCall(widget.quotationPartPk),
        child: BlocConsumer<QuotationBloc, QuotationState>(
            listener: (context, state) {},
            builder: (context, state) {
              return FutureBuilder<Widget>(
                  future: getDrawerForUser(context),
                  builder: (ctx, snapshot) {
                    final Widget drawer = snapshot.data;

                    return FutureBuilder<String>(
                        future: utils.getUserSubmodel(),
                        builder: (ctx, snapshot) {
                          if (!snapshot.hasData) {
                            return Scaffold(
                                appBar: AppBar(title: Text('')),
                                body: Container()
                            );
                          }

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

  Widget _getBody(context, state) {
    final QuotationBloc bloc = BlocProvider.of<QuotationBloc>(context);

    if (state is QuotationPartErrorState) {
      return errorNoticeWithReload(
          state.message,
          bloc,
          QuotationEvent(
              status: QuotationEventStatus.FETCH_DETAIL,
              value: widget.quotationPartPk
          )
      );
    }

    if (state is QuotationPartLoadedState) {
      return PartFormWidget(
        part: state.part,
      );
    }

    return loadingNotice();
  }
}
