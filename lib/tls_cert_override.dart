import 'dart:io';
import 'dart:typed_data';

/// This class allows the http client to accept
/// self-singed certificates for hosts in private
/// IP-address spaces.
class PrivateIPCertOverride extends HttpOverrides {
  static final List<_IPAddressSpace> _v4PrivateSpaces = [
    _IPAddressSpace(
      mask: Uint8List.fromList([192, 168]),
      length: 16,
    ), // 192.168.0.0/16
    _IPAddressSpace(
      mask: Uint8List.fromList([172, 16]),
      length: 12,
    ), // 172.16.0.0/12
    _IPAddressSpace(
      mask: Uint8List.fromList([10]),
      length: 8,
    ), // 10.0.0.0/8
  ];

  static final _IPAddressSpace _v6PrivateSpace = _IPAddressSpace(
    mask: Uint8List.fromList([0xfc]),
    length: 7,
  ); // fc00::/7

  bool _isPrivateIPHost(String host) {
    InternetAddress? ip = InternetAddress.tryParse(host);
    if (ip == null) {
      return false;
    }
    Uint8List rawIP = ip.rawAddress;

    switch (ip.type) {
      case InternetAddressType.IPv4:
        for (final space in _v4PrivateSpaces) {
          if (space.containsAddress(rawIP)) {
            return true;
          }
        }
        break;
      case InternetAddressType.IPv6:
        return _v6PrivateSpace.containsAddress(rawIP);
      default:
        return false;
    }

    return false;
  }

  @override
  HttpClient createHttpClient(final SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) =>
              _isPrivateIPHost(host);
  }
}

class _IPAddressSpace {
  const _IPAddressSpace({
    required this.mask,
    required this.length,
  });

  final Uint8List mask;
  final int length;

  bool containsAddress(Uint8List address) {
    int remainingLength = length;
    int i = 0;
    for (; remainingLength >= 8; i++, remainingLength -= 8) {
      if (address[i] != mask[i]) {
        return false;
      }
    }

    if (remainingLength == 0) {
      return true;
    }

    int partialAddressByte = address[i] & ((1 << remainingLength) - 1);

    return partialAddressByte == mask[i];
  }
}
