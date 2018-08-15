'use strict';

var _ = require('lodash');

/**
 * Financial Aid controller
 */
angular.module('calcentral.controllers').controller('FinaidController', function(apiService, finaidFactory, finaidService, linkService, tasksFactory, $routeParams, $scope, $location) {
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

  var setFinaidYear = function(data, finaidYearId) {
    if (finaidYearId) {
      $scope.finaidYear = finaidService.findFinaidYear(data, finaidYearId);
    } else {
      finaidService.setDefaultFinaidYear(data);
      $scope.finaidYear = _.get(finaidService, 'options.finaidYear');
    }
  };

  var combinationExists = function(data, finaidYearId) {
    var combination = finaidService.combinationExists(data, finaidYearId);
    if (!combination && $location.path() !== '/finances/finaid/t4/auth') {
      apiService.user.redirectToPage('finances');
      return false;
    }
  };

  var getFinaidSummary = function(options) {
    return finaidFactory.getSummary(options).then(
      function successCallback(response) {
        combinationExists(response.data.feed, $routeParams.finaidYearId);
        setFinaidYear(response.data.feed, $routeParams.finaidYearId);
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
