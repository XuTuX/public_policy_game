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
        pros:
            '학부모의 경제적 부담 감소, 아동 영양 불균형 해소, '
            '저소득층 아동의 식사 품질 향상, 교육 형평성 제고',
        cons:
            '연간 약 2조원의 추가 재정 소요, '
            '지자체 재정 부담 가중, 기존 급식 시스템 재편 필요',
      ),
      narrative: const BillNarrative(
        backgroundDialogue:
            '급식비 고지서가 나올 때마다 한숨을 쉬는 학부모와, 지역에 따라 다른 급식을 먹는 아이들의 모습입니다.',
        positiveDialogue:
            '이제 부모님의 소득과 관계없이 친구들과 같은 점심을 먹을 수 있어요. 우리 집도 급식비 걱정을 덜었고요.',
        concernDialogue:
            '전국 확대에 필요한 예산이 커서 다른 교육 사업이 줄어들 수 있습니다. 조리 시설과 인력도 지금 바로 확충해야 합니다.',
        positiveImpact: '급식비·아동 영양 격차 완화',
        concernImpact: '연 2조원 추가 재정 부담',
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
        pros:
            '기후변화 대응 강화, 국제사회 약속 이행, '
            '친환경 산업 성장 촉진, 미래세대 환경권 보호',
        cons:
            '제조업 경쟁력 약화 우려, 에너지 비용 상승, '
            '중소기업 부담 가중, 단기적 경제 성장률 하락 가능성',
      ),
      narrative: const BillNarrative(
        backgroundDialogue:
            '폭염과 폭우가 반복되지만 산업계의 자발적 감축만으로는 2050년 목표에 도달하기 어렵다는 경고가 나왔습니다.',
        positiveDialogue:
            '아이와 걷는 거리에 나무가 늘고 공기가 나아졌어요. 친환경 설비를 만드는 새 일자리도 생겼습니다.',
        concernDialogue:
            '공장의 전기와 설비 교체 비용이 급격히 늘었습니다. 특히 작은 공장은 납품 단가를 맞추기 어렵습니다.',
        positiveImpact: '탄소 감축·친환경 일자리 확대',
        concernImpact: '제조업 에너지·전환 비용 상승',
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
        pros:
            '플랫폼 노동자 기본권 보장, 산재사고 보상 체계 마련, '
            '사회 안전망 확충, 노동시장 형평성 향상',
        cons:
            '플랫폼 기업 비용 증가, 서비스 이용료 인상 가능성, '
            '유연한 근무 형태 제약, 소규모 플랫폼 존립 위협',
      ),
      narrative: const BillNarrative(
        backgroundDialogue:
            '배달 중 다쳐도 산재 보호를 받지 못하고, 콜이 없는 날은 최저 소득조차 보장되지 않는 노동자가 늘고 있습니다.',
        positiveDialogue:
            '사고 후 치료비를 혼자 감당하지 않아도 돼요. 최소 보수 기준도 생겨서 수입을 예측할 수 있어요.',
        concernDialogue:
            '보험료와 최저 보수 비용을 버티기 어려운 작은 플랫폼은 수수료를 올리거나 서비스를 접을 수 있습니다.',
        positiveImpact: '산재 보호·최저 보수 보장',
        concernImpact: '수수료 인상·소규모 플랫폼 위축',
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
        pros:
            'AI 산업 발전을 위한 제도적 기반 마련, 개인정보 보호 강화, '
            '알고리즘 투명성 확보, 국제 AI 규범 선도',
        cons:
            '과도한 규제로 AI 혁신 저해 우려, 글로벌 경쟁력 약화, '
            '스타트업 진입장벽 상승, 기술 발전 속도에 법이 따라가지 못할 가능성',
      ),
      narrative: const BillNarrative(
        backgroundDialogue:
            'AI가 채용과 대출 심사에 쓰이지만, 왜 탈락했는지 알 수 없고 개인정보가 어떻게 쓰였는지도 불분명한 사례가 늘었습니다.',
        positiveDialogue:
            'AI가 내린 결정의 기준을 확인하고 이의를 제기할 수 있게 됐어요. 개인정보 보호 책임도 명확해졌고요.',
        concernDialogue: '스타트업이 모든 규제 문서와 검증 비용을 감당하면 제품을 시험할 기회조차 줄어들 수 있습니다.',
        positiveImpact: 'AI 투명성·개인정보 보호 강화',
        concernImpact: '스타트업 규제 비용·진입장벽 상승',
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
        pros:
            '청년 주거 안정성 향상, 수도권 집중 완화 기대, '
            '1인 가구 생활 질 향상, 결혼·출산율 간접 기여',
        cons:
            '대규모 재정 투입 필요 (약 5조원), 기존 공공임대 입주자와의 형평성, '
            '민간 임대시장 왜곡 가능성, 도덕적 해이 우려',
      ),
      narrative: const BillNarrative(
        backgroundDialogue:
            '월세와 보증금이 소득의 반 이상을 차지해 독립을 포기하거나 멀리 이사하는 청년이 늘었습니다.',
        positiveDialogue:
            '월세 지원을 받아 통근 시간을 줄이고, 남은 돈으로 자격증 공부도 시작했어요. 내 집이 생기니 미래 계획을 세울 수 있어요.',
        concernDialogue:
            '기존 공공임대를 기다리던 가구와의 형평성 논란이 있습니다. 일부 지역은 월세 지원만큼 임대료가 올라갈 수도 있습니다.',
        positiveImpact: '청년 주거 안정·독립 지원',
        concernImpact: '5조원 재정·임대시장 왜곡 우려',
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
        pros:
            'AI 맞춤형 학습으로 교육 격차 해소, 교과서 무게 경감, '
            '실시간 교육 콘텐츠 업데이트, 환경 보호(종이 절약)',
        cons:
            '학생 디지털 기기 의존도 증가, 시력 건강 우려, '
            '교사 디지털 역량 격차, 해킹·개인정보 유출 위험',
      ),
      narrative: const BillNarrative(
        backgroundDialogue:
            '지역과 가정 형편에 따라 디지털 학습 환경이 다르고, 종이 교과서만으로는 각 학생의 속도에 맞춘 수업이 어렵습니다.',
        positiveDialogue:
            '내가 틀린 문제를 AI가 바로 설명해줘서 수업을 따라가기 쉬워졌어요. 무거운 교과서도 안 들고 다녀요.',
        concernDialogue:
            '오랜 화면 사용으로 시력과 집중력을 걱정하는 학부모가 많습니다. 교사의 연수와 학생 데이터 보호도 준비해야 합니다.',
        positiveImpact: '맞춤형 학습·콘텐츠 접근성 향상',
        concernImpact: '화면 의존·학습 데이터 유출 위험',
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
        pros:
            '소상공인 영업 안정성 확보, 골목상권 보호, '
            '무분별한 임대료 인상 방지, 지역 경제 활성화',
        cons:
            '건물주 재산권 침해 논란, 신규 투자 위축, '
            '임대시장 경직화, 건물 관리 소홀 우려',
      ),
      narrative: const BillNarrative(
        backgroundDialogue:
            '매출은 그대로인데 임대료가 크게 올라 오랫동안 장사한 가게를 떠나야 하는 소상공인이 늘었습니다.',
        positiveDialogue: '다음 달 임대료가 갑자기 틀지 않으니 직원을 계속 고용하고 가게에 투자할 수 있게 됐어요.',
        concernDialogue:
            '수리비와 이자는 올랐지만 임대료 조정이 어렵습니다. 상가 신축과 리모델링 투자가 줄어들 수 있습니다.',
        positiveImpact: '소상공인 영업 안정·상권 보호',
        concernImpact: '건물 투자 위축·재산권 논란',
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
        pros:
            '동물 복지 수준 향상, 유기동물 감소 기대, '
            '동물 학대 억제 효과, 입양 문화 정착',
        cons:
            '펫숍 업계 반발, 기존 번식업자 생계 문제, '
            '단속 인력 부족, 등록제 시스템 구축 비용',
      ),
      narrative: const BillNarrative(
        backgroundDialogue:
            '유기된 동물은 늘었지만 소유자를 확인하기 어렵고, 학대 사건의 처벌이 약해 재발을 막지 못한다는 지적이 나왔습니다.',
        positiveDialogue:
            '등록 정보 덕분에 잃어버린 강아지가 빨리 집으로 돌아왔어요. 충동구매보다 입양을 고려하는 사람도 늘었고요.',
        concernDialogue:
            '생체판매 금지로 펫숍과 번식업 종사자의 생계 대책이 필요합니다. 의무 등록을 검사할 인력과 시스템 비용도 큽니다.',
        positiveImpact: '유기·학대 예방·입양 문화 확대',
        concernImpact: '관련 업계 생계·등록제 운영 비용',
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
        pros:
            '노인 이동권 보장, 사회 참여 기회 확대, '
            '자가용 이용 감소로 교통 혼잡 완화, 노인 고립 예방',
        cons:
            '연간 약 1.5조원 재정 부담, 대중교통 운영 적자 심화, '
            '다른 세대와의 형평성 문제, 재원 마련 방안 불확실',
      ),
      narrative: const BillNarrative(
        backgroundDialogue:
            '지하철이 없는 지역의 어르신은 병원과 복지관에 가는 버스비도 부담이 되어 외출을 줄이고 있습니다.',
        positiveDialogue:
            '버스비 걱정 없이 병원과 친구 모임에 다닐 수 있어요. 집에 혼자 있는 날이 확실히 줄었습니다.',
        concernDialogue:
            '무상 이용 범위가 늘면 지자체와 운수사의 적자가 커집니다. 혼잡 시간대 수송력과 다른 세대와의 형평성도 따져야 합니다.',
        positiveImpact: '어르신 이동권·사회 참여 확대',
        concernImpact: '연 1.5조원 운영 부담·세대 형평성',
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
        pros:
            '투자자 자산 보호, 시장 투명성 향상, '
            '불공정 거래 근절, 제도권 편입으로 산업 신뢰도 상승',
        cons:
            '과도한 규제로 블록체인 혁신 저해, '
            '소규모 거래소 퇴출, 해외 거래소로의 자금 유출, '
            'DeFi 등 탈중앙 서비스 규제 한계',
      ),
      narrative: const BillNarrative(
        backgroundDialogue:
            '거래소가 파산하거나 해킹당해 투자금을 되찾지 못하고, 시세 조종 피해를 입은 투자자가 늘었습니다.',
        positiveDialogue:
            '거래소가 내 자산을 따로 보관하니 회사가 어려워져도 돈을 보호받을 수 있어요. 이상 거래 감시도 강화됐고요.',
        concernDialogue:
            '작은 거래소는 보관·보안 기준을 맞추는 비용을 감당하기 어렵습니다. 규제받지 않는 해외 서비스로 이용자가 옮겨갈 수도 있습니다.',
        positiveImpact: '고객 자산 보호·불공정 거래 억제',
        concernImpact: '소규모 거래소 퇴출·해외 유출 가능성',
      ),
    ),
  ];
}
