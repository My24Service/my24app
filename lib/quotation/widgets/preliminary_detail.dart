import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'package:my24app/core/widgets/widgets.dart';
import 'package:my24app/customer/api/customer_api.dart';
import 'package:my24app/customer/models/models.dart';
import 'package:my24app/quotation/blocs/quotation_bloc.dart';
import 'package:my24app/quotation/models/models.dart';
import 'package:my24app/quotation/api/quotation_api.dart';
import 'package:my24app/quotation/pages/images.dart';
import 'package:my24app/quotation/pages/list.dart';

import '../pages/part_form.dart';

class PreliminaryDetailWidget extends StatefulWidget {
  final bool isPlanning;
  final Quotation quotation;
  final List<QuotationPart> parts;

  PreliminaryDetailWidget({
    @required this.isPlanning,
    @required this.quotation,
    @required this.parts,
    Key key,
  }): super(key: key);

  @override
  State<StatefulWidget> createState() => new _PreliminaryDetailWidgetState();
}

class _PreliminaryDetailWidgetState extends State<PreliminaryDetailWidget> {
  bool _inAsyncCall = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
        child: Container(
            margin: new EdgeInsets.symmetric(horizontal: 20.0),
            child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  _buildQuotationDetailSection(context),
                  _buildPartsSection()
                ]
            )
        ), inAsyncCall: _inAsyncCall);
  }

  Widget _buildPartsSection() {
    return buildItemsSection(
        "quotations.detail.header_parts".tr(),
        widget.parts,
        (QuotationPart part) {
          List<Widget> items = [];
          items.add(createSubHeader(part.description));

          items.add(_createImageSection(part.images));
          // items.add(createDefaultElevatedButton(
          //     "Add image",
          //     () {}
          // ));
          // items.add(Divider());
          items.add(_createLinesSection(part.lines));
          // items.add(createDefaultElevatedButton(
          //     "Add line",
          //     () {}
          // ));
          // items.add(Divider());
          items.add(Row(
            children: [
              createDefaultElevatedButton("Edit quotation part", () { _navPartForm(part.id); }),
              SizedBox(width: 10),
              createDeleteButton("Delete quotation part", () {}),
            ],
          ));

          return items;
        },
        (QuotationPart part) {
          List<Widget> items = [];
          return items;
        }
    );
  }

  Widget _createImageSection(List<QuotationPartImage> images) {
    return buildItemsSection(
      "Images",
      images,
      (QuotationPartImage image) {
        List<Widget> items = [];

        items.add(createImagePart(
            image.url,
            image.description
        ));

        return items;
      },
      (QuotationPartImage image) {
        List<Widget> items = [];
        return items;
      },
    );
  }

  Widget _createLinesSection(List<QuotationPartLine> lines) {
    return buildItemsSection(
      "Lines",
      lines,
      (QuotationPartLine line) {
        List<Widget> items = [];

        items.add(buildItemListTile('quotations.info_line_old_product_name'.tr(), line.oldProductName));
        items.add(buildItemListTile('quotations.info_line_product_name'.tr(), line.productName));
        items.add(buildItemListTile('quotations.info_line_product_identifier'.tr(), line.productIdentifier));
        items.add(buildItemListTile('quotations.info_line_product_amount'.tr(), line.amount));

        return items;
      },
      (QuotationPartLine line) {
        List<Widget> items = [];
        return items;
      },
    );
  }

  void _showDeleteDialog() {

  }

  _navPartForm(int quotationPartPk) {
    final page = PartFormPage(quotationPartPk: quotationPartPk);
    Navigator.push(context,
        MaterialPageRoute(
            builder: (context) => page
        )
    );
  }

  _navUnacceptedList() {
    final page = QuotationListPage(mode: listModes.UNACCEPTED);
    Navigator.pushReplacement(context,
        MaterialPageRoute(
            builder: (context) => page
        )
    );
  }

  Widget _buildQuotationDetailSection(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        buildQuotationInfoCard(context, widget.quotation),
        SizedBox(
          height: 10.0,
        ),
      ],
    );
  }

}
