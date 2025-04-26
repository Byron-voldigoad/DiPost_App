class IBox {
  final int? id;
  final String boxId;
  final String location;
  final String size;
  final DateTime reservationDate;
  final DateTime? collectionDate;
  final String status;
  final String? parcelId;
  final String? senderId;

  IBox({
    this.id,
    required this.boxId,
    required this.location,
    required this.size,
    required this.reservationDate,
    this.collectionDate,
    required this.status,
    this.parcelId,
    this.senderId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'boxId': boxId,
      'location': location,
      'size': size,
      'reservationDate': reservationDate.toIso8601String(),
      'collectionDate': collectionDate?.toIso8601String(),
      'status': status,
      'parcelId': parcelId,
      'senderId': senderId,
    };
  }

  factory IBox.fromMap(Map<String, dynamic> map) {
    return IBox(
      id: map['id'],
      boxId: map['boxId'],
      location: map['location'],
      size: map['size'],
      reservationDate: DateTime.parse(map['reservationDate']),
      collectionDate: map['collectionDate'] != null 
          ? DateTime.parse(map['collectionDate']) 
          : null,
      status: map['status'],
      parcelId: map['parcelId'],
      senderId: map['senderId'],
    );
  }

  IBox copyWith({
    int? id,
    String? boxId,
    String? location,
    String? size,
    DateTime? reservationDate,
    DateTime? collectionDate,
    String? status,
    String? parcelId,
    String? senderId,
  }) {
    return IBox(
      id: id ?? this.id,
      boxId: boxId ?? this.boxId,
      location: location ?? this.location,
      size: size ?? this.size,
      reservationDate: reservationDate ?? this.reservationDate,
      collectionDate: collectionDate ?? this.collectionDate,
      status: status ?? this.status,
      parcelId: parcelId ?? this.parcelId,
      senderId: senderId ?? this.senderId,
    );
  }
}