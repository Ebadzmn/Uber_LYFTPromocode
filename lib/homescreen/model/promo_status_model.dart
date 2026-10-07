class PromoStatusModel {
  final bool canClaim;
  final String? lastClaimedAt;
  final String? nextAvailableDate;
  final int daysRemaining;
  final Map<String, dynamic>? lastCoupon;

  PromoStatusModel({
    required this.canClaim,
    this.lastClaimedAt,
    this.nextAvailableDate,
    required this.daysRemaining,
    this.lastCoupon,
  });

  factory PromoStatusModel.fromJson(Map<String, dynamic> json) {
    return PromoStatusModel(
      canClaim: json['canClaim'] is bool ? json['canClaim'] : false,
      lastClaimedAt: json['lastClaimedAt']?.toString(),
      nextAvailableDate: json['nextAvailableDate']?.toString(),
      daysRemaining: json['daysRemaining'] is int
          ? json['daysRemaining']
          : int.tryParse(json['daysRemaining']?.toString() ?? '0') ?? 0,
      lastCoupon: json['lastCoupon'] is Map<String, dynamic>
          ? json['lastCoupon'] as Map<String, dynamic>
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'canClaim': canClaim,
      'lastClaimedAt': lastClaimedAt,
      'nextAvailableDate': nextAvailableDate,
      'daysRemaining': daysRemaining,
      'lastCoupon': lastCoupon,
    };
  }
}
