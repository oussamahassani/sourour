import 'package:flutter/material.dart';

class InterventionReport {
  final String? id;
  final String? clientName;
  final String? address;
  final String? technicianName;
  final DateTime? date;
  final TimeOfDay? time;
  final String? interventionType;
  final String? description;
  final String? actionsTaken;
  final String? materialsUsed;
  final String? actualDuration;
  final String? observations;
  final String? recommendations;
  final String? clientSignature;
  final bool? clientSatisfied;

  InterventionReport({
    this.clientName,
    this.address,
    this.technicianName,
    this.date,
    this.time,
    this.interventionType,
    this.description,
    this.actionsTaken,
    this.materialsUsed,
    this.actualDuration,
    this.observations,
    this.recommendations,
    this.clientSignature,
    this.clientSatisfied,
    this.id,
  });

  Map<String, dynamic> toJson() => {
    'clientName': clientName,
    'address': address,
    'technicianName': technicianName,
    'date':
        date != null
            ? date?.toIso8601String()
            : DateTime.now().toIso8601String(),
    'time':
        time != null
            ? '${time?.hour.toString().padLeft(2, '0')}:${time?.minute.toString().padLeft(2, '0')}'
            : "10:00",

    'interventionType': interventionType,
    'description': description,
    'actionsTaken': actionsTaken,
    'materialsUsed': materialsUsed,
    'actualDuration': actualDuration,
    'observations': observations,
    'recommendations': recommendations,
    'clientSignature': clientSignature,
    'clientSatisfied': clientSatisfied,
  };
  static TimeOfDay parseTimeOfDay(String timeString) {
    final parts = timeString.split(":");
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return TimeOfDay(hour: hour, minute: minute);
  }

  factory InterventionReport.fromJson(Map<String, dynamic> json) {
    try {
      return InterventionReport(
        id: json['_id'],
        clientName: json['clientName']?.toString(),
        address: json['address'],
        technicianName: json['technicianName']?.toString(),
        date:
            json['date'] != null
                ? DateTime.parse(json['date'])
                : DateTime.now(),
        time: json['time'] != null ? parseTimeOfDay(json['time']) : null,
        interventionType: json['interventionType']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        actionsTaken: json['actionsTaken']?.toString() ?? '',
        materialsUsed: json['materialsUsed'],
        actualDuration: json['actualDuration'],
        observations: json['observations']?.toString(),
        recommendations: json['recommendations']?.toString(),
        clientSignature: json['clientSignature']?.toString(),
      );
    } catch (e) {
      throw FormatException(
        "Erreur lors de la conversion JSON en Fournisseur: ${e.toString()}",
      );
    }
  }
}
