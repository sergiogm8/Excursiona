enum MarkerType {
  warning('warning'),
  info('info'),
  rest('rest'),
  custom('custom');

  const MarkerType(this.type);
  final String type;
}
