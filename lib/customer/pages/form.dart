import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/core/utils.dart';
import 'package:my24app/customer/blocs/customer_bloc.dart';
import 'package:my24app/customer/blocs/customer_states.dart';
import 'package:my24app/customer/widgets/form.dart';
import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/core/widgets/drawers.dart';

class CustomerFormPage extends StatefulWidget {
  CustomerFormPage({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _CustomerFormPageState();
}

class _CustomerFormPageState extends State<CustomerFormPage> {
  CustomerBloc bloc = CustomerBloc(CustomerInitialState());

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (BuildContext context) => CustomerBloc(CustomerInitialState()),
        child: FutureBuilder<Widget>(
            future: getDrawerForUser(context),
            builder: (ctx, snapshot) {
              final Widget drawer = snapshot.data;
              bloc = BlocProvider.of<CustomerBloc>(ctx);

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
                        appBar: AppBar(title: Text('customers.form.app_bar_title'.tr())),
                        drawer: drawer,
                        body: GestureDetector(
                            onTap: () {
                              FocusScope.of(context).requestFocus(new FocusNode());
                            },
                            child: BlocListener<CustomerBloc, CustomerState>(
                                listener: (context, state) {
                                },
                                child: BlocBuilder<CustomerBloc, CustomerState>(
                                    builder: (context, state) {
                                      if (state is CustomerInitialState) {
                                        return loadingNotice();
                                      }

                                      if (state is CustomerLoadingState) {
                                        return loadingNotice();
                                      }

                                      if (state is CustomerErrorState) {
                                        return errorNotice(state.message);
                                      }

                                      if (state is CustomersLoadedState) {
                                        return CustomerFormWidget(isPlanning: _isPlanning);
                                      }

                                      return CustomerFormWidget(isPlanning: _isPlanning);
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
