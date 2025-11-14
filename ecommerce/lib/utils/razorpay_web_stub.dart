class RazorpayWebBridge {
  static bool get isSupported => false;

  static void open({
    required Map<String, dynamic> options,
    void Function(Map<String, dynamic> data)? onSuccess,
    void Function(Map<String, dynamic> error)? onError,
    void Function()? onDismiss,
  }) {
    throw UnsupportedError('Razorpay web bridge is unavailable on this platform');
  }
}

