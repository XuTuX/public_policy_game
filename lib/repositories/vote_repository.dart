import '../models/vote_model.dart';
import '../models/assembly_member_model.dart';
import '../models/user_answer_model.dart';
import '../services/vote_api_service.dart';
import '../app/constants/app_constants.dart';

/// 표결 데이터 Repository 인터페이스
abstract class VoteRepository {
  Future<List<VoteModel>> getVotesByBillId(String billId);
  Future<List<AssemblyMemberModel>> getMembers();
  Future<List<AssemblyMemberModel>> getMatchedMembers(
      List<UserAnswerModel> answers);
}

/// 표결 데이터 Repository 구현체
class VoteRepositoryImpl implements VoteRepository {
  final VoteApiService _apiService;

  VoteRepositoryImpl({VoteApiService? apiService})
      : _apiService = apiService ?? VoteApiService();

  List<AssemblyMemberModel>? _cachedMembers;

  @override
  Future<List<VoteModel>> getVotesByBillId(String billId) async {
    return _apiService.fetchVotesByBillId(billId);
  }

  @override
  Future<List<AssemblyMemberModel>> getMembers() async {
    if (_cachedMembers != null) return _cachedMembers!;
    _cachedMembers = await _apiService.fetchMembers();
    return _cachedMembers!;
  }

  /// 핵심 로직: 사용자 답변과 실제 의원 표결을 비교하여 일치율 계산
  @override
  Future<List<AssemblyMemberModel>> getMatchedMembers(
      List<UserAnswerModel> answers) async {
    final members = await getMembers();
    final billIds = answers.map((a) => a.billId).toList();
    final allVotes = await _apiService.fetchAllVotes(billIds);

    final matchedMembers = <AssemblyMemberModel>[];

    for (final member in members) {
      int matchCount = 0;
      int totalCount = 0;
      final comparisons = <VoteComparison>[];

      for (final answer in answers) {
        final votes = allVotes[answer.billId] ?? [];
        final memberVote = votes.where((v) {
          if (v.memberId.isNotEmpty) return v.memberId == member.id;
          return AppConstants.useMockData && v.memberName == member.name;
        }).firstOrNull;

        if (memberVote != null && memberVote.status.comparableChoice != null) {
          totalCount++;
          final isMatch = answer.answer == memberVote.status.comparableChoice;
          if (isMatch) matchCount++;

          comparisons.add(VoteComparison(
            billId: answer.billId,
            billName: answer.billName,
            userVote: answer.answer,
            memberVote: memberVote.status,
          ));
        }
      }

      final matchRate = totalCount > 0 ? (matchCount / totalCount) * 100 : 0.0;

      matchedMembers.add(member.copyWith(
        matchRate: matchRate,
        comparisons: comparisons,
      ));
    }

    // 일치율 내림차순 정렬
    matchedMembers.sort((a, b) {
      final byRate = b.matchRate.compareTo(a.matchRate);
      if (byRate != 0) return byRate;
      final byCompared = b.comparisons.length.compareTo(a.comparisons.length);
      if (byCompared != 0) return byCompared;
      return a.name.compareTo(b.name);
    });
    return matchedMembers;
  }

  void clearCache() {
    _cachedMembers = null;
  }
}
