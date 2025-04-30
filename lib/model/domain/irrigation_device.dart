// model/domain/irrigation_device.dart
class IrrigationDevice {
  final String id;
  final String ipAddress;
  final Map<String, dynamic> status;
  final bool isConnected;

  IrrigationDevice({
    required this.id,
    required this.ipAddress,
    required this.status,
    this.isConnected = false,
  });

  factory IrrigationDevice.fromJson(Map<String, dynamic> json) {
    return IrrigationDevice(
      id: json['id'] ?? '',
      ipAddress: json['ipAddress'] ?? '',
      status: json['status'] ?? {},
      isConnected: json['isConnected'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ipAddress': ipAddress,
      'status': status,
      'isConnected': isConnected,
    };
  }
} 