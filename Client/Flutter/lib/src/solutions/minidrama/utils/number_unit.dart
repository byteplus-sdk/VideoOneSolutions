const int K = 1000;
const int W = 10000;
const int M = 1000000;

String formatNumber(int count) {
  return formatNumberCN(count);
}

String formatNumberCN(int count) {
  if (count > W) {
    return '${(count / 10000).toStringAsFixed(1)}w';
  }
  return '$count';
}

String formatNumberEN(int count) {
  if (count > M) {
    return '${(count / M).toStringAsFixed(1)}m';
  } else if (count > K) {
    return '${(count / K).toStringAsFixed(1)}k';
  }
  return '$count';
}
