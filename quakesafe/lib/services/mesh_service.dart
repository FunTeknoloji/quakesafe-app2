import 'package:nearby_connections/nearby_connections.dart';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';

class MeshService {
  static final MeshService _instance = MeshService._internal();
  factory MeshService() => _instance;
  MeshService._internal();

  final Strategy strategy = Strategy.P2P_CLUSTER;
  Map<String, ConnectionInfo> endpointMap = {};
  Function(String, String)? globalMessageHandler;

  Future<bool> startMesh(String username, Function(String, String) onMessageReceived) async {
    globalMessageHandler = onMessageReceived;
    try {
      bool a = await Nearby().startAdvertising(
        username,
        strategy,
        onConnectionInitiated: (id, info) => _onConnectionInitiated(id, info),
        onConnectionResult: (id, status) => _onConnectionResult(id, status),
        onDisconnected: (id) => endpointMap.remove(id),
      );

      bool d = await Nearby().startDiscovery(
        username,
        strategy,
        onEndpointFound: (id, name, serviceId) {
          Nearby().requestConnection(username, id,
            onConnectionInitiated: (id, info) => _onConnectionInitiated(id, info),
            onConnectionResult: (id, status) => _onConnectionResult(id, status),
            onDisconnected: (id) => endpointMap.remove(id),
          );
        },
        onEndpointLost: (id) {},
      );

      return a && d;
    } catch (e) {
      debugPrint("Mesh error: $e");
      return false;
    }
  }

  void _onConnectionInitiated(String id, ConnectionInfo info) {
    endpointMap[id] = info;
    Nearby().acceptConnection(id, onPayloadReceived: (endpointId, payload) {
       if (payload.type == PayloadType.BYTES) {
          String msg = String.fromCharCodes(payload.bytes!);
          String senderName = endpointMap[endpointId]?.endpointName ?? "Bilinmeyen";
          globalMessageHandler?.call(senderName, msg);
       }
    }, onPayloadTransferUpdate: (endpointId, update) {
       // Status updates (optional but good for stability)
    });
  }

  void _onConnectionResult(String id, Status status) {
    if (status != Status.CONNECTED) {
      endpointMap.remove(id);
    }
  }

  void sendMeshMessage(String message) {
    endpointMap.keys.forEach((id) {
      Nearby().sendBytesPayload(id, Uint8List.fromList(message.codeUnits));
    });
  }

  void stopMesh() {
    Nearby().stopAdvertising();
    Nearby().stopDiscovery();
    Nearby().stopAllEndpoints();
    endpointMap.clear();
  }
}
