'use strict';

var _ = require('lodash');

angular.module('calcentral.directives').directive('ccAmountChangeSymbolDirective', [function() {
  var changeCssClasses = {
    added: ['cc-amount-added-icon', 'fa-arrow-right'],
    deleted: ['cc-amount-deleted-icon', 'fa-arrow-left'],
    changed: ['cc-amount-changed-icon', 'fa-exclamation-triangle'],
    same: ['cc-amount-same-icon'],
    blank: ['cc-amount-blank-icon']
  };

  return {
    link: function(scope, element, attr) {
      element.addClass('cc-finaid-compare-change-icons');
      element.addClass('fa');
      element.addClass('fa-fw');
      scope.$watch(attr.ccAmountChangeSymbolDirective, function ccAmountChangeWatchAction(value) {
        _.forEach(changeCssClasses[value], function(cssClass) {
          element.addClass(cssClass);
        });
      });
    }
  };
}]);
