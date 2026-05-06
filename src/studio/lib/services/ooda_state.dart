import 'package:flutter/foundation.dart';
import 'package:qtconsult_studio/models/ooda_data.dart';

class OodaState extends ChangeNotifier {
  final OodaData _data;

  OodaState(this._data);

  OodaData get data => _data;

  void toggleObserveConfirm(String id) {
    final index = _data.observes.indexWhere((c) => c.id == id);
    if (index == -1) return;
    final card = _data.observes[index];
    final newStatus = card.status == CardStatus.confirmed
        ? CardStatus.pending
        : CardStatus.confirmed;
    _data.observes[index] = card.copyWith(status: newStatus);
    notifyListeners();
  }

  void toggleStrategySelect(String id) {
    final index = _data.strategies.indexWhere((s) => s.id == id);
    if (index == -1) return;
    final s = _data.strategies[index];
    _data.strategies[index] = s.copyWith(isSelected: !s.isSelected);
    notifyListeners();
  }

  void updateClientNote(String id, String note) {
    final index = _data.strategies.indexWhere((s) => s.id == id);
    if (index == -1) return;
    _data.strategies[index] =
        _data.strategies[index].copyWith(clientNote: note);
    notifyListeners();
  }
}
