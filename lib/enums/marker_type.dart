enum MarkerType {
  warning('warning'),
  info('info'),
  rest('rest'),
  participant('participant'),
  custom('custom');

  const MarkerType(this.type);
  final String type;

  factory MarkerType.fromString(String type) {
    switch (type) {
      case 'warning':
        return MarkerType.warning;
      case 'info':
        return MarkerType.info;
      case 'rest':
        return MarkerType.rest;
      case 'participant':
        return MarkerType.participant;
      default:
        return MarkerType.custom;
    }
  }
}
