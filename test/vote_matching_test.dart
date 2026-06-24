import 'package:flutter_test/flutter_test.dart';
import 'package:public_policy_game/models/assembly_member_model.dart';
import 'package:public_policy_game/models/user_answer_model.dart';
import 'package:public_policy_game/models/vote_model.dart';
import 'package:public_policy_game/repositories/vote_repository.dart';
import 'package:public_policy_game/services/vote_api_service.dart';

class _FakeVoteApiService extends VoteApiService {
  final List<AssemblyMemberModel> fakeMembers;
  final Map<String, List<VoteModel>> fakeVotes;

  _FakeVoteApiService(this.fakeMembers, this.fakeVotes);

  @override
  Future<List<AssemblyMemberModel>> fetchMembers() async => fakeMembers;

  @override
  Future<Map<String, List<VoteModel>>> fetchAllVotes(
    List<String> billIds,
  ) async =>
      fakeVotes;
}

void main() {
  test('불참·미투표를 일치율 분모에서 제외한다', () async {
    const members = [
      AssemblyMemberModel(
        id: 'member-1',
        name: '가의원',
        party: '가당',
        district: '서울',
      ),
      AssemblyMemberModel(
        id: 'member-2',
        name: '나의원',
        party: '나당',
        district: '부산',
      ),
    ];
    const votes = {
      'bill-1': [
        VoteModel(
          billId: 'bill-1',
          memberId: 'member-1',
          memberName: '가의원',
          party: '가당',
          district: '서울',
          status: MemberVoteStatus.yes,
        ),
        VoteModel(
          billId: 'bill-1',
          memberId: 'member-2',
          memberName: '나의원',
          party: '나당',
          district: '부산',
          status: MemberVoteStatus.notVoted,
        ),
      ],
    };
    final repository = VoteRepositoryImpl(
      apiService: _FakeVoteApiService(members, votes),
    );

    final ranked = await repository.getMatchedMembers([
      UserAnswerModel(
        visitorId: 'local_user',
        billId: 'bill-1',
        billName: '테스트 법안',
        answer: VoteType.yes,
        answeredAt: DateTime(2026, 6, 24),
      ),
    ]);

    expect(ranked.first.id, 'member-1');
    expect(ranked.first.matchRate, 100);
    expect(ranked.first.comparisons, hasLength(1));
    expect(ranked.last.id, 'member-2');
    expect(ranked.last.matchRate, 0);
    expect(ranked.last.comparisons, isEmpty);
  });
}
