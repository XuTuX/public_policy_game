import 'package:dio/dio.dart';
import '../app/constants/app_constants.dart';
import '../models/vote_model.dart';
import '../models/assembly_member_model.dart';
import '../data/mock/mock_votes.dart';
import '../data/mock/mock_members.dart';

/// 국회의원 본회의 표결정보 API 서비스
/// 현재: Mock 데이터 반환
/// 향후: 국회 공공데이터 표결정보 API 연동
class VoteApiService {
  // ignore: unused_field
  final Dio _dio;

  VoteApiService({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: AppConstants.voteApiBaseUrl,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
            ));

  /// 특정 법안의 표결 데이터 조회
  Future<List<VoteModel>> fetchVotesByBillId(String billId) async {
    if (AppConstants.useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return MockVotes.getVotesForBill(billId);
    }

    // 실제 API 연동 시:
    // final response = await _dio.get('/nojepdqqaweusdfbi', queryParameters: {
    //   'KEY': AppConstants.assemblyApiKey,
    //   'Type': 'json',
    //   'BILL_ID': billId,
    // });
    // return (response.data['row'] as List)
    //     .map((e) => VoteModel.fromJson(e))
    //     .toList();

    throw UnimplementedError('실제 API 연동이 설정되지 않았습니다');
  }

  /// 전체 국회의원 목록 조회
  Future<List<AssemblyMemberModel>> fetchMembers() async {
    if (AppConstants.useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      return MockMembers.members;
    }

    throw UnimplementedError('실제 API 연동이 설정되지 않았습니다');
  }

  /// 특정 법안에 대한 모든 의원의 표결 데이터 일괄 조회
  Future<Map<String, List<VoteModel>>> fetchAllVotes(
      List<String> billIds) async {
    if (AppConstants.useMockData) {
      await Future.delayed(const Duration(milliseconds: 600));
      final result = <String, List<VoteModel>>{};
      for (final billId in billIds) {
        result[billId] = MockVotes.getVotesForBill(billId);
      }
      return result;
    }

    throw UnimplementedError('실제 API 연동이 설정되지 않았습니다');
  }
}
