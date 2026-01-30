class AppUser {
  String name;
  String role;
  String? imagePath;

  AppUser({
    required this.name,
    required this.role,
    this.imagePath,
  });
}
