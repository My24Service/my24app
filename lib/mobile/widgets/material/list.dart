import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/core/i18n_mixin.dart';
import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24app/mobile/blocs/material_bloc.dart';
import 'package:my24_flutter_core/widgets/slivers/base_widgets.dart';
import 'package:my24app/mobile/models/material/models.dart';
import 'package:my24_flutter_core/models/models.dart';
import 'mixins.dart';

class MaterialListWidget extends BaseSliverListStatelessWidget with MaterialMixin, i18nMixin {
  final String basePath = "assigned_orders.materials";
  final AssignedOrderMaterials? materials;
  final int? assignedOrderId;
  final PaginationInfo paginationInfo;
  final String? memberPicture;
  final String? searchQuery;

  MaterialListWidget({
    Key? key,
    required this.materials,
    required this.assignedOrderId,
    required this.paginationInfo,
    required this.memberPicture,
    required this.searchQuery
  }) : super(
      key: key,
      paginationInfo: paginationInfo,
      memberPicture: memberPicture
  ) {
    searchController.text = searchQuery?? '';
  }

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
    return $trans('app_bar_subtitle', namedArgs: {'count': "${materials!.count}"}
    );
  }

  @override
  SliverList getSliverList(BuildContext context) {
    return SliverList(
        delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              AssignedOrderMaterial material = materials!.results![index];

              return Column(
                  children: [
                    SizedBox(height: 10),
                    ...buildItemListKeyValueList(
                        $trans('info_material'),
                        material.materialName
                    ),
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _createColumnItem(
                            $trans('info_identifier'),
                            material.materialIdentifier,
                            width: 140,
                          ),
                          _createColumnItem(
                            $trans('info_location'),
                            material.locationName,
                            width: 140,
                          ),
                          _createColumnItem(
                            $trans('info_amount'),
                            material.amount!.round().toString(),
                            width: 80,
                          ),
                        ]
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        createDeleteButton(
                          $trans('button_delete'),
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
            childCount: materials!.results!.length,
        )
    );
  }

  // private methods
  Widget _createColumnItem(String key, String? val, {double width = 100}) {
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
      $trans('delete_dialog_title'),
      $trans('delete_dialog_content'),
      () => _doDelete(context, material),
      context
    );
  }
}
