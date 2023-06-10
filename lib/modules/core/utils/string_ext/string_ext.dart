extension HttpParser on String {
   bool get isHttpUrl => contains('http');
}