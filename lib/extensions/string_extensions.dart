extension StringExtensions on String {
  String truncate(int len) => length <= len ? this : '${substring(0, len)}...';
}
