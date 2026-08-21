/// Shipping address model.
class AddressModel {
  final String id;
  final String street;
  final String city;
  final String state;
  final String zip;

  const AddressModel({
    required this.id,
    required this.street,
    required this.city,
    required this.state,
    required this.zip,
  });

  String get displayAddress => '$street, $city, $state $zip';

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      street: json['street'] as String? ?? json['details'] as String? ?? '',
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      zip: json['zip'] as String? ?? json['postalCode'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'street': street,
        'city': city,
        'state': state,
        'zip': zip,
      };
}
