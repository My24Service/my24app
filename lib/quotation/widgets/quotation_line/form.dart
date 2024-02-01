import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/core/i18n_mixin.dart';
import 'package:my24app/quotation/blocs/quotation_line_bloc.dart';
import 'package:my24app/quotation/blocs/quotation_line_states.dart';
import 'package:my24app/quotation/models/quotation_line/form_data.dart';
import 'package:my24app/quotation/blocs/chapter_bloc.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';

class QuotationLineFormWidget extends StatefulWidget {
  final int? quotationId;
  final int? chapterId;
  final bool isNewChapter;

  QuotationLineFormWidget(
      {Key? key,
      required this.quotationId,
      required this.chapterId,
      this.isNewChapter = false});

  @override
  State<QuotationLineFormWidget> createState() =>
      _QuotationLineFormWidgetState();
}

class _QuotationLineFormWidgetState extends State<QuotationLineFormWidget>
    with TextEditingControllerMixin, i18nMixin {
  void dispose() {
    disposeAll();
    super.dispose();
  }

  QuotationLineBloc _initialCall() {
    final QuotationLineBloc bloc = QuotationLineBloc();

    if (widget.isNewChapter) {
      bloc.add(QuotationLineEvent(status: QuotationLineEventStatus.DO_ASYNC));
      bloc.add(QuotationLineEvent(
          status: QuotationLineEventStatus.NEW_FORM,
          quotationLinesFormsMap: {
            GlobalKey<FormState>(): QuotationLineFormData.createEmpty()
          }));
    } else {
      bloc.add(QuotationLineEvent(status: QuotationLineEventStatus.DO_ASYNC));
      bloc.add(QuotationLineEvent(
          status: QuotationLineEventStatus.FETCH_ALL,
          quotationId: widget.quotationId,
          chapterId: widget.chapterId));
    }
    return bloc;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _initialCall(),
      child: BlocConsumer<QuotationLineBloc, QuotationLineState>(
        listener: (context, state) {
          _handleListeners(context, state);
        },
        builder: (context, state) {
          return _getBody(context, state);
        },
      ),
    );
  }

  void _handleListeners(context, state) {
    final bloc = BlocProvider.of<ChapterBloc>(context);

    if (state is QuotationLineInsertedState) {
      createSnackBar(context, 'Quotation lines saved');
      bloc.add(ChapterEvent(status: ChapterEventStatus.DO_ASYNC));
      bloc.add(ChapterEvent(
          status: ChapterEventStatus.FETCH_ALL,
          quotationId: widget.quotationId));
    }
  }

  final Map<GlobalKey<FormState>, QuotationLineFormData>?
      quotationLinesFormsMap = {};
  Widget _getBody(BuildContext context, state) {
    final bloc = BlocProvider.of<QuotationLineBloc>(context);

    if (state is QuotationLineLoadingState) {
      return showLoading();
    }

    if (state is QuotationLineErrorState) {
      return Container(
        height: 200,
        child: errorNoticeWithReload(
            state.message!,
            bloc,
            QuotationLineEvent(
                status: QuotationLineEventStatus.FETCH_ALL,
                quotationId: widget.quotationId,
                chapterId: widget.chapterId)),
      );
    }

    if (state is QuotationLinesLoadedState) {
      List<Widget> quotationLines = [];

      for (final quotationLine in state.quotationLines?.results ?? []) {
        final GlobalKey<FormState> _quotationLineFormKey =
            GlobalKey<FormState>();
        final QuotationLineFormData quotationLineFormData =
            QuotationLineFormData.createFromModel(quotationLine);

        quotationLines.add(
            _getForm(context, quotationLineFormData, _quotationLineFormKey));
        quotationLines.add(Padding(
          padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
          child: Divider(thickness: 2),
        ));
      }

      return Column(
        children: [
          createSubHeader('Quotation lines'),
          ...quotationLines,
          _deleteChapterButton(context)
        ],
      );
    }

    if (state is NewQuotationLinesFormState) {
      List<Widget> quotationLines = [];

      for (var formKey in state.quotationLinesFormsMap!.keys) {
        quotationLines.add(_getForm(
            context, state.quotationLinesFormsMap![formKey]!, formKey));
        quotationLines.add(Padding(
          padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
          child: Divider(thickness: 2),
        ));
        quotationLinesFormsMap![formKey] =
            state.quotationLinesFormsMap![formKey]!;
      }

      return Column(
        children: [
          createSubHeader('Quotation lines'),
          ...quotationLines,
          _addQuotationLineButton(context),
          _saveChapterButton(context)
        ],
      );
    }

    return showLoading();
  }

  Widget _addQuotationLineButton(BuildContext context) {
    final bloc = BlocProvider.of<QuotationLineBloc>(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
      child: createElevatedButtonColored('Add quotation line', () {
        quotationLinesFormsMap![GlobalKey<FormState>()] =
            QuotationLineFormData.createEmpty();

        bloc.add(QuotationLineEvent(
            status: QuotationLineEventStatus.NEW_FORM,
            quotationLinesFormsMap: quotationLinesFormsMap));
      },
          foregroundColor: Colors.black,
          backgroundColor: Theme.of(context).primaryColor),
    );
  }

  Widget _saveChapterButton(BuildContext context) {
    final bloc = BlocProvider.of<QuotationLineBloc>(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
      child: createElevatedButtonColored('Save chapter', () {
        for (var formKey in quotationLinesFormsMap!.keys) {
          if (formKey.currentState!.validate()) {
            formKey.currentState!.save();
            quotationLinesFormsMap![formKey]!.quotation = widget.quotationId;
            quotationLinesFormsMap![formKey]!.chapter = widget.chapterId;
          } else {
            return;
          }
        }
        bloc.add(QuotationLineEvent(status: QuotationLineEventStatus.DO_ASYNC));
        bloc.add(QuotationLineEvent(
            status: QuotationLineEventStatus.INSERT,
            quotationLinesFormsMap: quotationLinesFormsMap));
      }, foregroundColor: Colors.white, backgroundColor: Colors.red),
    );
  }

  Widget _deleteChapterButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
      child: createElevatedButtonColored(
          'Delete chapter', () => _showDeleteDialog(context),
          foregroundColor: Colors.white, backgroundColor: Colors.red),
    );
  }

  _showDeleteDialog(BuildContext context) {
    showDeleteDialogWrapper('Delete chapter',
        'Are you sure you want to delete this chapter, this action is irreversible',
        () {
      final bloc = BlocProvider.of<ChapterBloc>(context);
      bloc.add(ChapterEvent(status: ChapterEventStatus.DO_ASYNC));
      bloc.add(ChapterEvent(
          status: ChapterEventStatus.DELETE, pk: widget.chapterId));
    }, context);
  }

  Widget _getForm(BuildContext context, QuotationLineFormData formData,
      GlobalKey<FormState> _quotationLineFormKey) {
    Map<String, TextEditingController> formControllers = {};

    TextEditingController? infoController = TextEditingController();
    TextEditingController? amountController = TextEditingController(text: '0');
    TextEditingController? priceController = TextEditingController(text: '0.0');
    TextEditingController? totalController = TextEditingController(text: '0.0');
    TextEditingController? vatController = TextEditingController(text: '0.0');

    addTextEditingController(infoController, formData, 'info');
    addTextEditingController(amountController, formData, 'amount');
    addTextEditingController(priceController, formData, 'price');
    addTextEditingController(totalController, formData, 'total');
    addTextEditingController(vatController, formData, 'vat');

    formControllers['amount'] = amountController;
    formControllers['price'] = priceController;
    formControllers['total'] = totalController;
    formControllers['vat'] = vatController;

    return Form(
        key: _quotationLineFormKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Table(
          children: [
            TableRow(children: [
              wrapGestureDetector(
                  context,
                  Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Text('Description',
                          style: TextStyle(fontWeight: FontWeight.bold)))),
              TextFormField(
                  readOnly: formData.id != null ? true : false,
                  controller: infoController,
                  validator: (value) {
                    return null;
                  }),
            ]),
            TableRow(children: [
              wrapGestureDetector(
                  context,
                  Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Text('Amount',
                          style: TextStyle(fontWeight: FontWeight.bold)))),
              TextFormField(
                  readOnly: formData.id != null ? true : false,
                  keyboardType: TextInputType.number,
                  controller: amountController,
                  onChanged: (value) {
                    debounceTextField(value, (value) {
                      if (double.tryParse(value) != null) {
                        amountController.text = value;
                        _updateFormData(context, formData, formControllers);
                      }
                    });
                  },
                  validator: (value) {
                    if (value == null || int.tryParse(value) == null) {
                      return 'Please enter a valid amount';
                    }
                    return null;
                  }),
            ]),
            TableRow(children: [
              wrapGestureDetector(
                  context,
                  Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Text('Price',
                          style: TextStyle(fontWeight: FontWeight.bold)))),
              TextFormField(
                  readOnly: formData.id != null ? true : false,
                  keyboardType: TextInputType.number,
                  controller: priceController,
                  inputFormatters: [
                    CurrencyInputFormatter(
                        leadingSymbol: CurrencySymbols.EURO_SIGN,
                        mantissaLength: 2)
                  ],
                  onChanged: (value) {
                    debounceTextField(value, (value) {
                      String price = toNumericString(value);

                      if (int.tryParse(price) != null) {
                        double priceInt = int.parse(price) / 100;
                        priceController.text = priceInt.toString();
                        _updateFormData(context, formData, formControllers);
                      }
                    });
                  },
                  validator: (value) {
                    String price = toNumericString(value);
                    if (price.isEmpty || double.tryParse(price) == null) {
                      return 'Please enter a valid price';
                    }
                    return null;
                  }),
            ]),
            TableRow(children: [
              wrapGestureDetector(
                  context,
                  Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Text('VAT type',
                          style: TextStyle(fontWeight: FontWeight.bold)))),
              DropdownButtonFormField<String>(
                value: formData.vatType.toString(),
                items: ['0.0', '9.0', '21.0'].map((String value) {
                  return new DropdownMenuItem<String>(
                    child: new Text(value),
                    value: value,
                  );
                }).toList(),
                onChanged: (newValue) {
                  formData.vatType = double.parse(newValue!);
                  _updateFormData(context, formData, formControllers);
                },
              )
            ]),
            TableRow(children: [
              wrapGestureDetector(
                  context,
                  Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Text('Total',
                          style: TextStyle(fontWeight: FontWeight.bold)))),
              TextFormField(
                  readOnly: true,
                  keyboardType: TextInputType.number,
                  controller: totalController,
                  inputFormatters: [
                    CurrencyInputFormatter(
                        leadingSymbol: CurrencySymbols.EURO_SIGN,
                        mantissaLength: 2)
                  ],
                  validator: (value) {
                    return null;
                  }),
            ]),
            TableRow(children: [
              wrapGestureDetector(
                  context,
                  Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Text('VAT',
                          style: TextStyle(fontWeight: FontWeight.bold)))),
              TextFormField(
                  readOnly: true,
                  keyboardType: TextInputType.number,
                  controller: vatController,
                  inputFormatters: [
                    CurrencyInputFormatter(
                        leadingSymbol: CurrencySymbols.EURO_SIGN,
                        mantissaLength: 2)
                  ],
                  validator: (value) {
                    return null;
                  }),
            ])
          ],
        ));
  }

  _updateFormData(BuildContext context, QuotationLineFormData formData,
      Map<String, TextEditingController> formControllers) {
    final bloc = BlocProvider.of<QuotationLineBloc>(context);

    if (formControllers['price']!.text.isNotEmpty &&
        formControllers['amount']!.text.isNotEmpty) {
      String price = toNumericString(formControllers['price']!.text);
      double priceInt = double.parse(price) / 10;
      double total = priceInt * double.parse(formControllers['amount']!.text);

      formControllers['total']!.text = toCurrencyString(total.toString(),
          leadingSymbol: CurrencySymbols.EURO_SIGN);

      double vat = total * (formData.vatType! / 100);
      formControllers['vat']!.text = toCurrencyString(vat.toString(),
          leadingSymbol: CurrencySymbols.EURO_SIGN);

      formControllers['price']!.text = toCurrencyString(
          formControllers['price']!.text,
          leadingSymbol: CurrencySymbols.EURO_SIGN);

      bloc.add(QuotationLineEvent(
          status: QuotationLineEventStatus.UPDATE_FORM,
          quotationLinesFormsMap: quotationLinesFormsMap));
    }
  }

  Widget showLoading() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Timer? _timer;

  void debounceTextField(value, Function callback) {
    if (_timer?.isActive ?? false) _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 1000), () => callback(value));
  }
}
