import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/mobile/blocs/material_bloc.dart';
import 'package:my24app/core/widgets/slivers/base_widgets.dart';
import 'package:my24app/mobile/models/material/models.dart';
import 'package:my24app/core/models/models.dart';


class MaterialListWidget extends BaseSliverListStatelessWidget {
  final AssignedOrderMaterials materials;
  final int assignedOrderId;
  final PaginationInfo paginationInfo;

  MaterialListWidget({
    Key key,
    @required this.materials,
    @required this.assignedOrderId,
    @required this.paginationInfo
  }) : super(
      key: key,
      modelName: 'assigned_orders.materials.model_name'.tr(),
      paginationInfo: paginationInfo
  );


  @override
  void doRefresh(BuildContext context) {
    final bloc = BlocProvider.of<MaterialBloc>(context);

    bloc.add(MaterialEvent(status: MaterialEventStatus.DO_ASYNC));
    bloc.add(MaterialEvent(
        status: MaterialEventStatus.FETCH_ALL,
        assignedOrderId: assignedOrderId
    ));
  }

  @override
  String getAppBarSubtitle(BuildContext context) {
    return 'assigned_orders.materials.app_bar_subtitle'.tr(
        namedArgs: {'count': "${materials.count}"}
    );
  }

  @override
  String getAppBarTitle(BuildContext context) {
    return 'assigned_orders.materials.app_bar_title'.tr();
  }

  @override
  SliverList getSliverList(BuildContext context) {
    return SliverList(
        delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              AssignedOrderMaterial material = materials.results[index];

              return Column(
                  children: [
                    SizedBox(height: 10),
                    ...buildItemListKeyValueList(
                        'assigned_orders.materials.info_material'.tr(),
                        material.materialName
                    ),
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _createColumnItem(
                            'assigned_orders.materials.info_identifier'.tr(),
                            material.materialIdentifier,
                            width: 140,
                          ),
                          _createColumnItem(
                            'assigned_orders.materials.info_location'.tr(),
                            material.locationName,
                            width: 140,
                          ),
                          _createColumnItem(
                            'assigned_orders.materials.info_amount'.tr(),
                            material.amount.round().toString(),
                            width: 80,
                          ),
                        ]
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        createDeleteButton(
                          "assigned_orders.materials.button_delete".tr(),
                          () { _showDeleteDialog(context, material); }
                        ),
                        SizedBox(width: 8),
                        createEditButton(
                          () => { _doEdit(context, material) },
                        )
                      ],
                    )
                  ]
              );
            },
            childCount: materials.results.length,
        )
    );
  }

  @override
  Widget getBottomSection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        createButton(
          () { _handleNew(context); },
          title: 'assigned_orders.materials.button_add'.tr(),
        )
      ],
    );
  }

  // private methods
  Widget _createColumnItem(String key, String val, {double width: 100}) {
    return Container(
      alignment: AlignmentDirectional.topStart,
      width: width,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: buildItemListKeyValueList(key, val)
      ),
    );
  }

  _handleNew(BuildContext context) {
    final bloc = BlocProvider.of<MaterialBloc>(context);

    bloc.add(MaterialEvent(
        status: MaterialEventStatus.NEW,
        assignedOrderId: assignedOrderId
    ));
  }

  _doDelete(BuildContext context, AssignedOrderMaterial material) {
    final bloc = BlocProvider.of<MaterialBloc>(context);

    bloc.add(MaterialEvent(status: MaterialEventStatus.DO_ASYNC));
    bloc.add(MaterialEvent(
        status: MaterialEventStatus.DELETE,
        pk: material.id,
        assignedOrderId: assignedOrderId
    ));
  }

  _doEdit(BuildContext context, AssignedOrderMaterial material) {
    final bloc = BlocProvider.of<MaterialBloc>(context);

    bloc.add(MaterialEvent(status: MaterialEventStatus.DO_ASYNC));
    bloc.add(MaterialEvent(
        status: MaterialEventStatus.FETCH_DETAIL,
        pk: material.id
    ));
  }

  _showDeleteDialog(BuildContext context, AssignedOrderMaterial material) {
    showDeleteDialogWrapper(
      'assigned_orders.materials.delete_dialog_title'.tr(),
      'assigned_orders.materials.delete_dialog_content'.tr(),
      () => _doDelete(context, material),
      context
    );
  }
}
