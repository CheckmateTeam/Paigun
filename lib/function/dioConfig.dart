import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final options = BaseOptions(
  baseUrl: dotenv.env['SUPABASE_EDGE'] ?? '',
  headers: {
    'apikey': dotenv.env['SUPABASE_KEY'] ?? '',
    'Authorization': 'Bearer ${dotenv.env['SUPABASE_KEY']}',
  },
  connectTimeout: const Duration(seconds: 60),
  receiveTimeout: const Duration(seconds: 60),
);
final dio = Dio(options);
