import 'dart:async';
import 'dart:developer';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/core/models/models.dart';
import 'package:my24app/core/i18n_mixin.dart';
import 'package:my24app/member/blocs/fetch_states.dart';
import 'package:my24app/quotation/blocs/quotation_line_bloc.dart';
import 'package:my24app/quotation/blocs/quotation_line_states.dart';
import 'package:my24app/quotation/models/quotation_line/models.dart';
import 'package:my24app/quotation/models/quotation_line/form_data.dart';
import 'package:my24app/quotation/blocs/chapter_bloc.dart';
import 'package:my24app/quotation/blocs/chapter_states.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';

class QuotationLineFormWidget extends StatelessWidget with i18nMixin {
  final int? quotationId;
  final int? chapterId;
  final bool isNewChapter;

  QuotationLineFormWidget(
      {Key? key,
      required this.quotationId,
      required this.chapterId,
      this.isNewChapter = false});

  QuotationLineBloc _initialCall() {
    final QuotationLineBloc bloc = QuotationLineBloc();

    bloc.add(QuotationLineEvent(status: QuotationLineEventStatus.DO_ASYNC));
    bloc.add(QuotationLineEvent(
        status: QuotationLineEventStatus.FETCH_ALL,
        quotationId: quotationId,
        chapterId: chapterId));

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
          status: ChapterEventStatus.FETCH_ALL, quotationId: quotationId));
    }
  }

  List<QuotationLineFormData> _quotationLinesForm = [];
  List<GlobalKey<FormState>> _quotationLinesFormsKey = [];
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
                quotationId: quotationId,
                chapterId: chapterId)),
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
      }

      if (isNewChapter && _quotationLinesForm.isEmpty) {
        final GlobalKey<FormState> _quotationLineFormKey =
            GlobalKey<FormState>();
        QuotationLineFormData newForm = QuotationLineFormData.createEmpty();
        quotationLines.add(_getForm(context, newForm, _quotationLineFormKey));
        _quotationLinesFormsKey.add(_quotationLineFormKey);
        _quotationLinesForm.add(newForm);
      } else if (isNewChapter && _quotationLinesForm.isNotEmpty) {
        for (final quotationLineForm in _quotationLinesForm) {
          quotationLines.add(
              _getForm(context, quotationLineForm, _quotationLinesFormsKey[0]));
        }
      }

      return Column(
        children: [
          createSubHeader('Quotation lines'),
          ...quotationLines,
          if (isNewChapter) _saveChapterButton(context),
          _deleteChapterButton(context)
        ],
      );
    }

    return showLoading();
  }

  Widget _saveChapterButton(BuildContext context) {
    final bloc = BlocProvider.of<QuotationLineBloc>(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
      child: createElevatedButtonColored('Save chapter', () {
        for (var i = 0; i < _quotationLinesFormsKey.length; i++) {
          final _quotationLineFormKey = _quotationLinesFormsKey[i];
          final _quotationLineForm = _quotationLinesForm[i];

          if (_quotationLineFormKey.currentState!.validate()) {
            _quotationLineFormKey.currentState!.save();
            _quotationLineForm.quotation = quotationId;
            _quotationLineForm.chapter = chapterId;
            QuotationLine newQuotationLine = _quotationLineForm.toModel();
            bloc.add(
                QuotationLineEvent(status: QuotationLineEventStatus.DO_ASYNC));
            bloc.add(QuotationLineEvent(
                status: QuotationLineEventStatus.INSERT,
                quotationLine: newQuotationLine));
          }
        }
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
      bloc.add(ChapterEvent(status: ChapterEventStatus.DELETE, pk: chapterId));
    }, context);
  }

  Widget _getForm(BuildContext context, QuotationLineFormData formData,
      GlobalKey<FormState> _quotationLineFormKey) {
    return Form(
        key: _quotationLineFormKey,
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
                  controller: formData.infoController,
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
                  keyboardType: TextInputType.number,
                  controller: formData.amountController,
                  onChanged: (value) {
                    debounceTextField(value, (value) {
                      if (double.tryParse(value) != null) {
                        formData.amountController!.text = value;
                        _updateFormData(context, formData);
                      }
                    });
                  },
                  validator: (value) {
                    if (value!.isEmpty || int.tryParse(value) == null) {
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
                  keyboardType: TextInputType.number,
                  controller: formData.priceController,
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
                        formData.priceController!.text = priceInt.toString();
                        _updateFormData(context, formData);
                      }
                    });
                  },
                  validator: (value) {
                    String price = toNumericString(value);
                    if (value!.isEmpty || double.tryParse(price) == null) {
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
                  _updateFormData(context, formData);
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
                  controller: formData.totalController,
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
                  controller: formData.vatController,
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

  _updateFormData(BuildContext context, QuotationLineFormData formData) {
    final bloc = BlocProvider.of<QuotationLineBloc>(context);

    if (formData.priceController!.text.isNotEmpty &&
        formData.amountController!.text.isNotEmpty) {
      String price = toNumericString(formData.priceController!.text);
      double priceInt = int.parse(price) / 100;
      double total = priceInt * double.parse(formData.amountController!.text);

      formData.totalController!.text = toCurrencyString(total.toString(),
          leadingSymbol: CurrencySymbols.EURO_SIGN);

      double vat = total * (formData.vatType! / 100);
      formData.vatController!.text = toCurrencyString(vat.toString(),
          leadingSymbol: CurrencySymbols.EURO_SIGN);

      formData.priceController!.text = toCurrencyString(
          formData.priceController!.text,
          leadingSymbol: CurrencySymbols.EURO_SIGN);

      bloc.add(
          QuotationLineEvent(status: QuotationLineEventStatus.UPDATE_FORM));
    }
  }

  Widget showLoading() {
    return Center(child: CircularProgressIndicator());
  }

  Timer? _timer;
  void debounceTextField(value, Function callback) {
    if (_timer?.isActive ?? false) _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 1000), () => callback(value));
  }
}
