// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:js' as js;

import 'package:js/js.dart';

typedef RazorpayWebSuccess = void Function(Map<String, dynamic> data);
typedef RazorpayWebError = void Function(Map<String, dynamic> error);

class RazorpayWebBridge {
  static bool get isSupported =>
      js.context.hasProperty('Razorpay') && js.context['Razorpay'] != null;

  static dynamic _convertJsValue(dynamic value) {
    if (value == null) return null;
    if (value is js.JsArray) {
      return List<dynamic>.generate(
        value.length,
        (index) => _convertJsValue(value[index]),
      );
    }
    if (value is js.JsObject) {
      final keys = js.context['Object']
          .callMethod('keys', <dynamic>[value]) as js.JsArray;
      final map = <String, dynamic>{};
      for (var i = 0; i < keys.length; i++) {
        final key = keys[i]?.toString();
        if (key == null) continue;
        map[key] = _convertJsValue(value[key]);
      }
      return map;
    }
    return value;
  }

  static void open({
    required Map<String, dynamic> options,
    RazorpayWebSuccess? onSuccess,
    RazorpayWebError? onError,
    void Function()? onDismiss,
  }) {
    if (!isSupported) {
      throw StateError(
        'Razorpay checkout script is not loaded on this page.',
      );
    }

    final constructor = js.context['Razorpay'];
    if (constructor == null) {
      throw StateError('Razorpay constructor missing on window');
    }

    final jsOptions = js.JsObject.jsify(options);
    if (onSuccess != null) {
      jsOptions['handler'] = allowInterop((dynamic response) {
        onSuccess(_convertJsValue(response) as Map<String, dynamic>? ?? {});
      });
    }

    final modalOptions = js.JsObject.jsify({});
    if (onDismiss != null) {
      modalOptions['ondismiss'] = allowInterop(onDismiss);
    }
    jsOptions['modal'] = modalOptions;

    final instance = js.JsObject(constructor, <dynamic>[jsOptions]);

    if (onError != null) {
      instance.callMethod(
        'on',
        <dynamic>[
          'payment.failed',
          allowInterop((dynamic response) {
            if (response is js.JsObject && response.hasProperty('error')) {
              onError(
                _convertJsValue(response['error']) as Map<String, dynamic>? ??
                    {},
              );
            } else {
              onError(
                _convertJsValue(response) as Map<String, dynamic>? ?? {},
              );
            }
          }),
        ],
      );
    }

    instance.callMethod('open');
  }
}

