import 'dart:io';

import 'package:http/http.dart';
import 'package:http/io_client.dart';

///  https://habr.com/ru/articles/504914/
///  https://github.com/sb-dor/ssl_pinning/tree/master/lib
///  https://github.com/sb-dor/ssl_certificate_binary_generator

List<int> binaryCert = <int>[];

Future<Client> httpClient() async {
  final securityContext = SecurityContext(withTrustedRoots: false)
    ..setTrustedCertificatesBytes(binaryCert);
  final httpClient = HttpClient(context: securityContext);
  return IOClient(httpClient);
}
