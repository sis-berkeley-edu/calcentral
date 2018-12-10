'use strict';

/**
 * Directive for the finaid permissions
 */
angular.module('calcentral.directives').directive('ccFinaidPermissionsDirective', function() {
  return {
    templateUrl: 'directives/finaid_permissions.html',
    scope: {
      buttonActionApprove: '&',
      buttonGoBack: '=',
      buttonTextApprove: '=',
      canPost: '=',
      responseHeader: '=',
      responseText: '=',
      header: '=',
      text: '=',
      title: '='
    }
  };
});
