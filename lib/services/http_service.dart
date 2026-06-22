import 'package:dio/dio.dart';

/// 앱 전체에서 공유되는 단일 Dio 인스턴스를 관리하는 싱글톤 HTTP 서비스
class HttpService {
  static final HttpService _instance = HttpService._internal();
  late final Dio dio;

  factory HttpService() {
    return _instance;
  }

  HttpService._internal() {
    dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
      },
    ));
  }
}
