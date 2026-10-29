import '../../../checkout/data/models/address_model.dart';

/// User model for authentication and profile.
class UserModel {
  final String? id;
  final String? image;
  final String name;
  final String userName;
  final String email;
  final String role;
  final String? phone;
  final List<AddressModel>? addresses;
  // final String? token;

  const UserModel({
    this.id,
    required this.name,
    required this.userName,
    required this.email,
    this.phone,
    this.image,
    required this.role,
    this.addresses,
    // this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] as String? ?? json['id'] as String?,
      name: json['name'] as String? ?? '',
      userName: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone']?.toString(),
      image: json['image'] as String?,
      role: json['role'] as String? ?? 'user',
      addresses: (json['address'] as List? ?? [])
          .map((e) => AddressModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      //token: json['token'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'username': userName,
    'email': email,
    if (phone != null) 'phone': phone,
    if (image != null) 'image': image,
    if (addresses != null)
      'address': addresses!.map((e) => e.toJson()).toList(),
  };

  UserModel copyWith({
    String? id,
    String? name,
    String? userName,
    String? email,
    String? phone,
    String? image,
    String? role,
    List<AddressModel>? addresses,
    //String? token,
  }) => UserModel(
    id: id ?? this.id,
    name: name ?? this.name,
    userName: userName ?? this.userName,
    email: email ?? this.email,
    phone: phone ?? this.phone,
    image: image ?? this.image,
    role: role ?? this.role,
    addresses: addresses ?? this.addresses,
    //token: token ?? this.token,
  );
}
