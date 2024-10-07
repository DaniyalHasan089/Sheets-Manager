import 'dart:convert';
import 'package:http/http.dart' as http;

class ClickUpService {
  final String apiToken = 'pk_49258133_AZ1ELD12YO9ONP5A4XKRN1ZP4GSRU8JJ';
  final String listId = '901802487788';

  Future<bool> createTask(Map<String, dynamic> payload) async {
    final url = 'https://api.clickup.com/api/v2/list/$listId/task';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': apiToken,
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payload),
    );

    // Debug prints to check the response
    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");

    return response.statusCode ==
        200; // Return true if the task was created successfully
  }
}
