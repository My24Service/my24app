import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/company/models/models.dart';
import 'package:my24app/mobile/blocs/assign_bloc.dart';
import 'package:my24app/order/models/order/models.dart';
import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/core/widgets/slivers/base_widgets.dart';
import 'package:my24app/core/i18n_mixin.dart';
import 'package:my24app/order/pages/unassigned.dart';
import '../../order/blocs/order_bloc.dart';
import '../models/assign/form_data.dart';

class AssignWidget extends BaseSliverPlainStatelessWidget with i18nMixin {
  final String basePath = "orders.assign";
  final Order order;
  final List<EngineerUser> engineers;
  final AssignOrderFormData formData;
  final String memberPicture;

  AssignWidget({
    Key key,
    @required this.order,
    @required this.engineers,
    @required this.formData,
    @required this.memberPicture,
  }) : super(
      key: key,
      memberPicture: memberPicture
  );

  @override
  Widget getBottomSection(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          createElevatedButtonColored(
              $trans('action_cancel', pathOverride: 'generic'),
              () => { _navList(context) }
          ),
          SizedBox(width: 10),
          createDefaultElevatedButton(
              $trans('button_assign'),
              () => { _doAssign(context) }
          ),
        ]
    );
  }

  @override
  Widget getContentWidget(BuildContext context) {
    return Column(
      children: [
          createHeader($trans('header_order')),
          buildOrderInfoCard(context, order),
          Divider(),
          _createEngineersTable(context),
        ]
    );
  }

  bool _isEngineerSelected(EngineerUser engineer) {
    return formData.selectedEngineerPks.contains(engineer.id);
  }

  Widget _createEngineersTable(BuildContext context) {
    return buildItemsSection(
      context,
      $trans('header_engineers'),
      engineers,
      (engineer) {
        return <Widget>[
          CheckboxListTile(
              value: _isEngineerSelected(engineer),
              activeColor: Colors.green,
              onChanged:(bool newValue) {
                if (newValue) {
                  formData.selectedEngineerPks.add(engineer.id);
                } else {
                  formData.selectedEngineerPks.remove(engineer.id);
                }

                _updateFormData(context);
              },
              title: Text('${engineer.fullName}')
          )
        ];
      },
      (item) {
        return <Widget>[
        ];
      },
    );
  }

  void _navList(BuildContext context) {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => OrdersUnAssignedPage(
      bloc: OrderBloc(),
    )));
  }

  void _doAssign(BuildContext context) {
    if (formData.selectedEngineerPks.length == 0) {
      displayDialog(context,
          $trans('dialog_no_engineers_selected_title'),
          $trans('dialog_no_engineers_selected_content')
      );
      return;
    }

    final bloc = BlocProvider.of<AssignBloc>(context);
    bloc.add(AssignEvent(status: AssignEventStatus.DO_ASYNC));
    bloc.add(AssignEvent(
        status: AssignEventStatus.ASSIGN,
        formData: formData,
        orderId: order.orderId
    ));
  }

  _updateFormData(BuildContext context) {
    final bloc = BlocProvider.of<AssignBloc>(context);
    bloc.add(AssignEvent(status: AssignEventStatus.DO_ASYNC));
    bloc.add(AssignEvent(
      status: AssignEventStatus.UPDATE_FORM_DATA,
      formData: formData,
      order: order
    ));
  }
}
