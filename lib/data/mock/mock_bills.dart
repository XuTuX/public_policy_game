import '../../models/bill_model.dart';

/// 10개 한국어 법안 Mock 데이터
/// 다양한 분야(교육, 환경, 경제, 복지, 기술 등) 포함
class MockBills {
  MockBills._();

  static final List<BillModel> bills = [
    BillModel(
      id: 'bill_001',
      billNo: '2201001',
      billName: '초등학교 무상급식 확대법안',
      category: '교육',
      status: '본회의 상정',
      proposer: '김교육 의원 외 15인',
      proposedDate: DateTime(2026, 5, 10),
      estimatedMinutes: 2,
      summary: const LlmSummary(
        background:
            '현재 초등학교 무상급식은 일부 지역에서만 시행되고 있습니다. '
            '학부모들의 급식비 부담을 줄이고 교육 형평성을 높이기 위해 '
            '전국 모든 초등학교로 무상급식을 확대하려는 법안입니다.',
        pros: '학부모의 경제적 부담 감소, 아동 영양 불균형 해소, '
            '저소득층 아동의 식사 품질 향상, 교육 형평성 제고',
        cons: '연간 약 2조원의 추가 재정 소요, '
            '지자체 재정 부담 가중, 기존 급식 시스템 재편 필요',
      ),
    ),
    BillModel(
      id: 'bill_002',
      billNo: '2201002',
      billName: '탄소중립 기본법 개정안',
      category: '환경',
      status: '본회의 상정',
      proposer: '박환경 의원 외 22인',
      proposedDate: DateTime(2026, 5, 15),
      estimatedMinutes: 3,
      summary: const LlmSummary(
        background:
            '2050 탄소중립 목표를 달성하기 위해 2035년까지 온실가스 배출량을 '
            '40% 감축하는 중간 목표를 신설하는 개정안입니다. '
            '현재 산업계의 자발적 감축만으로는 목표 달성이 어렵다는 지적이 있습니다.',
        pros: '기후변화 대응 강화, 국제사회 약속 이행, '
            '친환경 산업 성장 촉진, 미래세대 환경권 보호',
        cons: '제조업 경쟁력 약화 우려, 에너지 비용 상승, '
            '중소기업 부담 가중, 단기적 경제 성장률 하락 가능성',
      ),
    ),
    BillModel(
      id: 'bill_003',
      billNo: '2201003',
      billName: '플랫폼 종사자 보호법',
      category: '노동',
      status: '본회의 상정',
      proposer: '이노동 의원 외 18인',
      proposedDate: DateTime(2026, 5, 20),
      estimatedMinutes: 2,
      summary: const LlmSummary(
        background:
            '배달라이더, 대리운전기사 등 플랫폼 노동자가 급증하고 있지만 '
            '근로기준법의 보호를 받지 못하는 사각지대에 놓여 있습니다. '
            '이들에게 산재보험, 최저 보수 등 기본적 보호를 제공하려는 법안입니다.',
        pros: '플랫폼 노동자 기본권 보장, 산재사고 보상 체계 마련, '
            '사회 안전망 확충, 노동시장 형평성 향상',
        cons: '플랫폼 기업 비용 증가, 서비스 이용료 인상 가능성, '
            '유연한 근무 형태 제약, 소규모 플랫폼 존립 위협',
      ),
    ),
    BillModel(
      id: 'bill_004',
      billNo: '2201004',
      billName: 'AI 기본법',
      category: '기술',
      status: '본회의 상정',
      proposer: '정기술 의원 외 25인',
      proposedDate: DateTime(2026, 6, 1),
      estimatedMinutes: 3,
      summary: const LlmSummary(
        background:
            '인공지능 기술이 빠르게 발전하면서 개인정보 침해, 알고리즘 편향 등 '
            '다양한 사회적 문제가 대두되고 있습니다. AI 개발·활용에 관한 '
            '기본 원칙과 윤리 기준을 법으로 정하려는 법안입니다.',
        pros: 'AI 산업 발전을 위한 제도적 기반 마련, 개인정보 보호 강화, '
            '알고리즘 투명성 확보, 국제 AI 규범 선도',
        cons: '과도한 규제로 AI 혁신 저해 우려, 글로벌 경쟁력 약화, '
            '스타트업 진입장벽 상승, 기술 발전 속도에 법이 따라가지 못할 가능성',
      ),
    ),
    BillModel(
      id: 'bill_005',
      billNo: '2201005',
      billName: '청년 주거 지원 특별법',
      category: '주거',
      status: '본회의 상정',
      proposer: '최주거 의원 외 20인',
      proposedDate: DateTime(2026, 6, 5),
      estimatedMinutes: 2,
      summary: const LlmSummary(
        background:
            '수도권 주거비 상승으로 청년들의 주거 부담이 심화되고 있습니다. '
            '청년 전용 공공임대주택 10만호를 공급하고, 월세 지원금을 '
            '월 30만원으로 인상하려는 법안입니다.',
        pros: '청년 주거 안정성 향상, 수도권 집중 완화 기대, '
            '1인 가구 생활 질 향상, 결혼·출산율 간접 기여',
        cons: '대규모 재정 투입 필요 (약 5조원), 기존 공공임대 입주자와의 형평성, '
            '민간 임대시장 왜곡 가능성, 도덕적 해이 우려',
      ),
    ),
    BillModel(
      id: 'bill_006',
      billNo: '2201006',
      billName: '디지털 교과서 전면 도입법',
      category: '교육',
      status: '본회의 상정',
      proposer: '한교육 의원 외 12인',
      proposedDate: DateTime(2026, 6, 8),
      estimatedMinutes: 2,
      summary: const LlmSummary(
        background:
            '종이 교과서를 단계적으로 디지털 교과서로 전환하고, '
            '모든 학생에게 학습용 태블릿을 보급하려는 법안입니다. '
            'AI 기반 맞춤형 학습을 통해 교육 격차를 해소하겠다는 취지입니다.',
        pros: 'AI 맞춤형 학습으로 교육 격차 해소, 교과서 무게 경감, '
            '실시간 교육 콘텐츠 업데이트, 환경 보호(종이 절약)',
        cons: '학생 디지털 기기 의존도 증가, 시력 건강 우려, '
            '교사 디지털 역량 격차, 해킹·개인정보 유출 위험',
      ),
    ),
    BillModel(
      id: 'bill_007',
      billNo: '2201007',
      billName: '소상공인 임대료 상한제법',
      category: '경제',
      status: '본회의 상정',
      proposer: '강경제 의원 외 19인',
      proposedDate: DateTime(2026, 6, 10),
      estimatedMinutes: 2,
      summary: const LlmSummary(
        background:
            '상가 임대료 급등으로 소상공인들이 쫓겨나는 "젠트리피케이션"이 '
            '심화되고 있습니다. 상가 임대료 인상률을 연 5% 이내로 제한하고, '
            '계약갱신청구권을 10년으로 확대하려는 법안입니다.',
        pros: '소상공인 영업 안정성 확보, 골목상권 보호, '
            '무분별한 임대료 인상 방지, 지역 경제 활성화',
        cons: '건물주 재산권 침해 논란, 신규 투자 위축, '
            '임대시장 경직화, 건물 관리 소홀 우려',
      ),
    ),
    BillModel(
      id: 'bill_008',
      billNo: '2201008',
      billName: '반려동물 복지법 개정안',
      category: '복지',
      status: '본회의 상정',
      proposer: '윤복지 의원 외 30인',
      proposedDate: DateTime(2026, 6, 12),
      estimatedMinutes: 2,
      summary: const LlmSummary(
        background:
            '반려동물 가구가 1,500만을 넘어서면서 동물 학대, 유기 문제가 '
            '심각해지고 있습니다. 동물 학대 처벌을 강화하고, '
            '반려동물 등록제를 의무화하며, 펫숍 생체판매를 금지하려는 법안입니다.',
        pros: '동물 복지 수준 향상, 유기동물 감소 기대, '
            '동물 학대 억제 효과, 입양 문화 정착',
        cons: '펫숍 업계 반발, 기존 번식업자 생계 문제, '
            '단속 인력 부족, 등록제 시스템 구축 비용',
      ),
    ),
    BillModel(
      id: 'bill_009',
      billNo: '2201009',
      billName: '65세 이상 대중교통 무상법',
      category: '복지',
      status: '본회의 상정',
      proposer: '송복지 의원 외 17인',
      proposedDate: DateTime(2026, 6, 15),
      estimatedMinutes: 2,
      summary: const LlmSummary(
        background:
            '고령화 사회에서 노인의 이동권을 보장하기 위해 '
            '65세 이상 어르신에게 모든 대중교통을 무상으로 제공하려는 법안입니다. '
            '현재 지하철만 무료이나 버스, 광역철도까지 확대하는 내용입니다.',
        pros: '노인 이동권 보장, 사회 참여 기회 확대, '
            '자가용 이용 감소로 교통 혼잡 완화, 노인 고립 예방',
        cons: '연간 약 1.5조원 재정 부담, 대중교통 운영 적자 심화, '
            '다른 세대와의 형평성 문제, 재원 마련 방안 불확실',
      ),
    ),
    BillModel(
      id: 'bill_010',
      billNo: '2201010',
      billName: '가상자산 투자자 보호법',
      category: '경제',
      status: '본회의 상정',
      proposer: '임경제 의원 외 23인',
      proposedDate: DateTime(2026, 6, 18),
      estimatedMinutes: 3,
      summary: const LlmSummary(
        background:
            '가상자산(암호화폐) 투자자가 급증하면서 사기, 해킹, 거래소 파산 등 '
            '피해가 증가하고 있습니다. 가상자산 거래소에 고객 자산 분리 보관을 '
            '의무화하고, 불공정 거래를 처벌하는 법안입니다.',
        pros: '투자자 자산 보호, 시장 투명성 향상, '
            '불공정 거래 근절, 제도권 편입으로 산업 신뢰도 상승',
        cons: '과도한 규제로 블록체인 혁신 저해, '
            '소규모 거래소 퇴출, 해외 거래소로의 자금 유출, '
            'DeFi 등 탈중앙 서비스 규제 한계',
      ),
    ),
  ];
}
