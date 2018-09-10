'use strict';

var _ = require('lodash');

/**
 * SIR (Statement of Intent to Register) item received controller
 * This controller will be executed when the current checklist item is in received status
 */
angular.module('calcentral.controllers').controller('SirItemReceivedController', function(apiService, sirFactory, $interval, $scope, $q) {
  // The Higher One URL expires after 5 minutes, so we refresh it every 4.5 minutes
  var expireTimeMilliseconds = 4.5 * 60 * 1000;

  $scope.higherOneUrl = '';

  var getHigherOneUrl = function() {
    return sirFactory.getHigherOneUrl({
      refreshCache: true
    }).then(
      function successCallback(response) {
        $scope.higherOneUrl = _.get(response, 'data.feed.root.higherOneUrl.url');
      }
    );
  };

  /*
   * Start the Higher One URL interval since it expires after 5 minutes
   */
  var startHigherOneUrlInterval = function() {
    getHigherOneUrl();
    $interval(getHigherOneUrl, expireTimeMilliseconds);
  };

  var init = function() {
    if (apiService.user.profile.canActOnFinances) {
      startHigherOneUrlInterval();
    }

    return $q.resolve($scope.higherOneUrl);
  };

  init();
});
