extension HttpParser on String {
   bool isHttpUrl() => contains('http');
}