// lib/features/auth/models/user_model.dart
import 'dart:convert';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? phone;
  final String role;
  final String status;
  final String? program;
  final int?   programDays;
  final String subscriptionStatus;
  final String? subscriptionType;
  final int?   subscriptionEnd;
  final String? referralCode;
  final String? promoCode;
  final int?   referralCoins;
  final String? profilePicUrl;
  final String? coachId;
  final String? forceLogoutToken;
  final int?   dailyCals;
  final int?   protein;
  final int?   carbs;
  final int?   fat;
  final String? sessionToken;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    required this.status,
    this.program,
    this.programDays,
    required this.subscriptionStatus,
    this.subscriptionType,
    this.subscriptionEnd,
    this.referralCode,
    this.promoCode,
    this.referralCoins,
    this.profilePicUrl,
    this.coachId,
    this.forceLogoutToken,
    this.dailyCals,
    this.protein,
    this.carbs,
    this.fat,
    this.sessionToken,
  });

  bool get isSuperAdmin => role.toUpperCase() == 'SUPER_ADMIN';
  bool get isAdmin      => role.toUpperCase() == 'ADMIN';
  bool get isCoach      => role.toUpperCase() == 'COACH';
  bool get isAdminLike  => isSuperAdmin || isAdmin || isCoach;
  bool get isActive     => status == 'active';

  bool get subscriptionActive {
    if (isAdminLike) return true;
    if (subscriptionStatus != 'active') return false;
    if (subscriptionEnd != null && subscriptionEnd! > 0) {
      return DateTime.now().millisecondsSinceEpoch < subscriptionEnd!;
    }
    return true;
  }

  String get displayRole {
    switch (role.toUpperCase()) {
      case 'SUPER_ADMIN': return 'Super Admin';
      case 'ADMIN':       return 'Admin';
      case 'COACH':       return 'Coach';
      case 'TRAINEE':     return 'Trainee';
      case 'VIEWER':      return 'Viewer';
      default:            return role;
    }
  }

  factory UserModel.fromJson(Map<String, dynamic> j) {
    return UserModel(
      uid:                j['uid']?.toString()                ?? '',
      name:               j['name']?.toString()               ?? '',
      email:              j['email']?.toString()              ?? '',
      phone:              j['phone']?.toString(),
      role:               j['role']?.toString()               ?? 'TRAINEE',
      status:             j['status']?.toString()             ?? 'pending',
      program:            j['program']?.toString(),
      programDays:        _toInt(j['programDays']),
      subscriptionStatus: j['subscriptionStatus']?.toString() ?? 'none',
      subscriptionType:   j['subscriptionType']?.toString(),
      subscriptionEnd:    _toInt(j['subscriptionEnd']),
      referralCode:       j['referralCode']?.toString(),
      promoCode:          j['promoCode']?.toString(),
      referralCoins:      _toInt(j['referralCoins']),
      profilePicUrl:      j['profilePicUrl']?.toString(),
      coachId:            j['coachId']?.toString(),
      forceLogoutToken:   j['forceLogoutToken']?.toString(),
      dailyCals:          _toInt(j['dailyCals']),
      protein:            _toInt(j['protein']),
      carbs:              _toInt(j['carbs']),
      fat:                _toInt(j['fat']),
      sessionToken:       j['sessionToken']?.toString(),
    );
  }

  static int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is double) return v.toInt();
    final s = v.toString();
    return int.tryParse(s);
  }

  Map<String, dynamic> toJson() => {
    'uid':                uid,
    'name':               name,
    'email':              email,
    if (phone != null)           'phone':              phone,
    'role':               role,
    'status':             status,
    if (program != null)         'program':            program,
    if (programDays != null)     'programDays':        programDays,
    'subscriptionStatus': subscriptionStatus,
    if (subscriptionType != null) 'subscriptionType':  subscriptionType,
    if (subscriptionEnd != null)  'subscriptionEnd':   subscriptionEnd,
    if (referralCode != null)     'referralCode':      referralCode,
    if (promoCode != null)        'promoCode':         promoCode,
    if (referralCoins != null)    'referralCoins':     referralCoins,
    if (profilePicUrl != null)    'profilePicUrl':     profilePicUrl,
    if (coachId != null)          'coachId':           coachId,
    if (forceLogoutToken != null) 'forceLogoutToken':  forceLogoutToken,
    if (dailyCals != null)        'dailyCals':         dailyCals,
    if (protein != null)          'protein':           protein,
    if (carbs != null)            'carbs':             carbs,
    if (fat != null)              'fat':               fat,
  };

  String toJsonString() => jsonEncode(toJson());

  UserModel copyWith({
    String? uid, String? name, String? email, String? phone,
    String? role, String? status, String? program, int? programDays,
    String? subscriptionStatus, String? subscriptionType, int? subscriptionEnd,
    String? referralCode, String? promoCode, int? referralCoins,
    String? profilePicUrl, String? coachId, String? forceLogoutToken,
    int? dailyCals, int? protein, int? carbs, int? fat, String? sessionToken,
  }) {
    return UserModel(
      uid:                uid                ?? this.uid,
      name:               name               ?? this.name,
      email:              email              ?? this.email,
      phone:              phone              ?? this.phone,
      role:               role               ?? this.role,
      status:             status             ?? this.status,
      program:            program            ?? this.program,
      programDays:        programDays        ?? this.programDays,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      subscriptionType:   subscriptionType   ?? this.subscriptionType,
      subscriptionEnd:    subscriptionEnd    ?? this.subscriptionEnd,
      referralCode:       referralCode       ?? this.referralCode,
      promoCode:          promoCode          ?? this.promoCode,
      referralCoins:      referralCoins      ?? this.referralCoins,
      profilePicUrl:      profilePicUrl      ?? this.profilePicUrl,
      coachId:            coachId            ?? this.coachId,
      forceLogoutToken:   forceLogoutToken   ?? this.forceLogoutToken,
      dailyCals:          dailyCals          ?? this.dailyCals,
      protein:            protein            ?? this.protein,
      carbs:              carbs              ?? this.carbs,
      fat:                fat                ?? this.fat,
      sessionToken:       sessionToken       ?? this.sessionToken,
    );
  }
}
