import 'package:flutter/material.dart';

class Intervention {
  // Client information
  String clientId;
  String clientName;
  String address;
  String phone;
  String email;
  String contactPerson;

  // Intervention information
  String referenceNumber;
  DateTime? date;
  TimeOfDay? time;
  String interventionType;
  String estimatedDuration;
  String actualDuration;
  String technicianName;
  String technicianAddress;

  Intervention({
    this.clientId = '',
    this.clientName = '',
    this.address = '',
    this.phone = '',
    this.email = '',
    this.contactPerson = '',
    this.referenceNumber = '',
    this.date,
    this.time,
    this.interventionType = '',
    this.estimatedDuration = '',
    this.actualDuration = '',
    this.technicianName = '',
    this.technicianAddress = '',
  });

  factory Intervention.fromJson(Map<String, dynamic> json) {
    return Intervention(
      clientId: json['clientId'] ?? '',
      clientName: json['clientName'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      contactPerson: json['contactPerson'] ?? '',
      referenceNumber: json['referenceNumber'] ?? '',
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      time: json['time'] != null ? _parseTime(json['time']) : null,
      interventionType: json['interventionType'] ?? '',
      estimatedDuration: json['estimatedDuration'] ?? '',
      actualDuration: json['actualDuration'] ?? '',
      technicianName: json['technicianName'] ?? '',
      technicianAddress: json['technicianAddress'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clientId': clientId,
      'clientName': clientName,
      'address': address,
      'phone': phone,
      'email': email,
      'contactPerson': contactPerson,
      'referenceNumber': referenceNumber,
      'date_intervention': date?.toIso8601String(),
      'time':
          time != null
              ? '${time!.hour.toString().padLeft(2, '0')}:${time!.minute.toString().padLeft(2, '0')}'
              : null,
      'interventionType': interventionType,
      'estimatedDuration': estimatedDuration,
      'actualDuration': actualDuration,
      'technicianName': technicianName,
      'technicianAddress': technicianAddress,
    };
  }

  static TimeOfDay _parseTime(String timeStr) {
    final parts = timeStr.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  Intervention copyWith({
    String? clientId,
    String? clientName,
    String? address,
    String? phone,
    String? email,
    String? contactPerson,
    String? referenceNumber,
    DateTime? date,
    TimeOfDay? time,
    String? interventionType,
    String? estimatedDuration,
    String? actualDuration,
    String? technicianName,
    String? technicianAddress,
  }) {
    return Intervention(
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      contactPerson: contactPerson ?? this.contactPerson,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      date: date ?? this.date,
      time: time ?? this.time,
      interventionType: interventionType ?? this.interventionType,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      actualDuration: actualDuration ?? this.actualDuration,
      technicianName: technicianName ?? this.technicianName,
      technicianAddress: technicianAddress ?? this.technicianAddress,
    );
  }
}
