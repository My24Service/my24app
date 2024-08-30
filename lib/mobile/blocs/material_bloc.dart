import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:logging/logging.dart';

import 'package:my24app/mobile/models/material/api.dart';
import 'package:my24app/mobile/blocs/material_states.dart';
import 'package:my24app/mobile/models/material/form_data.dart';
import 'package:my24app/mobile/models/material/models.dart';
import 'package:my24app/quotation/models/quotation/api.dart';
import 'package:my24app/quotation/models/quotation_line/models.dart';

final log = Logger('mobile.blocs.material_bloc');

enum AssignedOrderMaterialEventStatus {
  DO_ASYNC,
  FETCH_ALL,
  DO_SEARCH,
  FETCH_DETAIL,
  NEW,
  NEW_EMPTY,
  DELETE,
  UPDATE,
  INSERT,
  INSERT_MULTIPLE,
  UPDATE_FORM_DATA,
  materialCreated
}

class AssignedOrderMaterialEvent {
  final int? pk;
  final int? assignedOrderId;
  final int? quotationId;
  final dynamic status;
  final AssignedOrderMaterial? material;
  final List<AssignedOrderMaterial>? materials;
  final AssignedOrderMaterialFormData? materialFormData;
  final int? page;
  final String? query;

  const AssignedOrderMaterialEvent({
    this.pk,
    this.assignedOrderId,
    this.quotationId,
    this.status,
    this.material,
    this.materials,
    this.materialFormData,
    this.page,
    this.query,
  });
}

class AssignedOrderMaterialBloc extends Bloc<AssignedOrderMaterialEvent, AssignedOrderMaterialState> {
  AssignedOrderMaterialApi api = AssignedOrderMaterialApi();
  QuotationApi quotationApi = QuotationApi();

  AssignedOrderMaterialBloc() : super(MaterialInitialState()) {
    on<AssignedOrderMaterialEvent>((event, emit) async {
      if (event.status == AssignedOrderMaterialEventStatus.DO_ASYNC) {
        _handleDoAsyncState(event, emit);
      }
      else if (event.status == AssignedOrderMaterialEventStatus.FETCH_ALL) {
        await _handleFetchAllState(event, emit);
      }
      else if (event.status == AssignedOrderMaterialEventStatus.DO_SEARCH) {
        _handleDoSearchState(event, emit);
      }
      else if (event.status == AssignedOrderMaterialEventStatus.FETCH_DETAIL) {
        await _handleFetchState(event, emit);
      }
      else if (event.status == AssignedOrderMaterialEventStatus.INSERT) {
        await _handleInsertState(event, emit);
      }
      else if (event.status == AssignedOrderMaterialEventStatus.INSERT_MULTIPLE) {
        await _handleInsertMultipleState(event, emit);
      }
      else if (event.status == AssignedOrderMaterialEventStatus.UPDATE) {
        await _handleEditState(event, emit);
      }
      else if (event.status == AssignedOrderMaterialEventStatus.DELETE) {
        await _handleDeleteState(event, emit);
      }
      else if (event.status == AssignedOrderMaterialEventStatus.UPDATE_FORM_DATA) {
        _handleUpdateFormDataState(event, emit);
      }
      else if (event.status == AssignedOrderMaterialEventStatus.NEW) {
        await _handleNewFormDataState(event, emit);
      }
      else if (event.status == AssignedOrderMaterialEventStatus.NEW_EMPTY) {
        _handleNewEmptyFormDataState(event, emit);
      }
      else if (event.status == AssignedOrderMaterialEventStatus.materialCreated) {
        _handleMaterialCreatedState(event, emit);
      }

    },
    transformer: sequential());
  }

  void _handleMaterialCreatedState(AssignedOrderMaterialEvent event, Emitter<AssignedOrderMaterialState> emit) {
    emit(MaterialNewMaterialCreatedState(materialFormData: event.materialFormData));
  }

  void _handleUpdateFormDataState(AssignedOrderMaterialEvent event, Emitter<AssignedOrderMaterialState> emit) {
    emit(MaterialLoadedState(materialFormData: event.materialFormData));
  }

  void _handleDoSearchState(AssignedOrderMaterialEvent event, Emitter<AssignedOrderMaterialState> emit) {
    emit(MaterialSearchState());
  }

  Future<void> _handleNewFormDataState(AssignedOrderMaterialEvent event, Emitter<AssignedOrderMaterialState> emit) async {
    AssignedOrderMaterialFormData materialFormData = AssignedOrderMaterialFormData.createEmpty(event.assignedOrderId);

    if (event.quotationId != null) {
      // quotation materials
      final List<QuotationLineMaterial> quotationMaterials = await quotationApi.fetchQuotationMaterials(event.quotationId!);

      // materials from quotation that are already entered
      List<AssignedOrderMaterialQuotation> enteredMaterialsFromQuotation = await api.quotationMaterials(event.quotationId!);
      for (int i=0; i<enteredMaterialsFromQuotation.length; i++) {
        enteredMaterialsFromQuotation[i].requestedAmount = quotationMaterials.firstWhere(
            (m) => m.material == enteredMaterialsFromQuotation[i].material
        ).amount;
      }
      materialFormData.enteredMaterialsFromQuotation = enteredMaterialsFromQuotation;

      // create form data list for materials that haven't been entered yet
      List<AssignedOrderMaterialFormData> formDataList = [];
      for (int i=0; i<quotationMaterials.length; i++) {
        List<AssignedOrderMaterialQuotation> itemsDone = enteredMaterialsFromQuotation.where(
          (m) => m.material == quotationMaterials[i].material
        ).toList();

        if (itemsDone.length == 0) {
          formDataList.add(AssignedOrderMaterialFormData(
              assignedOrderId: event.assignedOrderId,
              material: quotationMaterials[i].material,
              name: quotationMaterials[i].material_name,
              identifier: quotationMaterials[i].material_identifier,
              amount: "${quotationMaterials[i].amount}"
          ));
        } else {
          double amountRest = quotationMaterials[i].amount! - itemsDone.first.amount!;
          if (amountRest > 0) {
            formDataList.add(AssignedOrderMaterialFormData(
                assignedOrderId: event.assignedOrderId,
                material: quotationMaterials[i].material,
                name: quotationMaterials[i].material_name,
                identifier: quotationMaterials[i].material_identifier,
                amount: "$amountRest"
            ));
          }
        }
      }
      materialFormData.formDataList = formDataList;
    }

    emit(MaterialNewState(
        materialFormData: materialFormData
    ));
  }

  void _handleNewEmptyFormDataState(AssignedOrderMaterialEvent event, Emitter<AssignedOrderMaterialState> emit) {
    emit(MaterialNewState(
        materialFormData: AssignedOrderMaterialFormData.createEmpty(event.assignedOrderId)
    ));
  }

  void _handleDoAsyncState(AssignedOrderMaterialEvent event, Emitter<AssignedOrderMaterialState> emit) {
    emit(MaterialLoadingState());
  }

  Future<void> _handleFetchAllState(AssignedOrderMaterialEvent event, Emitter<AssignedOrderMaterialState> emit) async {
    try {
      final AssignedOrderMaterials materials = await api.list(
          filters: {
            "assigned_order": event.assignedOrderId,
            'q': event.query,
            'page': event.page
          });
      emit(MaterialsLoadedState(
          materials: materials,
          query: event.query,
          page: event.page
      ));
    } catch(e) {
      log.severe("fetch all: $e");
      emit(MaterialErrorState(message: e.toString()));
    }
  }

  Future<void> _handleFetchState(AssignedOrderMaterialEvent event, Emitter<AssignedOrderMaterialState> emit) async {
    try {
      final AssignedOrderMaterial material = await api.detail(event.pk!);
      emit(MaterialLoadedState(
          materialFormData: AssignedOrderMaterialFormData.createFromModel(material)
      ));
    } catch(e) {
      log.severe("fetch: $e");
      emit(MaterialErrorState(message: e.toString()));
    }
  }

  Future<void> _handleInsertState(AssignedOrderMaterialEvent event, Emitter<AssignedOrderMaterialState> emit) async {
    try {
      final AssignedOrderMaterial material = await api.insert(
          event.material!);
      emit(MaterialInsertedState(material: material));
    } catch(e) {
      log.severe("insert: $e");
      emit(MaterialErrorState(message: e.toString()));
    }
  }

  Future<void> _handleInsertMultipleState(AssignedOrderMaterialEvent event, Emitter<AssignedOrderMaterialState> emit) async {
    try {
      List<AssignedOrderMaterial> results = [];
      for (int i=0; i<event.materials!.length; i++) {
        final AssignedOrderMaterial material = await api.insert(
            event.materials![i]);
        results.add(material);
      }
      emit(MaterialsInsertedState(materials: results));
    } catch(e) {
      log.severe("insert: $e");
      emit(MaterialErrorState(message: e.toString()));
    }
  }

  Future<void> _handleEditState(AssignedOrderMaterialEvent event, Emitter<AssignedOrderMaterialState> emit) async {
    try {
      final AssignedOrderMaterial material = await api.update(event.pk!, event.material!);
      emit(MaterialUpdatedState(material: material));
    } catch(e) {
      log.severe("edit: $e");
      emit(MaterialErrorState(message: e.toString()));
    }
  }

  Future<void> _handleDeleteState(AssignedOrderMaterialEvent event, Emitter<AssignedOrderMaterialState> emit) async {
    try {
      final bool result = await api.delete(event.pk!);
      emit(MaterialDeletedState(result: result));
    } catch(e) {
      log.severe("delete: $e");
      emit(MaterialErrorState(message: e.toString()));
    }
  }
}
