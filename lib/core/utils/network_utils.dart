import 'dart:io';

/// Returns the first non-loopback IPv4 address from the given network interfaces, or null if none found.
String? firstNonLoopbackIpv4(List<NetworkInterface>? interfaces) {
  if (interfaces == null) return null;
  for (final iface in interfaces) {
    for (final addr in iface.addresses) {
      if (!addr.isLoopback && addr.type == InternetAddressType.IPv4) {
        return addr.address;
      }
    }
  }
  return null;
}
