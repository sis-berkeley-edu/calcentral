'use strict';



/**
 * Directive for finaid tables
 */
angular.module('calcentral.directives').directive('ccFinaidTableDirective', function() {
  return {
    templateUrl: 'directives/finaid_table.html',
    scope: {
      data: '=',
      toggle: '=',
      changeTags: '='
    }
  };
});
