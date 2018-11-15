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

  var setFinaidYear = function(aidYears, finaidYearId) {
    if (finaidYearId) {
      $scope.finaidYear = finaidService.findFinaidYear(aidYears, finaidYearId);
    } else {
      finaidService.setDefaultFinaidYear(aidYears);
      $scope.finaidYear = _.get(finaidService, 'options.finaidYear');
    }
  };

  var combinationExists = function(aidYears, finaidYearId) {
    var combination = finaidService.combinationExists(aidYears, finaidYearId);
    if (!combination && $location.path() !== '/finances/finaid/t4/auth') {
      apiService.user.redirectToPage('finances');
      return false;
    }
  };

  var getFinaidSummary = function(options) {
    return finaidFactory.getFinancialAidSummary(options).then(
      function successCallback(response) {
        var finaidSummary = _.get(response, 'data.financialAidSummary');
        var aidYears = _.get(finaidSummary, 'aidYears');
        combinationExists(aidYears, $routeParams.finaidYearId);
        setFinaidYear(aidYears, $routeParams.finaidYearId);
        $scope.finaidSummary = finaidSummary;
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
