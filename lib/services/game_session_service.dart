import '../models/bill_model.dart';

/// 현재 기기에서 진행 중인 게임 세트 메타데이터를 유지한다.
class GameSessionService {
  static final GameSessionService _instance = GameSessionService._();

  factory GameSessionService() => _instance;

  GameSessionService._();

  String gameSetId = '';
  DateTime? dataAsOf;
  List<BillModel> bills = const [];

  void update({
    required String gameSetId,
    DateTime? dataAsOf,
    List<BillModel>? bills,
  }) {
    this.gameSetId = gameSetId;
    this.dataAsOf = dataAsOf;
    if (bills != null) this.bills = List.unmodifiable(bills);
  }

  void clear() {
    gameSetId = '';
    dataAsOf = null;
    bills = const [];
  }
}
