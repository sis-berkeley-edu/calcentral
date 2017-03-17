'use strict';

var angular = require('angular');
var _ = require('lodash');

/**
 * Financial Aid - Awards controller
 */
angular.module('calcentral.controllers').controller('FinaidAwardsTermController', function($routeParams, $scope, finaidFactory) {
  $scope.finaidAwardsTerm = {
    isLoading: true,
    feed: {}
  };

  var loadAwardsTerm = function() {
    return finaidFactory.getAwardsTerm({
      finaidYearId: $routeParams.finaidYearId
    }).then(
      function successCallback(response) {
        angular.extend($scope.finaidAwardsTerm.feed, _.get(response, 'data.feed'));
        $scope.finaidAwardsTerm.errored = _.get(response, 'data.errored');
        $scope.finaidAwardsTerm.isLoading = false;
      }
    );
  };

  loadAwardsTerm();
  $scope.$on('calcentral.custom.api.finaid.finaidYear', loadAwardsTerm);
});
