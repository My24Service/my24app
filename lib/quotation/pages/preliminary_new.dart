import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/core/utils.dart';
import 'package:my24app/quotation/blocs/quotation_bloc.dart';
import 'package:my24app/quotation/blocs/quotation_states.dart';
import 'package:my24app/quotation/widgets/preliminary_new.dart';
import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/core/widgets/drawers.dart';

class PreliminaryNewPage extends StatefulWidget {
  PreliminaryNewPage({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _PreliminaryNewPageState();
}

class _PreliminaryNewPageState extends State<PreliminaryNewPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => QuotationBloc(),
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
                                  'quotations.new.app_bar_title'.tr())
                              ),
                              drawer: drawer,
                              body: GestureDetector(
                                  onTap: () {
                                    FocusScope.of(context).requestFocus(
                                        new FocusNode());
                                  },
                                  child: _getBody(state, _isPlanning)
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

  Widget _getBody(state, isPlanning) {
    if (state is QuotationInitialState) {
      return PreliminaryNewWidget(isPlanning: isPlanning);
    }

    if (state is QuotationLoadingState) {
      return loadingNotice();
    }

    if (state is QuotationErrorState) {
      return errorNotice(state.message);
    }

    if (state is QuotationsLoadedState) {
      return PreliminaryNewWidget(isPlanning: isPlanning);
    }

    return PreliminaryNewWidget(isPlanning: isPlanning);
  }
}
