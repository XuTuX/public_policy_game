import '../models/vote_model.dart';
import '../models/assembly_member_model.dart';
import 'http_service.dart';
import 'game_session_service.dart';
import 'supabase_service.dart';

/// Supabase RPC에서 공개된 게임 세트의 의원 표결정보를 조회한다.
class VoteApiService {
  // ignore: unused_field
  final HttpService _httpService;

  VoteApiService({HttpService? httpService})
    : _httpService = httpService ?? HttpService();

  Map<String, dynamic>? _gameVotesCache;

  Future<Map<String, dynamic>> _fetchGameVotes() async {
    if (_gameVotesCache != null) return _gameVotesCache!;
    await SupabaseService.ensureInitialized();
    final gameSetId = GameSessionService().gameSetId;
    if (gameSetId.isEmpty) {
      throw StateError('활성 게임 세트가 없습니다. 법안을 먼저 불러오세요.');
    }
    final response = await SupabaseService.client.rpc(
      'get_game_votes',
      params: {'p_game_set_id': gameSetId},
    );
    if (response is! Map) throw StateError('표결 데이터 형식이 잘못되었습니다.');
    _gameVotesCache = Map<String, dynamic>.from(response);
    return _gameVotesCache!;
  }

  /// 특정 법안의 표결 데이터 조회
  Future<List<VoteModel>> fetchVotesByBillId(String billId) async {
    final payload = await _fetchGameVotes();
    final rows = payload['votes'];
    if (rows is! List) return const [];
    return rows
        .whereType<Map>()
        .map((row) => VoteModel.fromJson(Map<String, dynamic>.from(row)))
        .where((vote) => vote.billId == billId)
        .toList();
  }

  /// 전체 국회의원 목록 조회
  Future<List<AssemblyMemberModel>> fetchMembers() async {
    final payload = await _fetchGameVotes();
    final rows = payload['members'];
    if (rows is! List) return const [];
    return rows
        .whereType<Map>()
        .map(
          (row) => AssemblyMemberModel.fromJson(Map<String, dynamic>.from(row)),
        )
        .toList();
  }

  /// 특정 법안에 대한 모든 의원의 표결 데이터 일괄 조회
  Future<Map<String, List<VoteModel>>> fetchAllVotes(
    List<String> billIds,
  ) async {
    final payload = await _fetchGameVotes();
    final rows = payload['votes'];
    final result = <String, List<VoteModel>>{
      for (final billId in billIds) billId: <VoteModel>[],
    };
    if (rows is! List) return result;
    for (final row in rows.whereType<Map>()) {
      final vote = VoteModel.fromJson(Map<String, dynamic>.from(row));
      result[vote.billId]?.add(vote);
    }
    return result;
  }
}
