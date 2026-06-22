import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../app/constants/app_constants.dart';
import '../models/user_answer_model.dart';

/// 로컬 저장소 서비스
/// SharedPreferences를 래핑하여 앱 데이터를 로컬에 저장
class LocalStorageService {
  SharedPreferences? _prefs;

  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // ── 온보딩 ──

  Future<bool> isOnboardingCompleted() async {
    final prefs = await _preferences;
    return prefs.getBool(AppConstants.keyOnboardingCompleted) ?? false;
  }

  Future<void> setOnboardingCompleted() async {
    final prefs = await _preferences;
    await prefs.setBool(AppConstants.keyOnboardingCompleted, true);
  }

  // ── 표결 기록 ──

  Future<void> saveVoteHistory(List<UserAnswerModel> answers) async {
    final prefs = await _preferences;
    final jsonList = answers.map((a) => jsonEncode(a.toJson())).toList();
    await prefs.setStringList(AppConstants.keyVoteHistory, jsonList);
  }

  Future<List<UserAnswerModel>> getVoteHistory() async {
    final prefs = await _preferences;
    final jsonList =
        prefs.getStringList(AppConstants.keyVoteHistory) ?? [];
    return jsonList
        .map((s) => UserAnswerModel.fromJson(jsonDecode(s)))
        .toList();
  }

  // ── 레벨 ──

  Future<int> getTotalVotes() async {
    final prefs = await _preferences;
    return prefs.getInt(AppConstants.keyTotalVotes) ?? 0;
  }

  Future<void> setTotalVotes(int count) async {
    final prefs = await _preferences;
    await prefs.setInt(AppConstants.keyTotalVotes, count);
  }

  // ── 전체 초기화 ──

  Future<void> clearAll() async {
    final prefs = await _preferences;
    await prefs.clear();
  }
}
