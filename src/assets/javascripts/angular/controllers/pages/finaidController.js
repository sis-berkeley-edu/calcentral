'use strict';

var angular = require('angular');
var _ = require('lodash');

/**
 * Financial Aid controller
 */
angular.module('calcentral.controllers').controller('FinaidController', function(apiService, finaidFactory, finaidService, linkService, tasksFactory, $routeParams, $scope) {
  linkService.addCurrentRouteSettings($scope);
  apiService.util.setTitle($scope.currentPage.name);

  $scope.isMainFinaid = true;
  $scope.finaid = {
    isLoading: true
  };
  $scope.changeTags = {
    added: 'added',
    deleted: 'deleted',
    changed: 'changed',
    same: 'same',
    blank: 'blank'
  };

  /**
   * Set the current finaid year
   * If we don't receive a finaid year through the route params, use the default aid year
   */
  var setFinaidYear = function(data, finaidYearId) {
    if (finaidYearId) {
      $scope.finaidYear = finaidService.findFinaidYear(data, finaidYearId);
    } else {
      finaidService.setDefaultFinaidYear(data);
      $scope.finaidYear = _.get(finaidService, 'options.finaidYear');
    }
  };

  /**
   * See whether the finaid year exist, otherwise, send them to the 404 page
   */
  var combinationExists = function(data, finaidYearId) {
    var combination = finaidService.combinationExists(data, finaidYearId);

    // If no correct finaid year comes back, make sure to send them to the 404 page.
    if (!combination) {
      apiService.util.redirect('404');
      return false;
    }
  };

  /**
   * Get the finaid summary information
   */
  var getFinaidSummary = function(options) {
    return finaidFactory.getSummary(options).then(
      function successCallback(response) {
        setFinaidYear(response.data.feed, $routeParams.finaidYearId);
        combinationExists(response.data.feed, _.get($scope, 'finaidYear.id'));
        $scope.finaidSummary = response.data.feed.finaidSummary;
        $scope.finaid.isLoading = false;
      }
    );
  };

  getFinaidSummary();

  /**
   * We need to update the finaid summary & checklists when the approvals have changed
   */
  $scope.$on('calcentral.custom.api.finaid.approvals', function() {
    tasksFactory.getFinaidTasks({
      refreshCache: true
    });
    getFinaidSummary({
      refreshCache: true
    });
  });
});
