class Device {
  final String id;
  final String name;
  final String platform;
  final bool isOnline;

  const Device({
    required this.id,
    required this.name,
    required this.platform,
    this.isOnline = false,
  });
}
