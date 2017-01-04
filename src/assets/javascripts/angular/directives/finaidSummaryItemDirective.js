'use strict';

var angular = require('angular');

/**
 * Directive for the finaid permissions
 */
angular.module('calcentral.directives').directive('ccFinaidSummaryItemDirective', function() {

  var capitalizeSentence = function(str) {
    if (typeof(str) !== 'string') {
      return '';
    }
    return str.toLowerCase().replace(/^(.*?)[a-zA-Z]{1}(.*?)/g, function(char) {
      return char.toUpperCase();
    });
  };

  return {
    templateUrl: 'directives/finaid_summary_item.html',
    scope: {
      item: '='
    },
    link: function(scope) {
      scope.itemSubTitle = capitalizeSentence(scope.item ? scope.item.subTitle : undefined);
    }
  };
});
