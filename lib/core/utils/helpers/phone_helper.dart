class PhoneHelper {
  /// Extract phone number from formatted phone string
  /// Removes country code, spaces, dashes, parentheses, etc.
  static int? extractPhoneNumber(String phoneText) {
    if (phoneText.isEmpty) return null;
    
    // Remove all non-digit characters
    String digitsOnly = phoneText.replaceAll(RegExp(r'[^\d]'), '');
    
    // Remove Egypt country code if present
    if (digitsOnly.startsWith('20') && digitsOnly.length > 10) {
      digitsOnly = digitsOnly.substring(2); // Remove +20 country code
    }
    
    // Try to parse as integer
    return int.tryParse(digitsOnly);
  }

  /// Format phone number for display
  static String formatPhoneNumber(int phoneNumber) {
    String phoneStr = phoneNumber.toString();
    
    // Add formatting based on length
    if (phoneStr.length == 10) {
      // Egyptian format: 1x xxxx xxxx (without country code)
      return '${phoneStr.substring(0, 2)} ${phoneStr.substring(2, 6)} ${phoneStr.substring(6)}';
    } else if (phoneStr.length == 11) {
      // Legacy format: 01x xxxx xxxx
      return '${phoneStr.substring(0, 3)} ${phoneStr.substring(3, 7)} ${phoneStr.substring(7)}';
    }
    
    return phoneStr;
  }

  /// Validate Egyptian phone number
  static bool isValidEgyptianPhone(String phoneText) {
    final phoneNumber = extractPhoneNumber(phoneText);
    if (phoneNumber == null) return false;
    
    String phoneStr = phoneNumber.toString();
    
    // Egyptian phone numbers are 10 digits starting with 1 (after removing +20)
    // Valid patterns: 10xxxxxxxx, 11xxxxxxxx, 12xxxxxxxx, 15xxxxxxxx
    return phoneStr.length == 10 && phoneStr.startsWith('1');
  }
}