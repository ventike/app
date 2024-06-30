class Arguments {
  final String userHash;
  final int role;
  final String? profilePicture;

  Arguments(this.userHash, this.role, this.profilePicture);
}

class EditPartnerArguments {
  final String userHash;
  final int role;
  final String? profilePicture;
  final int id;
  final String name;
  final String description;
  final int type;
  final String email;
  final String phone;
  final String? image;
  final String individualFirstName;
  final String individualLastName;
  final String individualEmail;
  final String individualPhone;
  final List<dynamic> tags;
  final List<dynamic> resources;

  EditPartnerArguments(this.userHash, this.role, this.profilePicture, this.id, this.name, this.description, this.type, this.email, this.phone, this.image, this.individualFirstName, this.individualLastName, this.individualEmail, this.individualPhone, this.tags, this.resources);
}

class EditEventArguments {
  final String userHash;
  final int role;
  final String? profilePicture;
  final int id;
  final String name;
  final String description;
  final String date;
  final String startTime;
  final String endTime;
  final List<dynamic> partners;

  EditEventArguments(this.userHash, this.role, this.profilePicture, this.id, this.name, this.description, this.date, this.startTime, this.endTime, this.partners);
}

class EditUserArguments {
  final String userHash;
  final int role;
  final String? profilePicture;
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final int userRole;

  EditUserArguments(this.userHash, this.role, this.profilePicture, this.id, this.username, this.email, this.firstName, this.lastName, this.userRole);
}