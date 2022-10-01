import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/quotation/blocs/quotation_bloc.dart';
import 'package:my24app/quotation/blocs/quotation_states.dart';
import 'package:my24app/quotation/pages/preliminary_detail.dart';
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
            listener: (context, state) {
              _listener(context, state);
            },
            builder: (context, state) {
              return FutureBuilder<Widget>(
                  future: getDrawerForUser(context),
                  builder: (ctx, snapshot) {
                    final Widget drawer = snapshot.data;
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
                              child: _getBody(state)
                          )
                      );
                  }
              );
            }
        )
    );
  }

  void _listener(context, state) {
    if (state is QuotationInsertedState) {
      if (state.quotation != null) {
        createSnackBar(context, 'quotations.new.snackbar_created'.tr());

        final page = PreliminaryDetailPage(quotationPk: state.quotation.id);
        Navigator.pushReplacement(context,
            MaterialPageRoute(
                builder: (context) => page
            )
        );
      } else {
        displayDialog(context,
            'generic.error_dialog_title'.tr(),
            'quotations.new.error_creating_dialog_content'.tr()
        );
      }
    }
  }

  Widget _getBody(state) {
    if (state is QuotationErrorState) {
      return errorNotice(state.message);
    }

    if (state is QuotationLoadingState) {
      return loadingNotice();
    }

    return PreliminaryNewWidget();
  }
}
