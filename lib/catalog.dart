import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class Laptop {
  final String id, title, description;
  final int price;
  const Laptop({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
  });
  factory Laptop.fromJson(Map<String, dynamic> json) {
    if (json['id'] is! String ||
        (json['id'] as String).isEmpty ||
        json['title'] is! String ||
        json['description'] is! String ||
        json['price'] is! int ||
        (json['price'] as int) < 0) {
      throw const FormatException('Invalid laptop data.');
    }
    return Laptop(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      price: json['price'],
    );
  }
  String get priceLabel => '\$${(price / 100).toStringAsFixed(2)}';
}

class CatalogRepository {
  final http.Client client;
  final String baseUrl;
  CatalogRepository({
    http.Client? client,
    this.baseUrl = const String.fromEnvironment('API_URL'),
  }) : client = client ?? http.Client();
  bool get isDemo => baseUrl.isEmpty;
  Future<List<Laptop>> load() async {
    final List<dynamic> items;
    if (isDemo) {
      items = jsonDecode(await rootBundle.loadString('assets/laptops.json'));
    } else {
      final uri = Uri.parse(
        '${baseUrl.replaceFirst(RegExp(r'/+$'), '')}/api/laptops',
      );
      if (uri.scheme != 'https' &&
          !(uri.scheme == 'http' &&
              ['localhost', '127.0.0.1', '10.0.2.2'].contains(uri.host))) {
        throw const FormatException('Use HTTPS or a local development server.');
      }
      final response = await client
          .get(uri)
          .timeout(const Duration(seconds: 12));
      if (response.statusCode != 200) {
        throw Exception('Catalog unavailable (${response.statusCode}).');
      }
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      items = data['items'] as List<dynamic>;
    }
    final laptops = items
        .map((x) => Laptop.fromJson(x as Map<String, dynamic>))
        .toList();
    if (laptops.map((x) => x.id).toSet().length != laptops.length) {
      throw const FormatException('Duplicate laptop identifiers.');
    }
    return laptops;
  }

  void close() => client.close();
}
