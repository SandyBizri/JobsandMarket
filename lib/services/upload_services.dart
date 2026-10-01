import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

Future<String> uploadPhoto(File file, String userId) async {
  final fileName = '$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';

  await supabase.storage
      .from('products')
      .upload(fileName, file);

  final publicUrl = supabase.storage
      .from('products')
      .getPublicUrl(fileName);

  return publicUrl;
}