/// Thrown when the user backs out of the Google account picker.
/// Not a real error — represents a deliberate user cancellation.
class GoogleSignInCancelledException implements Exception {
  const GoogleSignInCancelledException();
}