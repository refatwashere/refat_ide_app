import 'dart:async';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class CollaborationService {
  static io.Socket? _socket;
  static final _messageStream = StreamController<Map<String, dynamic>>.broadcast();
  static String? _sessionId;
  static String? _userId;

  static Stream<Map<String, dynamic>> get messageStream => _messageStream.stream;

  static void connect(String sessionId, String userId) {
    _sessionId = sessionId;
    _userId = userId;
    
    _socket = io.io('https://collab.mobile-ide.com', <String, dynamic>{
      'transports': ['websocket'],
      'query': {'sessionId': sessionId, 'userId': userId},
    });

    _socket!.on('connect', (_) {
      _messageStream.add({'type': 'system', 'message': 'Connected to session'});
    });

    _socket!.on('codeUpdate', (data) {
      _messageStream.add({
        'type': 'codeUpdate',
        'content': data['content'],
        'sender': data['sender'],
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    });

    _socket!.on('cursorPosition', (data) {
      _messageStream.add({
        'type': 'cursorPosition',
        'position': data['position'],
        'userId': data['userId'],
        'userName': data['userName'],
      });
    });

    _socket!.on('disconnect', (_) {
      _messageStream.add({'type': 'system', 'message': 'Disconnected'});
    });

    _socket!.on('error', (err) {
      _messageStream.add({'type': 'error', 'message': err.toString()});
    });
  }

  static void disconnect() {
    _socket?.disconnect();
    _socket = null;
    _sessionId = null;
    _userId = null;
  }

  static void sendCodeUpdate(String content) {
    _socket?.emit('codeUpdate', {
      'sessionId': _sessionId,
      'userId': _userId,
      'content': content,
    });
  }

  static void sendCursorPosition(int position) {
    _socket?.emit('cursorPosition', {
      'sessionId': _sessionId,
      'userId': _userId,
      'position': position,
    });
  }

  static void startSharing(String projectId) {
    _socket?.emit('startSharing', {
      'projectId': projectId,
      'userId': _userId,
    });
  }
}

class CursorOverlay extends StatelessWidget {
  final String userId;
  final String userName;
  final Color color;
  final int position;
  final double characterWidth;
  final double lineHeight;

  const CursorOverlay({
    super.key,
    required this.userId,
    required this.userName,
    required this.color,
    required this.position,
    required this.characterWidth,
    required this.lineHeight,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate position based on character offset
    // This is simplified - real implementation would need line mapping
    final top = (position ~/ 100) * lineHeight;
    final left = (position % 100) * characterWidth;

    return Positioned(
      top: top,
      left: left,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 2,
            height: lineHeight,
            color: color,
          ),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              userName,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}