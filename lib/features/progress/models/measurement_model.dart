// lib/features/progress/models/measurement_model.dart

class MeasurementEntry {
  final String dateKey;
  final double? weight;
  final double? bodyFat;
  final double? chest;
  final double? waist;
  final double? hips;
  final double? bicepsLeft;
  final double? bicepsRight;
  final double? thighLeft;
  final double? thighRight;
  final String? photoUrl;
  final String? note;

  const MeasurementEntry({
    required this.dateKey,
    this.weight,
    this.bodyFat,
    this.chest,
    this.waist,
    this.hips,
    this.bicepsLeft,
    this.bicepsRight,
    this.thighLeft,
    this.thighRight,
    this.photoUrl,
    this.note,
  });

  factory MeasurementEntry.fromJson(Map<String, dynamic> j) =>
      MeasurementEntry(
        dateKey:     j['dateKey']?.toString()           ?? '',
        weight:      (j['weight']     as num?)?.toDouble(),
        bodyFat:     (j['bodyFat']    as num?)?.toDouble(),
        chest:       (j['chest']      as num?)?.toDouble(),
        waist:       (j['waist']      as num?)?.toDouble(),
        hips:        (j['hips']       as num?)?.toDouble(),
        bicepsLeft:  (j['bicepsLeft'] as num?)?.toDouble(),
        bicepsRight: (j['bicepsRight'] as num?)?.toDouble(),
        thighLeft:   (j['thighLeft']  as num?)?.toDouble(),
        thighRight:  (j['thighRight'] as num?)?.toDouble(),
        photoUrl:    j['photoUrl']?.toString(),
        note:        j['note']?.toString(),
      );

  Map<String, dynamic> toJson() => {
    'dateKey': dateKey,
    if (weight      != null) 'weight':      weight,
    if (bodyFat     != null) 'bodyFat':     bodyFat,
    if (chest       != null) 'chest':       chest,
    if (waist       != null) 'waist':       waist,
    if (hips        != null) 'hips':        hips,
    if (bicepsLeft  != null) 'bicepsLeft':  bicepsLeft,
    if (bicepsRight != null) 'bicepsRight': bicepsRight,
    if (thighLeft   != null) 'thighLeft':   thighLeft,
    if (thighRight  != null) 'thighRight':  thighRight,
    if (photoUrl    != null) 'photoUrl':    photoUrl,
    if (note        != null) 'note':        note,
  };
}

// ─── Progress Provider ──────────────────────────────────────────
