class OrderNumberSettings {
  const OrderNumberSettings({
    this.queuePrefix = 'A-',
    this.startingQueueNumber = '4288',
  });

  final String queuePrefix;
  final String startingQueueNumber;

  String get formattedNextQueueNumber => '$queuePrefix$startingQueueNumber';

  OrderNumberSettings copyWith({
    String? queuePrefix,
    String? startingQueueNumber,
  }) {
    return OrderNumberSettings(
      queuePrefix: queuePrefix ?? this.queuePrefix,
      startingQueueNumber: startingQueueNumber ?? this.startingQueueNumber,
    );
  }
}
