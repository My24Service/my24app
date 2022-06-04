import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/core/utils.dart';
import 'package:my24app/customer/blocs/customer_bloc.dart';
import 'package:my24app/customer/blocs/customer_states.dart';
import 'package:my24app/customer/widgets/form.dart';
import 'package:my24app/core/widgets/widgets.dart';

class CustomerFormPage extends StatefulWidget {
  final dynamic customerPk;

  CustomerFormPage({
    this.customerPk,
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _CustomerFormPageState();
}

class _CustomerFormPageState extends State<CustomerFormPage> {
  bool firstTime = true;

  CustomerBloc _getInitialBloc(bool isEdit) {
    final CustomerBloc bloc = CustomerBloc();

    if (isEdit && firstTime) {
      bloc.add(CustomerEvent(status: CustomerEventStatus.DO_ASYNC));
      bloc.add(CustomerEvent(
          status: CustomerEventStatus.FETCH_DETAIL,
          value: widget.customerPk));

      if (firstTime) {
        firstTime = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEdit = widget.customerPk is int;

    return BlocProvider(
        create: (context) =>  _getInitialBloc(isEdit),
        child: BlocConsumer(
          bloc: _getInitialBloc(isEdit),
          listener: (context, state) {},
          builder: (context, state) {
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
                  final String title = isEdit
                      ? 'customers.form.app_bar_title_update'.tr()
                      : 'customers.form.app_bar_title_add'.tr();

                  return Scaffold(
                      appBar: AppBar(title: Text(title)),
                      body: GestureDetector(
                          onTap: () {
                            FocusScope.of(context).requestFocus(new FocusNode());
                          },
                          child: _getBody(context, state, _isPlanning)
                      )
                  );
                }
            );
          }
      )
    );
  }

  Widget _getBody(context, state, isPlanning) {
    if (state is CustomerInitialState) {
      return CustomerFormWidget(
          customer: null,
          isPlanning: isPlanning
      );
    }

    if (state is CustomerLoadingState) {
      return loadingNotice();
    }

    if (state is CustomerErrorState) {
      return errorNotice(state.message);
    }

    if (state is CustomerLoadedState) {
      return CustomerFormWidget(
          customer: state.customer,
          isPlanning: isPlanning
      );
    }

    return loadingNotice();
  }
}
