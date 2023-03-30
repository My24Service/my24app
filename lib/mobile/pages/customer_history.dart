import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/core/i18n_mixin.dart';
import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/mobile/blocs/customer_history_bloc.dart';
import 'package:my24app/mobile/blocs/customer_history_states.dart';
import 'package:my24app/mobile/widgets/customer_history/list.dart';
import 'package:my24app/mobile/widgets/customer_history/empty.dart';
import 'package:my24app/mobile/widgets/customer_history/error.dart';
import 'package:my24app/core/models/models.dart';
import 'package:my24app/core/utils.dart';

class CustomerHistoryPage extends StatelessWidget with i18nMixin {
  final int customerPk;
  final String customerName;
  final CustomerHistoryBloc bloc;
  final Utils utils = Utils();

  CustomerHistoryPage({
    Key key,
    @required this.customerPk,
    @required this.customerName,
    @required this.bloc
  }) : super(key: key);

  Future<DefaultPageData> getPageData() async {
    String memberPicture = await this.utils.getMemberPicture();

    DefaultPageData result = DefaultPageData(
      memberPicture: memberPicture,
    );

    return result;
  }

  CustomerHistoryBloc _initialBlocCall() {
    bloc.add(CustomerHistoryEvent(status: CustomerHistoryEventStatus.DO_ASYNC));
    bloc.add(CustomerHistoryEvent(
        status: CustomerHistoryEventStatus.FETCH_ALL,
        customerPk: customerPk
    ));

    return bloc;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DefaultPageData>(
        future: getPageData(),
        builder: (ctx, snapshot) {
          if (snapshot.hasData) {
            DefaultPageData pageData = snapshot.data;

            return BlocProvider<CustomerHistoryBloc>(
                create: (context) => _initialBlocCall(),
                child: BlocConsumer<CustomerHistoryBloc, CustomerHistoryState>(
                    listener: (context, state) {
                    },
                    builder: (context, state) {
                      return Scaffold(
                          body: GestureDetector(
                            onTap: () {
                              FocusScope.of(context).requestFocus(FocusNode());
                            },
                            child: _getBody(context, state, pageData),
                          )
                      );
                    }
                )
            );
          } else if (snapshot.hasError) {
            print(snapshot.error);
            return Center(
                child: Text(
                    $trans("error_arg", pathOverride: "generic",
                        namedArgs: {"error": snapshot.error}))
            );
          } else {
            return loadingNotice();
          }
        }
    );
  }

  Widget _getBody(context, state, DefaultPageData pageData) {
    if (state is CustomerHistoryInitialState) {
      return loadingNotice();
    }

    if (state is CustomerHistoryLoadingState) {
      return loadingNotice();
    }

    if (state is CustomerHistoryErrorState) {
      return CustomerHistoryErrorWidget(
          error: state.message,
          memberPicture: pageData.memberPicture
      );
    }

    if (state is CustomerHistoryLoadedState) {
      if (state.customerHistoryOrders.results.length == 0) {
        return CustomerHistoryEmptyWidget(memberPicture: pageData.memberPicture);
      }

      PaginationInfo paginationInfo = PaginationInfo(
          count: state.customerHistoryOrders.count,
          next: state.customerHistoryOrders.next,
          previous: state.customerHistoryOrders.previous,
          currentPage: state.page != null ? state.page : 1,
          pageSize: 2
      );

      return CustomerHistoryWidget(
        customerHistoryOrders: state.customerHistoryOrders,
        customerPk: customerPk,
        paginationInfo: paginationInfo,
        memberPicture: pageData.memberPicture,
        customerName: customerName,
      );
    }

    return loadingNotice();
  }
}
