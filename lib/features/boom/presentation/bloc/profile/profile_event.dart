abstract class ProfileEvent {}

class GetProfileEvent extends ProfileEvent {}

class UpdateNameEvent extends ProfileEvent {
  final String newName;
  UpdateNameEvent(this.newName);
}

class LogoutEvent extends ProfileEvent {}