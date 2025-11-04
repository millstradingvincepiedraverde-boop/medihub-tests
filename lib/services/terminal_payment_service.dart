// lib/services/terminal_payment_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:http/http.dart' as http;

class TerminalPaymentResult {
  final bool ok;
  final String? paymentIntentId;
  final String? status; // e.g. 'succeeded', 'requires_payment_method', etc.
  final String? chargeId;
  final String? error;

  TerminalPaymentResult({
    required this.ok,
    this.paymentIntentId,
    this.status,
    this.chargeId,
    this.error,
  });
}

class TerminalPaymentService {
  TerminalPaymentService({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  // Pick the right base URL for your target (Android emulator vs desktop, etc.)
  String get _baseUrl {
    if (kIsWeb) return 'http://localhost:4242';
    if (Platform.isAndroid) return 'http://10.0.2.2:4242';
    return 'http://localhost:4242';
  }

  Future<String> createPaymentIntent({
    required int amountCents,
    String currency = 'AUD',
    Map<String, dynamic>? metadata,
  }) async {
    debugPrint(
      '\x1B[33m💰 [TerminalPaymentService] Creating payment intent for amount: $amountCents currency: $currency metadata: $metadata\x1B[0m',
    );
    final uri = Uri.parse('$_baseUrl/create_payment_intent');
    final resp = await _client
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'amount': amountCents,
            'currency': currency,
            if (metadata != null) 'metadata': metadata,
          }),
        )
        .timeout(const Duration(seconds: 20));

    debugPrint(
      '\x1B[33m💰 [TerminalPaymentService] Response: ${resp.body}\x1B[0m',
    );

    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final body = jsonDecode(resp.body) as Map<String, dynamic>;
      final pi = body['id'];
      if (pi is String && pi.isNotEmpty) return pi;
      throw Exception(
        'create_payment_intent: no payment_intent_id in response',
      );
    } else {
      throw Exception('create_payment_intent: ${resp.statusCode} ${resp.body}');
    }
  }

  Future<TerminalPaymentResult> processPayment({
    required String terminalId,
    required String paymentIntentId,
  }) async {
    final uri = Uri.parse('$_baseUrl/process_payment');
    debugPrint(
      '\x1B[33m💰 [TerminalPaymentService] Processing payment for terminal: $terminalId payment intent: $paymentIntentId\x1B[0m',
    );
    final resp = await _client
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'reader_id': terminalId,
            'payment_intent_id': paymentIntentId,
          }),
        )
        .timeout(const Duration(minutes: 2)); // give Terminal time

    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      debugPrint(
        '\x1B[33m💰 [TerminalPaymentService] Processing payment successful: ${resp.body}\x1B[0m',
      );
      final body = jsonDecode(resp.body) as Map<String, dynamic>;
      return TerminalPaymentResult(
        ok: true,
        paymentIntentId: body['payment_intent_id'] as String?,
        status: body['status'] as String?,
        chargeId: body['charge_id'] as String?,
      );
    } else {
      debugPrint(
        '\x1B[31m❌ [TerminalPaymentService] Processing payment failed: ${resp.statusCode} ${resp.body}\x1B[0m',
      );
      return TerminalPaymentResult(
        ok: false,
        error: 'process_payment: ${resp.statusCode} ${resp.body}',
      );
    }
  }

  // Creat eme a cancel payment intent
  Future<void> cancelPaymentIntent({
    required String paymentIntentId,
    String? readerId,
  }) async {
    final uri = Uri.parse('$_baseUrl/cancel_payment_intent');
    final resp = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'payment_intent_id': paymentIntentId,
        if (readerId != null) 'reader_id': readerId,
      }),
    );
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('cancel_payment_intent: ${resp.statusCode} ${resp.body}');
    }
  }

  /// One-shot helper that runs both steps.
  Future<TerminalPaymentResult> payOnTerminal({
    required int amountCents,
    required String terminalId,
    String currency = 'aud',
    Map<String, dynamic>? metadata,
  }) async {
    final pi = await createPaymentIntent(
      amountCents: amountCents,
      currency: currency,
      metadata: metadata,
    );
    return processPayment(terminalId: terminalId, paymentIntentId: pi);
  }
}
