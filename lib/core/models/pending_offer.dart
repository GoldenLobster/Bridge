class PendingOffer {
  final String transferId;
  final String deviceId;
  final String fileName;
  final int fileSize;

  const PendingOffer({
    required this.transferId,
    required this.deviceId,
    required this.fileName,
    required this.fileSize,
  });
}
