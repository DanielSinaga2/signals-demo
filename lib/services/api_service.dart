import 'package:dio/dio.dart';

class ApiService {
  ApiService._();
  static final instance = ApiService._();
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://pos.cicd.web.id',
      headers: {'Accept': 'application/json'},
    ),
  );
  void setAccessToken(String? token) {
    if (token == null || token.isEmpty) {
      dio.options.headers.remove('Authorization');
    } else {
      dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  /// Directus returns the uploaded asset UUID in `data.id`.
  Future<String> uploadImage(List<int> bytes, String filename) async {
    final response = await dio.post(
      '/files',
      data: FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: filename),
      }),
    );
    final data = response.data is Map ? response.data['data'] : null;
    final id = data is Map ? data['id']?.toString() : null;
    if (id == null || id.isEmpty) {
      throw const FormatException(
        'ID gambar tidak tersedia pada respons upload.',
      );
    }
    return id;
  }

  String errorMessage(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      final errors = data is Map ? data['errors'] : null;
      final apiMessage =
          errors is List && errors.isNotEmpty && errors.first is Map
          ? (errors.first as Map)['message']?.toString()
          : null;
      if (apiMessage != null && apiMessage.isNotEmpty) return apiMessage;
      switch (error.response?.statusCode) {
        case 400:
          return 'Data yang dikirim tidak valid.';
        case 401:
          return 'Session atau kredensial tidak valid.';
        case 403:
          return 'Akses ditolak.';
        case 404:
          return 'Data tidak ditemukan.';
        default:
          return (error.response?.statusCode ?? 0) >= 500
              ? 'Server sedang mengalami masalah.'
              : 'Tidak dapat terhubung ke server.';
      }
    }
    return 'Terjadi kesalahan yang tidak diketahui.';
  }
}
