import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/core/utils.dart';
import 'package:my24app/quotation/blocs/quotation_bloc.dart';
import 'package:my24app/quotation/blocs/quotation_states.dart';
import 'package:my24app/quotation/widgets/form.dart';
import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/core/widgets/drawers.dart';
import 'package:my24app/quotation/pages/images.dart';

class QuotationFormPage extends StatefulWidget {
  final dynamic orderPk;

  QuotationFormPage({
    Key key,
    @required this.orderPk,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _QuotationFormPageState();
}

class _QuotationFormPageState extends State<QuotationFormPage> {
  QuotationBloc bloc = QuotationBloc(QuotationInitialState());

  _navQuotationList() {
    // final page = QuotationListPage();
    // Navigator.pushReplacement(context,
    //     MaterialPageRoute(
    //         builder: (context) => page
    //     )
    // );
  }

  _navUnacceptedList() {
    // final page = UnacceptedPage();
    // Navigator.pushReplacement(context,
    //     MaterialPageRoute(
    //         builder: (context) => page
    //     )
    // );
  }

  _insertStateHandler(QuotationInsertedState state, bool isPlanning) {
    if (state.quotation != null) {
      createSnackBar(context, 'quotations.form.snackbar_created'.tr());

      showDialog<void>(
          context: context,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('quotations.form.dialog_add_images_title'.tr()),
              content: Text('quotations.form.dialog_add_images_content'.tr()),
              actions: <Widget>[
                TextButton(
                  child: Text('quotations.form.dialog_add_images_button_yes'.tr()),
                  onPressed: () {
                    final page = ImagesPage(quotationPk: state.quotation.id);

                    Navigator.of(context).pop();
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(
                            builder: (context) => page
                        )
                    );
                  },
                ),
                TextButton(
                  child: Text('orders.form.dialog_add_images_button_no'.tr()),
                  onPressed: () {
                    final nextPage = isPlanning ? _navQuotationList() : _navUnacceptedList();

                    Navigator.of(context).pop();
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(
                            builder: (context) => nextPage
                        )
                    );
                  },
                ),
              ],
            );
          }
      );
    } else {
      displayDialog(
          context,
          'generic.error_dialog_title',
          'quotations.form.error_creating'.tr()
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    QuotationBloc _initialBlocCall() {
      bloc.add(QuotationEvent(status: QuotationEventStatus.DO_ASYNC));
      bloc.add(QuotationEvent(
          status: QuotationEventStatus.FETCH_ALL
      ));

      return bloc;
    }

    return BlocProvider(
        create: (BuildContext context) => _initialBlocCall(),
        child: FutureBuilder<Widget>(
          future: getDrawerForUser(context),
          builder: (ctx, snapshot) {
            final Widget drawer = snapshot.data;
            bloc = BlocProvider.of<QuotationBloc>(ctx);

            return FutureBuilder<String>(
              future: utils.getUserSubmodel(),
              builder: (ctx, snapshot) {
                if(!snapshot.hasData) {
                  return Scaffold(
                      appBar: AppBar(title: Text('')),
                      body: Container()
                  );
                }

                final bool _isPlanning = snapshot.data == 'planning_user';

                return Scaffold(
                    appBar: AppBar(title: Text('quotations.form.app_bar_title'.tr())),
                    drawer: drawer,
                    body: GestureDetector(
                        onTap: () {
                          FocusScope.of(context).requestFocus(new FocusNode());
                        },
                        child: BlocListener<QuotationBloc, QuotationState>(
                          listener: (context, state) {
                            if (state is QuotationInsertedState) {
                              _insertStateHandler(state, _isPlanning);
                            }
                          },
                          child: BlocBuilder<QuotationBloc, QuotationState>(
                            builder: (context, state) {
                              if (state is QuotationInitialState) {
                                return loadingNotice();
                              }

                              if (state is QuotationLoadingState) {
                                return loadingNotice();
                              }

                              if (state is QuotationErrorState) {
                                return errorNotice(state.message);
                              }

                              if (state is QuotationsLoadedState) {
                                return QuotationFormWidget();
                              }

                              return SizedBox(height: 0);
                            }
                          )
                      )
                    )
                );
              }
            );
          }
        )
    );
  }
}
