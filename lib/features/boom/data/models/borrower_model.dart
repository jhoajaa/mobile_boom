class BorrowerModel {
  final String borrowerId;
  final String userId;
  final String name;
  final String phoneNumber;

  BorrowerModel({
    required this.borrowerId,
    required this.userId,
    required this.name,
    required this.phoneNumber,
  });

  factory BorrowerModel.fromJson(Map<String, dynamic> json) {
    return BorrowerModel(
      borrowerId: json['borrower_id'] ?? '',
      userId: json['user_id'] ?? '',
      name: json['name'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
    );
  }
}