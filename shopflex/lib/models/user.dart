class Users {
 late String displayName;
 late String email;
  late String password;
  late String uuid;
  late String role;
  late String phone;

  Users();

  Users.fromMap(Map<String, dynamic> data) {
    displayName = data['displayName'];
    email = data['email'];
    password = data['password'];
    uuid = data['uuid'];
    role = data['role'];
    phone = data['phone'];
  }

  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'email': email,
      'password': password,
      'uuid': uuid,
      'role': role,
      'phone': phone,
    };
  }
}
