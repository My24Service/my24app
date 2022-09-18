import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

import 'package:my24app/quotation/api/quotation_api.dart';
import 'package:my24app/quotation/blocs/quotation_states.dart';
import 'package:my24app/quotation/models/models.dart';

import '../../core/utils.dart';

enum QuotationEventStatus {
  DO_ASYNC,
  DO_SEARCH,
  DO_REFRESH,
  FETCH_ALL,
  FETCH_UNACCEPTED,
  FETCH_DETAIL,
  FETCH_PART_DETAIL,
  DELETE,
  DELETE_LINE,
  DELETE_IMAGE,
  ACCEPT
}

class QuotationEvent {
  final QuotationEventStatus status;
  final int quotationPk;
  final int quotationPartPk;
  final int linePk;
  final int imagePk;
  final dynamic value;
  final int page;
  final String query;

  const QuotationEvent({
    this.value,
    this.quotationPk,
    this.quotationPartPk,
    this.linePk,
    this.imagePk,
    this.status,
    this.page,
    this.query
  });
}

class QuotationBloc extends Bloc<QuotationEvent, QuotationState> {
  QuotationApi localQuotationApi = quotationApi;

  QuotationBloc() : super(QuotationInitialState()) {
    on<QuotationEvent>((event, emit) async {
      if (event.status == QuotationEventStatus.DO_ASYNC) {
        _handleDoAsyncState(event, emit);
      }
      else if (event.status == QuotationEventStatus.DO_SEARCH) {
        _handleDoSearchState(event, emit);
      }
      else if (event.status == QuotationEventStatus.DO_REFRESH) {
        _handleDoRefreshState(event, emit);
      }
      else if (event.status == QuotationEventStatus.FETCH_ALL) {
        await _handleFetchAllState(event, emit);
      }
      else if (event.status == QuotationEventStatus.FETCH_PART_DETAIL) {
        await _handleFetchPartDetailState(event, emit);
      }
      else if (event.status == QuotationEventStatus.FETCH_DETAIL) {
        await _handleFetchDetailState(event, emit);
      }
      else if (event.status == QuotationEventStatus.DELETE) {
        await _handleDeleteState(event, emit);
      }
      else if (event.status == QuotationEventStatus.FETCH_UNACCEPTED) {
        await _handleUnAcceptedState(event, emit);
      }
      else if (event.status == QuotationEventStatus.ACCEPT) {
        await _handleAcceptState(event, emit);
      }
    },
    transformer: sequential());
  }

  void _handleDoAsyncState(QuotationEvent event, Emitter<QuotationState> emit) {
    emit(QuotationLoadingState());
  }

  void _handleDoSearchState(QuotationEvent event, Emitter<QuotationState> emit) {
    emit(QuotationSearchState());
  }

  void _handleDoRefreshState(QuotationEvent event, Emitter<QuotationState> emit) {
    emit(QuotationRefreshState());
  }

  Future<void> _handleFetchAllState(QuotationEvent event, Emitter<QuotationState> emit) async {
    try {
      final Quotations quotations = await localQuotationApi.fetchQuotations(
          query: event.query,
          page: event.page
      );
      emit(QuotationsLoadedState(quotations: quotations, query: event.query));
    } catch(e) {
      emit(QuotationErrorState(message: e.toString()));
    }
  }

  Future<void> _handleFetchDetailState(QuotationEvent event, Emitter<QuotationState> emit) async {
    try {
      // final Quotation quotation = await localQuotationApi.fetchQuotation(event.quotationPk);
      // final List<QuotationPart> parts = await localQuotationApi.fetchQuotationParts(event.quotationPk);
      Quotation quotation = Quotation(
        customerRelation: 1,
        quotationId: "RJ-00012",
        customerId: "1224356",
        quotationName: "Abbot",
        quotationAddress: "Bla straat 1",
        quotationPostal: "1552AB",
        quotationCity: "Emmen",
        quotationCountryCode: "NL",
        quotationTel: "06-123456678",
        quotationMobile: "06-2673547263",
        quotationEmail: "abbot@abbot.com",
        quotationContact: "Piet",
        description: "Offerte voor OBS Het Eenspan",
        quotationReference: "3456778-4876283",

        signatureEngineer: '',
        signatureNameEngineer: '',
        signatureCustomer: '',
        signatureNameCustomer: '',
        lastStatusFull: "17/09/2022 10:55 aangemaakt door richard@pedroja.tech"
      );

      QuotationPartImage img1 = QuotationPartImage(
          description: "Lokaal B1",
          image: "/media/company_pictures/ritehite/64c2482a-9c1c-4218-a78d-7361a05c4931.jpeg"
      );
      img1.url = await utils.getUrl(img1.image);
      img1.url = img1.url.replaceAll('api/', '');

      QuotationPartImage img2 = QuotationPartImage(
          description: "Lokaal B2",
          image: "/media/company_pictures/ritehite/19042e7b-9cf6-46de-bcd5-2da11aa57d47.jpeg"
      );
      img2.url = await utils.getUrl(img1.image);
      img2.url = img2.url.replaceAll('api/', '');

      QuotationPartLine line1 = QuotationPartLine(
          oldProductName: "Nog een oude lamp 70W",
          productName: "LED HEW-3467",
          productIdentifier: "LED-HEW-3467",
          amount: 3
      );

      QuotationPartLine line2 = QuotationPartLine(
          oldProductName: "Hele oude lamp 10W",
          productName: "LED AKL-3467",
          productIdentifier: "LED-AKL-3467",
          amount: 2
      );

      QuotationPart part1 = QuotationPart(
        description: "Eerste etage",
        images: [img1, img2],
        lines: [line1, line2]
      );

      QuotationPart part2 = QuotationPart(
          description: "Tweede etage",
          images: [img1, img2],
          lines: [line1, line2]
      );

      emit(QuotationLoadedState(quotation: quotation, parts: [part1, part2]));
    } catch(e) {
      emit(QuotationErrorState(message: e.toString()));
    }
  }

  Future<void> _handleFetchPartDetailState(QuotationEvent event, Emitter<QuotationState> emit) async {
    try {
      // final QuotationPart part = await localQuotationApi.fetchQuotationPart(event.quotationPartPk);
      // final List<QuotationPartImage> images = await localQuotationApi.fetchQuotationPartImages(event.quotationPk);
      // final List<QuotationPartLine> lines = await localQuotationApi.fetchQuotationPartLines(event.quotationPk);
      QuotationPartImage img1 = QuotationPartImage(
          id: 1,
          description: "Lokaal B1",
          image: "/media/company_pictures/ritehite/64c2482a-9c1c-4218-a78d-7361a05c4931.jpeg"
      );
      img1.url = await utils.getUrl(img1.image);
      img1.url = img1.url.replaceAll('api/', '');

      QuotationPartImage img2 = QuotationPartImage(
          id: 2,
          description: "Lokaal B2",
          image: "/media/company_pictures/ritehite/19042e7b-9cf6-46de-bcd5-2da11aa57d47.jpeg"
      );
      img2.url = await utils.getUrl(img1.image);
      img2.url = img2.url.replaceAll('api/', '');

      QuotationPartLine line1 = QuotationPartLine(
          id: 1,
          oldProductName: "Nog een oude lamp 70W",
          productName: "LED HEW-3467",
          productIdentifier: "LED-HEW-3467",
          amount: 3
      );

      QuotationPartLine line2 = QuotationPartLine(
          id: 2,
          oldProductName: "Hele oude lamp 10W",
          productName: "LED AKL-3467",
          productIdentifier: "LED-AKL-3467",
          amount: 2
      );

      QuotationPart part = QuotationPart(
          description: "Eerste etage",
          images: [img1, img2],
          lines: [line1, line2]
      );
      emit(QuotationPartLoadedState(part: part));
    } catch(e) {
      emit(QuotationPartErrorState(message: e.toString()));
    }
  }

  Future<void> _handleUnAcceptedState(QuotationEvent event, Emitter<QuotationState> emit) async {
    try {
      final Quotations quotations = await localQuotationApi.fetchUncceptedQuotations();
      emit(QuotationsUnacceptedLoadedState(quotations: quotations));
    } catch(e) {
      emit(QuotationErrorState(message: e.toString()));
    }
  }

  Future<void> _handleDeleteState(QuotationEvent event, Emitter<QuotationState> emit) async {
    try {
      final bool result = await localQuotationApi.deleteQuotation(event.value);
      emit(QuotationDeletedState(result: result));
    } catch(e) {
      emit(QuotationErrorState(message: e.toString()));
    }
  }

  Future<void> _handleAcceptState(QuotationEvent event, Emitter<QuotationState> emit) async {
    try {
      final bool result = await localQuotationApi.acceptQuotation(event.value);
      emit(QuotationAcceptedState(result: result));
    } catch(e) {
      emit(QuotationErrorState(message: e.toString()));
    }
  }

}
