'use strict';

/**
 * Directive for the finaid permissions
 */
angular.module('calcentral.directives').directive('ccFinaidPermissionsDirective', function() {
  return {
    templateUrl: 'directives/finaid_permissions.html',
    scope: {
      buttonActionApprove: '&',
      buttonActionDontApprove: '&',
      buttonGoBack: '=',
      buttonTextApprove: '=',
      buttonTextDontApprove: '=',
      canPost: '=',
      header: '=',
      text: '=',
      title: '='
    }
  };
});
