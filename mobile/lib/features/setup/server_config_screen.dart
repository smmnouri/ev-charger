import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_url.dart';
import '../../core/services/server_config_service.dart';

enum _TestState { idle, testing, success, failed }

/// Shown at startup when no server URL is saved, or when the saved URL could
/// not be reached. The user enters the address, tests the connection, and
/// taps Continue — which seeds [serverUrlProvider] and updates
/// [serverConfigStatusProvider] to [ServerConfigStatus.connected], causing
/// the router to rebuild and advance to the normal auth flow.
class ServerConfigScreen extends ConsumerStatefulWidget {
  const ServerConfigScreen({super.key});

  @override
  ConsumerState<ServerConfigScreen> createState() => _ServerConfigScreenState();
}

class _ServerConfigScreenState extends ConsumerState<ServerConfigScreen> {
  late final TextEditingController _urlCtrl;
  _TestState _testState = _TestState.idle;
  String? _statusMessage;
  late final bool _isConnectionFailed;

  @override
  void initState() {
    super.initState();
    _isConnectionFailed =
        ref.read(serverConfigStatusProvider) ==
        ServerConfigStatus.connectionFailed;
    final saved = ref.read(serverUrlProvider);
    _urlCtrl = TextEditingController(
      text: saved.isNotEmpty ? saved : 'http://192.168.1.x:5000',
    );
    _urlCtrl.addListener(_onUrlEdited);
  }

  @override
  void dispose() {
    _urlCtrl.removeListener(_onUrlEdited);
    _urlCtrl.dispose();
    super.dispose();
  }

  void _onUrlEdited() {
    if (_testState != _TestState.idle) {
      setState(() {
        _testState = _TestState.idle;
        _statusMessage = null;
      });
    }
  }

  String _normalize(String raw) {
    return normalizeServerRoot(raw);
  }

  String? _validate(String url) {
    if (url.isEmpty) return 'URL cannot be empty';
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme || uri.scheme.isEmpty) {
      return 'A scheme is required (http:// or https://)';
    }
    if (uri.scheme != 'http' && uri.scheme != 'https') {
      return 'Scheme must be http or https';
    }
    if (!uri.hasAuthority || uri.host.isEmpty) {
      return 'URL must include a host';
    }
    if (uri.path.isNotEmpty && uri.path != '/') {
      return 'Enter only the server root without a path';
    }
    return null;
  }

  Future<void> _testConnection() async {
    final url = _normalize(_urlCtrl.text);
    final validationError = _validate(url);
    if (validationError != null) {
      setState(() {
        _testState = _TestState.failed;
        _statusMessage = validationError;
      });
      return;
    }

    setState(() {
      _testState = _TestState.testing;
      _statusMessage = null;
    });

    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
      ),
    );

    try {
      final response = await dio.get('${buildApiBaseUrl(url)}/health/ready');
      if (!mounted) return;
      if (response.statusCode == 200) {
        setState(() => _testState = _TestState.success);
      } else {
        setState(() {
          _testState = _TestState.failed;
          _statusMessage = 'Server returned status ${response.statusCode}';
        });
      }
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _testState = _TestState.failed;
        _statusMessage = _friendlyDioError(e);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _testState = _TestState.failed;
        _statusMessage = 'Unexpected error — check the URL and try again';
      });
    } finally {
      dio.close();
    }
  }

  String _friendlyDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return 'Connection timed out — check IP, port, and firewall';
      case DioExceptionType.connectionError:
        return 'Cannot reach server — check IP and port';
      default:
        return 'Connection failed';
    }
  }

  Future<void> _save() async {
    final url = _normalize(_urlCtrl.text);
    await saveServerUrl(url);
    ref.read(serverUrlProvider.notifier).state = url;
    // Triggers appRouterProvider rebuild → new GoRouter starts at splash → auth flow.
    ref.read(serverConfigStatusProvider.notifier).state =
        ServerConfigStatus.connected;
  }

  @override
  Widget build(BuildContext context) {
    final isTesting = _testState == _TestState.testing;
    final isConnected = _testState == _TestState.success;
    final isFailed = _testState == _TestState.failed;

    const brandGreen = Color(0xFF22C55E);
    const darkBg = Color(0xFF060D09);
    const surfaceBg = Color(0xFF0E1A11);

    return Scaffold(
      backgroundColor: darkBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Logo / title ──────────────────────────────────────────────
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF4ADE80), Color(0xFF16A34A)],
                      ),
                    ),
                    child: const Icon(
                      Icons.bolt_rounded,
                      color: Colors.black,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Server Setup',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'EVcharge',
                        style: TextStyle(color: Colors.white38, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // ── Connection-failed banner ──────────────────────────────────
              if (_isConnectionFailed) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F0A0A),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.35),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.wifi_off_rounded,
                        color: Color(0xFFEF4444),
                        size: 18,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Could not reach the saved server. Update the address and test again.',
                          style: TextStyle(
                            color: Color(0xFFEF4444),
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ] else ...[
                const Text(
                  'Enter the backend server address to continue.',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),
              ],

              // ── URL field ─────────────────────────────────────────────────
              TextField(
                controller: _urlCtrl,
                keyboardType: TextInputType.url,
                autocorrect: false,
                enableSuggestions: false,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Server Base URL',
                  labelStyle: const TextStyle(color: Colors.white54),
                  hintText: 'http://192.168.1.x:5000',
                  hintStyle: const TextStyle(color: Colors.white24),
                  filled: true,
                  fillColor: surfaceBg,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: isConnected
                          ? brandGreen
                          : isFailed
                          ? const Color(0xFFEF4444)
                          : Colors.white12,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: isConnected
                          ? brandGreen
                          : isFailed
                          ? const Color(0xFFEF4444)
                          : brandGreen,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Android emulator  →  http://10.0.2.2:5000\n'
                'Same WiFi network →  http://<LAN-IP>:5000',
                style: TextStyle(
                  color: Colors.white24,
                  fontSize: 11,
                  height: 1.7,
                ),
              ),
              const SizedBox(height: 28),

              // ── Test Connection ───────────────────────────────────────────
              OutlinedButton.icon(
                onPressed: isTesting ? null : _testConnection,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(
                    color: isConnected
                        ? brandGreen
                        : isFailed
                        ? const Color(0xFFEF4444)
                        : Colors.white24,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: isTesting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white38,
                        ),
                      )
                    : Icon(
                        isConnected
                            ? Icons.check_circle_outline_rounded
                            : isFailed
                            ? Icons.error_outline_rounded
                            : Icons.wifi_tethering_rounded,
                        color: isConnected
                            ? brandGreen
                            : isFailed
                            ? const Color(0xFFEF4444)
                            : Colors.white38,
                        size: 18,
                      ),
                label: Text(
                  isTesting
                      ? 'Testing…'
                      : isConnected
                      ? 'Connected'
                      : isFailed
                      ? 'Retry'
                      : 'Test Connection',
                  style: TextStyle(
                    color: isConnected
                        ? brandGreen
                        : isFailed
                        ? const Color(0xFFEF4444)
                        : Colors.white38,
                  ),
                ),
              ),

              if (isFailed && _statusMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  _statusMessage!,
                  style: const TextStyle(
                    color: Color(0xFFEF4444),
                    fontSize: 12,
                  ),
                ),
              ],
              if (isConnected) ...[
                const SizedBox(height: 8),
                const Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF22C55E),
                      size: 14,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Server is reachable',
                      style: TextStyle(color: Color(0xFF22C55E), fontSize: 12),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 24),

              // ── Continue ──────────────────────────────────────────────────
              FilledButton(
                onPressed: isConnected ? _save : null,
                style: FilledButton.styleFrom(
                  backgroundColor: brandGreen,
                  disabledBackgroundColor: Colors.white10,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isConnected ? Colors.black : Colors.white24,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
