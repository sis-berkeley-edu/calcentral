'use strict';

var angular = require('angular');

angular.module('calcentral.directives').directive('ccTelPhoneInputDirective', function() {
  /**
   * 8,9,18,19 AUG 2016
   * Regexp-based attempt at parsing tel number input strings
   * Note: should use <input type="tel" ...> to display big number buttons in small mobile devices
   * Goals:
   *  + remove leading `+` char from International matches
   *  + re-format US matches as either `1 xxx yyy zzzz` if leading 1 is
   *   present, or as `xxx yyy zzzz`
   * What it does:
   * - replaces one or more consecutive non-word chars with a single space char
   * - trims leading and trailing space chars
   * Returns object with:
   *  + `value` containing formatted phone number if matching
   *  International or US patterns, or the user-entered value if no match.
   *  + `valid` boolean property set to true if a pattern was matched, false if
   *   no pattern is matched.
   */
  var reIntlPhone = /^(\+?((?:\d ?){6,14}\d))?$/;
  var reUsPhone = /^([\d][\W])?(\d{3})\W?[\W]?(\d{3})[\W]?(\d{4})?$/;
  var space = ' ';
  var blank = '';

  var validPhone = function(phone, valueRequired) {
    var value = (phone || blank).replace(/[\W]{1,}/gm, space).trim();
    var valid = reUsPhone.test(value) || reIntlPhone.test(value);
    valid = valueRequired && value === '' ? false : valid;

    return {
      valid: valid,
      value: value
    };
  };

  return {
    require: 'ngModel',
    restrict: 'A',
    link: function(scope, elm, attr, ctrl) {
      var validateAndUpdate = function(options) {
        var showMessage = options && options.showMessage;
        var value = elm.val();
        var phone = validPhone(value, attr.required);
        var valid = phone.valid;

        if (valid || (!valid && showMessage)) {
          ctrl.$setValidity('invalidPhoneNumber', valid);
          ctrl.$setViewValue(phone.value);
          ctrl.$render();
        }
      };

      elm.on('keyup', function() {
        // The keyup handler updates the view only when a valid field value
        // is detected, in order to hide error messages.
        validateAndUpdate({
          showMessage: false
        });
      });

      elm.on('change', function() {
        // The change handler updates the view only when an invalid field value
        // is detected, in order to show error messages.
        validateAndUpdate({
          showMessage: true
        });
      });
    }
  };
});
