import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/core/utils.dart';
import 'package:my24app/quotation/blocs/quotation_bloc.dart';
import 'package:my24app/quotation/blocs/quotation_states.dart';
import 'package:my24app/quotation/widgets/preliminary_detail.dart';
import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/core/widgets/drawers.dart';

class PreliminaryDetailPage extends StatefulWidget {
  final int quotationPk;

  PreliminaryDetailPage({
    Key key,
    @required this.quotationPk,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _PreliminaryDetailPageState();
}

class _PreliminaryDetailPageState extends State<PreliminaryDetailPage> {
  bool firstTime = true;

  QuotationBloc _initialBlocCall(int quotationPk) {
    QuotationBloc bloc = QuotationBloc();

    if (firstTime) {
      bloc.add(QuotationEvent(status: QuotationEventStatus.DO_ASYNC));
      bloc.add(QuotationEvent(
          status: QuotationEventStatus.FETCH_DETAIL, value: quotationPk));

      firstTime = false;
    }

    return bloc;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => _initialBlocCall(widget.quotationPk),
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

                          final bool _isPlanning = snapshot.data == 'planning_user';

                          return Scaffold(
                              appBar: AppBar(title: Text(
                                  'quotations.detail.app_bar_title'.tr())
                              ),
                              drawer: drawer,
                              body: GestureDetector(
                                  onTap: () {
                                    FocusScope.of(context).requestFocus(
                                        new FocusNode());
                                  },
                                  child: _getBody(context, state, _isPlanning)
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

  Widget _getBody(context, state, isPlanning) {
    final QuotationBloc bloc = BlocProvider.of<QuotationBloc>(context);

    if (state is QuotationErrorState) {
      return errorNoticeWithReload(
          state.message,
          bloc,
          QuotationEvent(
              status: QuotationEventStatus.FETCH_DETAIL,
              value: widget.quotationPk
          )
      );
    }

    if (state is QuotationLoadedState) {
      return PreliminaryDetailWidget(
        quotation: state.quotation,
        parts: state.parts,
        isPlanning: isPlanning,
      );
    }

    return loadingNotice();
  }
}
