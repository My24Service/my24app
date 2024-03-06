import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';

import 'package:my24_flutter_core/utils.dart';
import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_core/i18n.dart';

import 'package:my24app/common/utils.dart';
import 'package:my24app/quotation/blocs/quotation_line_bloc.dart';
import 'package:my24app/quotation/blocs/quotation_line_states.dart';
import 'package:my24app/quotation/blocs/quotation_states.dart';
import 'package:my24app/quotation/models/quotation_line/form_data.dart';
import 'package:my24app/quotation/models/quotation_line/models.dart';
import 'package:my24app/quotation/blocs/chapter_bloc.dart';

class QuotationLineWidget extends StatelessWidget {
  final int? quotationId;
  final int? chapterId;
  final CoreWidgets widgetsIn;
  final My24i18n i18nIn;

  QuotationLineWidget(
      {Key? key,
      required this.quotationId,
      required this.chapterId,
      required this.widgetsIn,
      required this.i18nIn});

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
      }, builder: (context, state) {
        final bloc = BlocProvider.of<QuotationLineBloc>(context);

        if (state.status == QuotationLineStatus.loading) {
          return Container(
              height: 100, child: Center(child: CircularProgressIndicator()));
        }

        if (state.status == QuotationLineStatus.error) {
          return Container(
            height: 200,
            child: widgetsIn.errorNoticeWithReload(
                state.message!,
                bloc,
                QuotationLineEvent(
                    status: QuotationLineEventStatus.FETCH_ALL,
                    quotationId: quotationId,
                    chapterId: chapterId)),
          );
        }

        return Container(
          child: Column(
            children: [
              widgetsIn
                  .createSubHeader(i18nIn.$trans('subheader_quotation_lines')),
              QuotationLineList(
                i18nIn: i18nIn,
                widgetsIn: widgetsIn,
                quotationLineForms: state.quotationLineForms!,
              ),
              QuotationLineFormWidget(
                chapterId: chapterId,
                quotationId: quotationId,
                widgetsIn: widgetsIn,
                quotationLineForms: state.quotationLineForms!,
                i18nIn: i18nIn,
              )
            ],
          ),
        );
      }),
    );
  }

  void _handleListeners(context, state) {
    final bloc = BlocProvider.of<QuotationLineBloc>(context);

    if (state is QuotationLineDeletedState) {
      widgetsIn.createSnackBar(context, i18nIn.$trans('snackbar_line_deleted'));
      bloc.add(QuotationLineEvent(status: QuotationLineEventStatus.DO_ASYNC));
      bloc.add(QuotationLineEvent(
          status: QuotationLineEventStatus.FETCH_ALL,
          quotationId: quotationId,
          chapterId: chapterId));
    }
  }
}

class QuotationLineList extends StatelessWidget {
  final CoreWidgets widgetsIn;
  final My24i18n i18nIn;
  final QuotationLineForms quotationLineForms;

  QuotationLineList(
      {Key? key,
      required this.widgetsIn,
      required this.i18nIn,
      required this.quotationLineForms});

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<QuotationLineBloc>(context);

    if (bloc.state.status == QuotationLineStatus.loading) {
      return Container(
          height: 100, child: Center(child: CircularProgressIndicator()));
    }

    if (quotationLineForms.quotationLines!.isEmpty) {
      return Column(
        children: [Text(i18nIn.$trans("no_quotation_lines"))],
      );
    }

    return widgetsIn
        .buildItemsSection(context, "", quotationLineForms.quotationLines,
            (QuotationLine quotationLine) {
      return <Widget>[
        Table(
          children: [
            TableRow(children: [
              Text(i18nIn.$trans('title_description'),
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text('${quotationLine.info}'),
            ]),
            TableRow(children: [
              Text(i18nIn.$trans('info_amount'),
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text('${quotationLine.amount}'),
            ]),
            TableRow(children: [
              Text(i18nIn.$trans('info_price'),
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text('${_formatWithCurrency(quotationLine.price)}'),
            ]),
            TableRow(children: [
              Text(i18nIn.$trans('info_vat_type'),
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text('${quotationLine.vat_type}'),
            ]),
            TableRow(children: [
              Text(i18nIn.$trans('info_total'),
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text('${_formatWithCurrency(quotationLine.total)}'),
            ]),
            TableRow(children: [
              Text(i18nIn.$trans('info_vat'),
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text('${_formatWithCurrency(quotationLine.vat)}'),
            ]),
            TableRow(children: [
              Text(i18nIn.$trans('extra_description'),
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text('${quotationLine.extra_description}'),
            ])
          ],
        )
      ];
    }, (QuotationLine quotationLine) {
      return <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: widgetsIn.createDeleteButton(() {
                _showDeleteDialog(context, quotationLine);
              }),
            )
          ],
        )
      ];
    });
  }

  String _formatWithCurrency(value) {
    return toCurrencyString(value.toString(),
        leadingSymbol: utils.getCurrencySymbol(quotationLineForms.currency!));
  }

  _showDeleteDialog(BuildContext context, QuotationLine quotationLine) {
    widgetsIn.showDeleteDialogWrapper(i18nIn.$trans('delete_dialog_title_line'),
        i18nIn.$trans('delete_dialog_quotation_line'), () {
      final bloc = BlocProvider.of<QuotationLineBloc>(context);
      bloc.add(QuotationLineEvent(status: QuotationLineEventStatus.DO_ASYNC));
      bloc.add(QuotationLineEvent(
          status: QuotationLineEventStatus.DELETE, pk: quotationLine.id));
    }, context);
  }
}

class QuotationLineFormWidget extends StatefulWidget {
  final int? quotationId;
  final int? chapterId;
  final CoreWidgets widgetsIn;
  final My24i18n i18nIn;
  final QuotationLineForms quotationLineForms;

  QuotationLineFormWidget(
      {Key? key,
      required this.quotationId,
      required this.chapterId,
      required this.widgetsIn,
      required this.i18nIn,
      required this.quotationLineForms});

  @override
  State<QuotationLineFormWidget> createState() => _QuotationLineFormState();
}

class _QuotationLineFormState extends State<QuotationLineFormWidget>
    with TextEditingControllerMixin {
  final GlobalKey<FormState> _quotationLineFormKey = GlobalKey<FormState>();
  final TextEditingController infoController = TextEditingController();
  final TextEditingController extraDescriptionController =
      TextEditingController();
  final TextEditingController amountController =
      TextEditingController(text: '0');
  final TextEditingController priceController =
      TextEditingController(text: '0.0');
  final TextEditingController totalController =
      TextEditingController(text: '0.0');
  final TextEditingController vatController =
      TextEditingController(text: '0.0');
  bool newQuotationLine = false;

  @override
  void initState() {
    addTextEditingController(infoController,
        widget.quotationLineForms.quotationLineFormData!, 'info');
    addTextEditingController(extraDescriptionController,
        widget.quotationLineForms.quotationLineFormData!, 'extraDescription');
    addTextEditingController(amountController,
        widget.quotationLineForms.quotationLineFormData!, 'amount');
    addTextEditingController(priceController,
        widget.quotationLineForms.quotationLineFormData!, 'price');
    addTextEditingController(totalController,
        widget.quotationLineForms.quotationLineFormData!, 'total');
    addTextEditingController(
        vatController, widget.quotationLineForms.quotationLineFormData!, 'vat');

    super.initState();
  }

  void dispose() {
    disposeAll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currencySymbol =
        utils.getCurrencySymbol(widget.quotationLineForms.currency!);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (newQuotationLine)
          Form(
              key: _quotationLineFormKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Table(
                children: [
                  TableRow(children: [
                    TextFormField(
                        controller: infoController,
                        decoration: InputDecoration(
                            labelText:
                                widget.i18nIn.$trans('title_description')),
                        validator: (value) {
                          return null;
                        }),
                  ]),
                  TableRow(children: [
                    TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            labelText: widget.i18nIn.$trans('info_amount')),
                        controller: amountController,
                        onChanged: (value) {
                          if (double.tryParse(value) != null) {
                            _updateFormData(context);
                          }
                        },
                        validator: (value) {
                          if (value == null || int.tryParse(value) == null) {
                            return widget.i18nIn.$trans('invalid_amount');
                            //return 'Please enter a valid amount';
                          }
                          return null;
                        }),
                  ]),
                  TableRow(children: [
                    TextFormField(
                        keyboardType: TextInputType.number,
                        controller: priceController,
                        decoration: InputDecoration(
                            labelText: widget.i18nIn.$trans('info_price')),
                        inputFormatters: [
                          CurrencyInputFormatter(
                              leadingSymbol: currencySymbol, mantissaLength: 2)
                        ],
                        onChanged: (value) {
                          String price = toNumericString(value);
                          if (int.tryParse(price) != null) {
                            _updateFormData(context);
                          }
                        },
                        validator: (value) {
                          String price = toNumericString(value);
                          if (price.isEmpty || double.tryParse(price) == null) {
                            widget.i18nIn.$trans('invalid_price');
                            // return 'Please enter a valid price';
                          }
                          return null;
                        }),
                  ]),
                  TableRow(children: [
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                          labelText: widget.i18nIn.$trans('info_vat_type')),
                      value: widget
                          .quotationLineForms.quotationLineFormData!.vatType
                          .toString(),
                      items: ['0.0', '9.0', '21.0'].map((String value) {
                        return new DropdownMenuItem<String>(
                          child: new Text(value),
                          value: value,
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        widget.quotationLineForms.quotationLineFormData!
                            .vatType = double.parse(newValue!);
                        _updateFormData(context);
                      },
                    )
                  ]),
                  TableRow(children: [
                    TextFormField(
                        readOnly: true,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            labelText: widget.i18nIn.$trans('info_total')),
                        controller: totalController,
                        inputFormatters: [
                          CurrencyInputFormatter(
                              leadingSymbol: currencySymbol, mantissaLength: 2)
                        ],
                        validator: (value) {
                          return null;
                        }),
                  ]),
                  TableRow(children: [
                    TextFormField(
                        readOnly: true,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            labelText: widget.i18nIn.$trans('info_vat')),
                        controller: vatController,
                        inputFormatters: [
                          CurrencyInputFormatter(
                              leadingSymbol: currencySymbol, mantissaLength: 2)
                        ],
                        validator: (value) {
                          return null;
                        }),
                  ]),
                  TableRow(children: [
                    TextFormField(
                        keyboardType: TextInputType.multiline,
                        minLines: 1,
                        maxLines: 4,
                        decoration: InputDecoration(
                            labelText:
                                widget.i18nIn.$trans('extra_description')),
                        controller: extraDescriptionController,
                        validator: (value) {
                          return null;
                        }),
                  ]),
                  TableRow(children: [
                    Padding(
                        padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
                        child: widget.widgetsIn.createSubmitButton(
                            context, () => _saveNewQuotationLine(context)))
                  ])
                ],
              )),
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            if (newQuotationLine)
              widget.widgetsIn.createCancelButton(
                  () => _addNewQuotationLine(context, false)),
            if (!newQuotationLine)
              widget.widgetsIn.createDefaultElevatedButton(
                  context,
                  widget.i18nIn.$trans('button_quotation_line_add'),
                  () => _addNewQuotationLine(context, true))
          ],
        )
      ],
    );
  }

  _addNewQuotationLine(BuildContext context, isNew) {
    setState(() {
      newQuotationLine = isNew;
    });
  }

  _saveNewQuotationLine(BuildContext context) {
    final bloc = BlocProvider.of<QuotationLineBloc>(context);

    if (_quotationLineFormKey.currentState!.validate()) {
      _quotationLineFormKey.currentState!.save();
      widget.quotationLineForms.quotationLineFormData!.quotation =
          widget.quotationId;
      widget.quotationLineForms.quotationLineFormData!.chapter =
          widget.chapterId;
      QuotationLine newQuotationLine =
          widget.quotationLineForms.quotationLineFormData!.toModel();
      widget.quotationLineForms.newQuotationLineForm();

      bloc.add(QuotationLineEvent(status: QuotationLineEventStatus.DO_ASYNC));
      bloc.add(QuotationLineEvent(
          status: QuotationLineEventStatus.INSERT,
          quotationLine: newQuotationLine,
          quotationLineForms: widget.quotationLineForms));
    }
  }

  _updateFormData(BuildContext context) {
    final currencySymbol =
        utils.getCurrencySymbol(widget.quotationLineForms.currency!);
    final formData = widget.quotationLineForms.quotationLineFormData;

    if (priceController.text.isNotEmpty && amountController.text.isNotEmpty) {
      String price = toNumericString(priceController.text);
      double priceInt = double.parse(price) / 100;

      double total = priceInt * double.parse(amountController.text);
      totalController.text =
          toCurrencyString(total.toString(), leadingSymbol: currencySymbol);

      double vat = total * (formData!.vatType! / 100);
      vatController.text =
          toCurrencyString(vat.toString(), leadingSymbol: currencySymbol);
    }
  }
}
