import 'package:flutter_test/flutter_test.dart';
import 'package:public_policy_game/models/bill_model.dart';
import 'package:public_policy_game/models/user_answer_model.dart';
import 'package:public_policy_game/models/vote_model.dart';

void main() {
  group('실데이터 모델', () {
    test('기권 사용자 응답을 로컬 저장소에서 복원한다', () {
      final answer = UserAnswerModel.fromJson({
        'visitorId': 'local_user',
        'billId': 'bill-id',
        'billName': '테스트 법안',
        'answer': 'abstain',
        'answeredAt': '2026-06-24T01:00:00Z',
        'gameSetId': 'game-set-id',
      });

      expect(answer.answer, VoteType.abstain);
      expect(answer.gameSetId, 'game-set-id');
    });

    test('불참을 기권과 별도의 의원 표결 상태로 파싱한다', () {
      final vote = VoteModel.fromJson({
        'billId': 'bill-id',
        'memberId': 'member-id',
        'memberName': '홍길동',
        'party': '테스트당',
        'district': '서울',
        'status': 'not_voted',
        'rawVoteResult': '불참',
      });

      expect(vote.status, MemberVoteStatus.notVoted);
      expect(vote.status.comparableChoice, isNull);
    });

    test('알 수 없는 의원 표결을 기권으로 변환하지 않는다', () {
      expect(
        () => VoteModel.fromJson({
          'billId': 'bill-id',
          'memberName': '홍길동',
          'party': '테스트당',
          'district': '서울',
          'status': '확인불가',
        }),
        throwsFormatException,
      );
    });

    test('법안의 출처와 데이터 기준 시각을 파싱한다', () {
      final bill = BillModel.fromJson({
        'id': 'bill-id',
        'billNo': '2200001',
        'billName': '테스트 법안',
        'category': '기술',
        'status': '가결',
        'proposer': '홍길동',
        'proposedDate': '2026-06-01',
        'voteDate': '2026-06-20',
        'officialSourceUrl': 'https://likms.assembly.go.kr/example',
        'dataAsOf': '2026-06-24T01:00:00Z',
        'aiModel': 'deepseek-v4-flash',
      });

      expect(bill.voteDate, DateTime(2026, 6, 20));
      expect(bill.officialSourceUrl, contains('assembly.go.kr'));
      expect(bill.aiModel, 'deepseek-v4-flash');
    });

    test('법안명에서 발의 의원 정보를 파싱 시점에 제거한다', () {
      final billWithProposers = BillModel.fromJson({
        'id': 'bill-id',
        'billNo': '2200001',
        'billName': '국가유산기본법 일부개정법률안 (홍길동의원 등 10인)',
        'category': '기술',
        'status': '가결',
        'proposer': '홍길동',
        'proposedDate': '2026-06-01',
      });
      final billWithSingleProposer = BillModel.fromJson({
        'id': 'bill-id-2',
        'billNo': '2200002',
        'billName': '디지털포용법안 (김철수의원 발의)',
        'category': '기술',
        'status': '가결',
        'proposer': '김철수',
        'proposedDate': '2026-06-01',
      });

      expect(billWithProposers.billName, '국가유산기본법 일부개정법률안');
      expect(billWithSingleProposer.billName, '디지털포용법안');
    });
  });
}
