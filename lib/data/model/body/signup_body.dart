class SignUpBody {
  String phone;
  String fName;
  String lName;
  String email;

  SignUpBody({
    this.phone,
    this.fName,
    this.lName,
    this.email,
  });

  SignUpBody.fromJson(Map<String, dynamic> json) {
    phone = json['phone'];
    fName = json['f_name'];
    lName = json['l_name'];
    email = json['email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data['phone'] = this.phone;
    data['f_name'] = this.fName;
    data['l_name'] = this.lName;
    data['email'] = this.email;

    return data;
  }

  Map<String, dynamic> toMap() {
    return {
      'phone': phone,
      'f_name': fName,
      'l_name': lName,
      'email': email,
    };
  }

  factory SignUpBody.fromMap(Map<String, dynamic> map) {
    return SignUpBody(
      phone: map['phone'],
      fName: map['f_name'],
      lName: map['l_name'],
      email: map['email'],
    );
  }
}
