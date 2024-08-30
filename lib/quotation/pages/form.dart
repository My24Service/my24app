import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_core/i18n.dart';

import 'package:my24app/quotation/blocs/quotation_bloc.dart';
import 'package:my24app/quotation/blocs/quotation_states.dart';
import 'package:my24app/quotation/models/quotation/form_data.dart';
import 'package:my24app/quotation/widgets/quotation/form.dart';

class QuotationForm extends StatelessWidget {
  final QuotationFormData? formData;
  final String? memberPicture;
  final QuotationEventStatus fetchStatus;
  final CoreWidgets widgetsIn;
  final My24i18n i18nIn;
  final CoreWidgets widgets = CoreWidgets();

  QuotationForm({
    Key? key,
    required this.memberPicture,
    required this.formData,
    required this.fetchStatus,
    required this.widgetsIn,
    required this.i18nIn,
  });

  QuotationBloc _initialCall() {
    final QuotationBloc bloc = QuotationBloc();

    if (formData!.id != null) {
      bloc.add(QuotationEvent(
          status: QuotationEventStatus.UPDATE_FORM_DATA, formData: formData));
    } else {
      bloc.add(QuotationEvent(
        status: QuotationEventStatus.NEW,
      ));
    }

    return bloc;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => _initialCall(),
        child: BlocConsumer<QuotationBloc, QuotationState>(
            listener: (context, state) {
          _handleListeners(context, state);
        }, builder: (context, state) {
          return Scaffold(
            body: _getBody(context, state),
          );
        }));
  }

  void _handleListeners(context, state) {
    final bloc = BlocProvider.of<QuotationBloc>(context);

    if (state is QuotationEditedState) {
      widgets.createSnackBar(context, i18nIn.$trans('snackbar_updated'));
      bloc.add(QuotationEvent(status: QuotationEventStatus.DO_ASYNC));
      bloc.add(QuotationEvent(
          status: QuotationEventStatus.UPDATE_FORM_DATA,
          formData: QuotationFormData.createFromModel(state.result!)));
    }

    if (state is QuotationInsertedState) {
      widgets.createSnackBar(context, i18nIn.$trans('snackbar_added'));
      bloc.add(QuotationEvent(status: QuotationEventStatus.DO_ASYNC));
      bloc.add(QuotationEvent(
          status: QuotationEventStatus.UPDATE_FORM_DATA,
          formData: state.formData));
    }
  }

  Widget _getBody(context, state) {
    final bloc = BlocProvider.of<QuotationBloc>(context);

    if (state is QuotationInitialState) {
      return widgets.loadingNotice();
    }

    if (state is QuotationLoadingState) {
      return widgets.loadingNotice();
    }

    if (state is QuotationErrorState) {
      return widgets.errorNoticeWithReload(
          state.message!, bloc, QuotationEvent(status: fetchStatus));
    }

    if (state is QuotationNewState || state is QuotationUpdateState) {
      return QuotationFormWidget(
        memberPicture: memberPicture,
        formData: state.formData,
        fetchStatus: fetchStatus,
        widgetsIn: widgets,
        i18nIn: i18nIn,
      );
    }

    return widgets.loadingNotice();
  }
}
