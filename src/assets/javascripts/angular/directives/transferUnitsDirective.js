'use strict';


var _ = require('lodash');

angular.module('calcentral.directives').directive('ccTransferUnitsDirective', function(numberFilter) {
  var formatDecimal = function(number) {
    return numberFilter(number, '1');
  };

  return {
    link: function(scope, element, attr) {
      scope.$watch(attr.ccTransferUnitsDirective, function(value) {
        if (!value || !_.isNumber(value.unitsAdjusted)) {
          element.text('');
          return;
        }
        if (_.isNumber(value.unitsNonAdjusted) && value.unitsNonAdjusted !== value.unitsAdjusted) {
          element.text(formatDecimal(value.unitsAdjusted) + ' (Non-Adjusted: ' + formatDecimal(value.unitsNonAdjusted) + ')');
        } else {
          element.text(formatDecimal(value.unitsAdjusted));
        }
      });
    }
  };
});
