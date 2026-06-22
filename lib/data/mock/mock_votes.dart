import '../../models/vote_model.dart';

/// 20명 × 10개 법안 = 200개 표결 Mock 데이터
/// 정당별 투표 성향 패턴 반영
class MockVotes {
  MockVotes._();

  /// 특정 법안의 표결 데이터 조회
  static List<VoteModel> getVotesForBill(String billId) {
    return _allVotes.where((v) => v.billId == billId).toList();
  }

  /// 특정 의원의 전체 표결 데이터 조회
  static List<VoteModel> getVotesForMember(String memberName) {
    return _allVotes.where((v) => v.memberName == memberName).toList();
  }

  static final List<VoteModel> _allVotes = [
    // ═══════════════════════════════════════
    // bill_001: 초등학교 무상급식 확대법안
    // 민주당: 대부분 찬성 / 국민의힘: 대부분 반대
    // ═══════════════════════════════════════
    ..._generateVotesForBill('bill_001', {
      '김민주': VoteType.yes,   '이진보': VoteType.yes,
      '박민생': VoteType.yes,   '정평등': VoteType.yes,
      '한복지': VoteType.yes,   '오연대': VoteType.yes,
      '유시민': VoteType.yes,
      '최보수': VoteType.no,    '강안보': VoteType.no,
      '조경제': VoteType.no,    '윤질서': VoteType.no,
      '서자유': VoteType.no,    '임시장': VoteType.no,
      '배국방': VoteType.abstain,
      '신개혁': VoteType.yes,   '남중도': VoteType.abstain,
      '홍정의': VoteType.yes,   '문환경': VoteType.yes,
      '양미래': VoteType.yes,   '하독립': VoteType.yes,
    }),

    // ═══════════════════════════════════════
    // bill_002: 탄소중립 기본법 개정안
    // ═══════════════════════════════════════
    ..._generateVotesForBill('bill_002', {
      '김민주': VoteType.yes,   '이진보': VoteType.yes,
      '박민생': VoteType.yes,   '정평등': VoteType.yes,
      '한복지': VoteType.yes,   '오연대': VoteType.yes,
      '유시민': VoteType.yes,
      '최보수': VoteType.no,    '강안보': VoteType.no,
      '조경제': VoteType.no,    '윤질서': VoteType.no,
      '서자유': VoteType.abstain, '임시장': VoteType.no,
      '배국방': VoteType.no,
      '신개혁': VoteType.yes,   '남중도': VoteType.yes,
      '홍정의': VoteType.yes,   '문환경': VoteType.yes,
      '양미래': VoteType.yes,   '하독립': VoteType.abstain,
    }),

    // ═══════════════════════════════════════
    // bill_003: 플랫폼 종사자 보호법
    // ═══════════════════════════════════════
    ..._generateVotesForBill('bill_003', {
      '김민주': VoteType.yes,   '이진보': VoteType.yes,
      '박민생': VoteType.yes,   '정평등': VoteType.yes,
      '한복지': VoteType.yes,   '오연대': VoteType.yes,
      '유시민': VoteType.yes,
      '최보수': VoteType.no,    '강안보': VoteType.no,
      '조경제': VoteType.no,    '윤질서': VoteType.abstain,
      '서자유': VoteType.no,    '임시장': VoteType.no,
      '배국방': VoteType.no,
      '신개혁': VoteType.yes,   '남중도': VoteType.yes,
      '홍정의': VoteType.yes,   '문환경': VoteType.yes,
      '양미래': VoteType.abstain, '하독립': VoteType.yes,
    }),

    // ═══════════════════════════════════════
    // bill_004: AI 기본법
    // 초당적으로 지지가 높은 법안
    // ═══════════════════════════════════════
    ..._generateVotesForBill('bill_004', {
      '김민주': VoteType.yes,   '이진보': VoteType.yes,
      '박민생': VoteType.yes,   '정평등': VoteType.yes,
      '한복지': VoteType.abstain, '오연대': VoteType.yes,
      '유시민': VoteType.yes,
      '최보수': VoteType.yes,   '강안보': VoteType.yes,
      '조경제': VoteType.yes,   '윤질서': VoteType.yes,
      '서자유': VoteType.yes,   '임시장': VoteType.yes,
      '배국방': VoteType.abstain,
      '신개혁': VoteType.yes,   '남중도': VoteType.yes,
      '홍정의': VoteType.no,    '문환경': VoteType.abstain,
      '양미래': VoteType.yes,   '하독립': VoteType.yes,
    }),

    // ═══════════════════════════════════════
    // bill_005: 청년 주거 지원 특별법
    // ═══════════════════════════════════════
    ..._generateVotesForBill('bill_005', {
      '김민주': VoteType.yes,   '이진보': VoteType.yes,
      '박민생': VoteType.yes,   '정평등': VoteType.yes,
      '한복지': VoteType.yes,   '오연대': VoteType.yes,
      '유시민': VoteType.yes,
      '최보수': VoteType.no,    '강안보': VoteType.no,
      '조경제': VoteType.no,    '윤질서': VoteType.no,
      '서자유': VoteType.abstain, '임시장': VoteType.no,
      '배국방': VoteType.no,
      '신개혁': VoteType.yes,   '남중도': VoteType.abstain,
      '홍정의': VoteType.yes,   '문환경': VoteType.yes,
      '양미래': VoteType.yes,   '하독립': VoteType.yes,
    }),

    // ═══════════════════════════════════════
    // bill_006: 디지털 교과서 전면 도입법
    // 초당적이지만 소수 반대
    // ═══════════════════════════════════════
    ..._generateVotesForBill('bill_006', {
      '김민주': VoteType.yes,   '이진보': VoteType.yes,
      '박민생': VoteType.yes,   '정평등': VoteType.abstain,
      '한복지': VoteType.yes,   '오연대': VoteType.yes,
      '유시민': VoteType.no,
      '최보수': VoteType.yes,   '강안보': VoteType.yes,
      '조경제': VoteType.yes,   '윤질서': VoteType.yes,
      '서자유': VoteType.yes,   '임시장': VoteType.yes,
      '배국방': VoteType.yes,
      '신개혁': VoteType.yes,   '남중도': VoteType.yes,
      '홍정의': VoteType.no,    '문환경': VoteType.no,
      '양미래': VoteType.yes,   '하독립': VoteType.abstain,
    }),

    // ═══════════════════════════════════════
    // bill_007: 소상공인 임대료 상한제법
    // ═══════════════════════════════════════
    ..._generateVotesForBill('bill_007', {
      '김민주': VoteType.yes,   '이진보': VoteType.yes,
      '박민생': VoteType.yes,   '정평등': VoteType.yes,
      '한복지': VoteType.yes,   '오연대': VoteType.yes,
      '유시민': VoteType.yes,
      '최보수': VoteType.no,    '강안보': VoteType.no,
      '조경제': VoteType.no,    '윤질서': VoteType.no,
      '서자유': VoteType.no,    '임시장': VoteType.abstain,
      '배국방': VoteType.no,
      '신개혁': VoteType.yes,   '남중도': VoteType.yes,
      '홍정의': VoteType.yes,   '문환경': VoteType.yes,
      '양미래': VoteType.abstain, '하독립': VoteType.yes,
    }),

    // ═══════════════════════════════════════
    // bill_008: 반려동물 복지법 개정안
    // 초당적 지지가 높은 법안
    // ═══════════════════════════════════════
    ..._generateVotesForBill('bill_008', {
      '김민주': VoteType.yes,   '이진보': VoteType.yes,
      '박민생': VoteType.yes,   '정평등': VoteType.yes,
      '한복지': VoteType.yes,   '오연대': VoteType.yes,
      '유시민': VoteType.yes,
      '최보수': VoteType.yes,   '강안보': VoteType.abstain,
      '조경제': VoteType.yes,   '윤질서': VoteType.yes,
      '서자유': VoteType.yes,   '임시장': VoteType.yes,
      '배국방': VoteType.no,
      '신개혁': VoteType.yes,   '남중도': VoteType.yes,
      '홍정의': VoteType.yes,   '문환경': VoteType.yes,
      '양미래': VoteType.yes,   '하독립': VoteType.yes,
    }),

    // ═══════════════════════════════════════
    // bill_009: 65세 이상 대중교통 무상법
    // ═══════════════════════════════════════
    ..._generateVotesForBill('bill_009', {
      '김민주': VoteType.yes,   '이진보': VoteType.yes,
      '박민생': VoteType.yes,   '정평등': VoteType.yes,
      '한복지': VoteType.yes,   '오연대': VoteType.yes,
      '유시민': VoteType.abstain,
      '최보수': VoteType.yes,   '강안보': VoteType.yes,
      '조경제': VoteType.no,    '윤질서': VoteType.no,
      '서자유': VoteType.yes,   '임시장': VoteType.abstain,
      '배국방': VoteType.yes,
      '신개혁': VoteType.abstain, '남중도': VoteType.no,
      '홍정의': VoteType.yes,   '문환경': VoteType.yes,
      '양미래': VoteType.yes,   '하독립': VoteType.no,
    }),

    // ═══════════════════════════════════════
    // bill_010: 가상자산 투자자 보호법
    // ═══════════════════════════════════════
    ..._generateVotesForBill('bill_010', {
      '김민주': VoteType.yes,   '이진보': VoteType.abstain,
      '박민생': VoteType.yes,   '정평등': VoteType.yes,
      '한복지': VoteType.yes,   '오연대': VoteType.yes,
      '유시민': VoteType.yes,
      '최보수': VoteType.yes,   '강안보': VoteType.yes,
      '조경제': VoteType.yes,   '윤질서': VoteType.yes,
      '서자유': VoteType.yes,   '임시장': VoteType.yes,
      '배국방': VoteType.yes,
      '신개혁': VoteType.yes,   '남중도': VoteType.yes,
      '홍정의': VoteType.no,    '문환경': VoteType.no,
      '양미래': VoteType.yes,   '하독립': VoteType.abstain,
    }),
  ];

  /// 의원별-법안별 표결을 VoteModel 리스트로 생성하는 헬퍼
  static List<VoteModel> _generateVotesForBill(
    String billId,
    Map<String, VoteType> memberVotes,
  ) {
    // 의원 이름 → 정당, 지역구 매핑
    const memberInfo = {
      '김민주': {'party': '더불어민주당', 'district': '서울 강남구 갑'},
      '이진보': {'party': '더불어민주당', 'district': '서울 마포구'},
      '박민생': {'party': '더불어민주당', 'district': '경기 성남시 분당구 갑'},
      '정평등': {'party': '더불어민주당', 'district': '인천 남동구 갑'},
      '한복지': {'party': '더불어민주당', 'district': '광주 동구 남구'},
      '오연대': {'party': '더불어민주당', 'district': '전남 목포시'},
      '유시민': {'party': '더불어민주당', 'district': '서울 종로구'},
      '최보수': {'party': '국민의힘', 'district': '서울 서초구 갑'},
      '강안보': {'party': '국민의힘', 'district': '부산 해운대구 갑'},
      '조경제': {'party': '국민의힘', 'district': '대구 수성구 갑'},
      '윤질서': {'party': '국민의힘', 'district': '경북 포항시 남구'},
      '서자유': {'party': '국민의힘', 'district': '대전 유성구 갑'},
      '임시장': {'party': '국민의힘', 'district': '경남 창원시 성산구'},
      '배국방': {'party': '국민의힘', 'district': '부산 연제구'},
      '신개혁': {'party': '개혁신당', 'district': '서울 송파구 갑'},
      '남중도': {'party': '개혁신당', 'district': '경기 수원시 장안구'},
      '홍정의': {'party': '녹색정의당', 'district': '비례대표'},
      '문환경': {'party': '녹색정의당', 'district': '비례대표'},
      '양미래': {'party': '새미래당', 'district': '비례대표'},
      '하독립': {'party': '무소속', 'district': '제주시 갑'},
    };

    return memberVotes.entries.map((entry) {
      final info = memberInfo[entry.key]!;
      return VoteModel(
        billId: billId,
        memberName: entry.key,
        party: info['party']!,
        district: info['district']!,
        voteType: entry.value,
      );
    }).toList();
  }
}
