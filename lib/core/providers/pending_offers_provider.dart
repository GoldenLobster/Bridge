import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pending_offer.dart';

class PendingOffersNotifier extends StateNotifier<List<PendingOffer>> {
  PendingOffersNotifier() : super([]);

  void addOffer(PendingOffer offer) {
    state = [...state, offer];
  }

  void removeOffer(String transferId) {
    state = state.where((o) => o.transferId != transferId).toList();
  }

  PendingOffer? getOffer(String transferId) {
    return state.where((o) => o.transferId == transferId).firstOrNull;
  }

  List<PendingOffer> getOffersByDevice(String deviceId) {
    return state.where((o) => o.deviceId == deviceId).toList();
  }
}

final pendingOffersProvider =
    StateNotifierProvider<PendingOffersNotifier, List<PendingOffer>>(
  (_) => PendingOffersNotifier(),
);
