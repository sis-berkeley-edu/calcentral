'use strict';

/**
 * Finaid Approvals controller
 */
angular.module('calcentral.controllers').controller('FinaidApprovalsController', function($route, $rootScope, $scope, finaidFactory) {
  $scope.approvalMessage = {};

  // Send an event to let everyone know the permissions have been updated.
  var sendEvent = function() {
    $rootScope.$broadcast('calcentral.custom.api.finaid.approvals');
  };

  $scope.sendResponseTC = function(finaidYearId, response) {
    finaidFactory.postTCResponse(finaidYearId, response).then(sendEvent()).then($route.reload());
  };

  $scope.sendResponseT4 = function(response) {
    finaidFactory.postT4Response(response).then(sendEvent());
  };
});
