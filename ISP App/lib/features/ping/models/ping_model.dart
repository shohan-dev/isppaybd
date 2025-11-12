class PingResponse {
  final String status;
  final List<PingData> data;
  final String averageLatency;
  final PingPackets packets;

  PingResponse({
    required this.status,
    required this.data,
    required this.averageLatency,
    required this.packets,
  });

  factory PingResponse.fromJson(Map<String, dynamic> json) {
    return PingResponse(
      status: json['status'] ?? '',
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => PingData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      averageLatency: json['average_latency'] ?? 'N/A',
      packets: PingPackets.fromJson(json['packets'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': data.map((e) => e.toJson()).toList(),
      'average_latency': averageLatency,
      'packets': packets.toJson(),
    };
  }
}

class PingData {
  final String seq;
  final String host;
  final String status;
  final String sent;
  final String received;
  final String packetLoss;
  final String? time; // For successful pings

  PingData({
    required this.seq,
    required this.host,
    required this.status,
    required this.sent,
    required this.received,
    required this.packetLoss,
    this.time,
  });

  factory PingData.fromJson(Map<String, dynamic> json) {
    return PingData(
      seq: json['seq']?.toString() ?? '',
      host: json['host'] ?? '',
      status: json['status'] ?? '',
      sent: json['sent']?.toString() ?? '',
      received: json['received']?.toString() ?? '',
      packetLoss: json['packet-loss']?.toString() ?? '',
      time: json['time']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'seq': seq,
      'host': host,
      'status': status,
      'sent': sent,
      'received': received,
      'packet-loss': packetLoss,
      if (time != null) 'time': time,
    };
  }

  bool get isTimeout => status.toLowerCase() == 'timeout';
  bool get isSuccess => !isTimeout;
}

class PingPackets {
  final int sent;
  final int received;
  final String loss;

  PingPackets({required this.sent, required this.received, required this.loss});

  factory PingPackets.fromJson(Map<String, dynamic> json) {
    return PingPackets(
      sent: json['sent'] ?? 0,
      received: json['received'] ?? 0,
      loss: json['loss']?.toString() ?? '0%',
    );
  }

  Map<String, dynamic> toJson() {
    return {'sent': sent, 'received': received, 'loss': loss};
  }

  double get lossPercentage {
    final lossStr = loss.replaceAll('%', '').trim();
    return double.tryParse(lossStr) ?? 0.0;
  }
}
