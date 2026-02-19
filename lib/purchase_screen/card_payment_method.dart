// To parse this JSON data, do
//
//     final loginResponse = loginResponseFromJson(jsonString);

import 'dart:convert';

LoginResponse loginResponseFromJson(String str) => LoginResponse.fromJson(json.decode(str));

String loginResponseToJson(LoginResponse data) => json.encode(data.toJson());

class LoginResponse {
    String message;
    Data data;

    LoginResponse({
        required this.message,
        required this.data,
    });

    factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
        message: json["message"],
        data: Data.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "message": message,
        "data": data.toJson(),
    };
}

class Data {
    int id;
    String nameOfCard;
    String paymentOption;
    String status;
    String price;
    String transactionId;
    String cardNumber;
    String expiryDate;
    String cvv;
    int user;
    int wasteSubmission;

    Data({
        required this.id,
        required this.nameOfCard,
        required this.paymentOption,
        required this.status,
        required this.price,
        required this.transactionId,
        required this.cardNumber,
        required this.expiryDate,
        required this.cvv,
        required this.user,
        required this.wasteSubmission,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["id"],
        nameOfCard: json["name_of_card"],
        paymentOption: json["payment_option"],
        status: json["status"],
        price: json["price"],
        transactionId: json["transaction_id"],
        cardNumber: json["card_number"],
        expiryDate: json["expiry_date"],
        cvv: json["cvv"],
        user: json["user"],
        wasteSubmission: json["waste_submission"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name_of_card": nameOfCard,
        "payment_option": paymentOption,
        "status": status,
        "price": price,
        "transaction_id": transactionId,
        "card_number": cardNumber,
        "expiry_date": expiryDate,
        "cvv": cvv,
        "user": user,
        "waste_submission": wasteSubmission,
    };
}
