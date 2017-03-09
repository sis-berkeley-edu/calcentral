'use strict';

var angular = require('angular');

/**
 * Finaid Approvals controller
 */
angular.module('calcentral.controllers').controller('FinaidApprovalsController', function($location, $rootScope, $scope, finaidFactory) {
  $scope.approvalMessage = {};

  /**
   * Send an event to let everyone know the permissions have been updated.
   */
  var sendEvent = function() {
    $rootScope.$broadcast('calcentral.custom.api.finaid.approvals');
  };

  var showDeclineMessage = function(data) {
    angular.extend($scope.approvalMessage, data.data.feed);
  };

  $scope.sendResponseTC = function(finaidYearId, response) {
    finaidFactory.postTCResponse(finaidYearId, response).then(function(data) {
      if (response === 'N') {
        showDeclineMessage(data);
      } else {
        sendEvent();
        $location.path('/finances');
      }
    });
  };
  $scope.sendResponseT4 = function(response) {
    finaidFactory.postT4Response(response).then(function(data) {
      if (response === 'N') {
        // Primes the cache on aid_years without automatically refreshing the page.
        finaidFactory.getSummary({
          refreshCache: true
        });
        showDeclineMessage(data);
      } else {
        sendEvent();
        $location.path('/finances');
      }
    });
  };
});
