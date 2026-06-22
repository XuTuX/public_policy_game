import '../../models/assembly_member_model.dart';

/// 20명 가상 국회의원 Mock 데이터
/// 6개 정당 분포, 다양한 지역구
class MockMembers {
  MockMembers._();

  static final List<AssemblyMemberModel> members = [
    // ── 더불어민주당 (7명) ──
    const AssemblyMemberModel(
      id: 'member_001', name: '김민주', party: '더불어민주당', district: '서울 강남구 갑',
    ),
    const AssemblyMemberModel(
      id: 'member_002', name: '이진보', party: '더불어민주당', district: '서울 마포구',
    ),
    const AssemblyMemberModel(
      id: 'member_003', name: '박민생', party: '더불어민주당', district: '경기 성남시 분당구 갑',
    ),
    const AssemblyMemberModel(
      id: 'member_004', name: '정평등', party: '더불어민주당', district: '인천 남동구 갑',
    ),
    const AssemblyMemberModel(
      id: 'member_005', name: '한복지', party: '더불어민주당', district: '광주 동구 남구',
    ),
    const AssemblyMemberModel(
      id: 'member_006', name: '오연대', party: '더불어민주당', district: '전남 목포시',
    ),
    const AssemblyMemberModel(
      id: 'member_007', name: '유시민', party: '더불어민주당', district: '서울 종로구',
    ),

    // ── 국민의힘 (7명) ──
    const AssemblyMemberModel(
      id: 'member_008', name: '최보수', party: '국민의힘', district: '서울 서초구 갑',
    ),
    const AssemblyMemberModel(
      id: 'member_009', name: '강안보', party: '국민의힘', district: '부산 해운대구 갑',
    ),
    const AssemblyMemberModel(
      id: 'member_010', name: '조경제', party: '국민의힘', district: '대구 수성구 갑',
    ),
    const AssemblyMemberModel(
      id: 'member_011', name: '윤질서', party: '국민의힘', district: '경북 포항시 남구',
    ),
    const AssemblyMemberModel(
      id: 'member_012', name: '서자유', party: '국민의힘', district: '대전 유성구 갑',
    ),
    const AssemblyMemberModel(
      id: 'member_013', name: '임시장', party: '국민의힘', district: '경남 창원시 성산구',
    ),
    const AssemblyMemberModel(
      id: 'member_014', name: '배국방', party: '국민의힘', district: '부산 연제구',
    ),

    // ── 개혁신당 (2명) ──
    const AssemblyMemberModel(
      id: 'member_015', name: '신개혁', party: '개혁신당', district: '서울 송파구 갑',
    ),
    const AssemblyMemberModel(
      id: 'member_016', name: '남중도', party: '개혁신당', district: '경기 수원시 장안구',
    ),

    // ── 녹색정의당 (2명) ──
    const AssemblyMemberModel(
      id: 'member_017', name: '홍정의', party: '녹색정의당', district: '비례대표',
    ),
    const AssemblyMemberModel(
      id: 'member_018', name: '문환경', party: '녹색정의당', district: '비례대표',
    ),

    // ── 새미래당 (1명) ──
    const AssemblyMemberModel(
      id: 'member_019', name: '양미래', party: '새미래당', district: '비례대표',
    ),

    // ── 무소속 (1명) ──
    const AssemblyMemberModel(
      id: 'member_020', name: '하독립', party: '무소속', district: '제주시 갑',
    ),
  ];
}
