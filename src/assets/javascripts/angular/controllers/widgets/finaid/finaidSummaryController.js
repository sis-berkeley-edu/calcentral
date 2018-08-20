'use strict';

var _ = require('lodash');

/**
 * Finaid Summary controller
 */
angular.module('calcentral.controllers').controller('FinaidSummaryController', function(finaidFactory, finaidService, tasksFactory, $location, $q, $route, $routeParams, $scope) {
  $scope.financialAidSummary = {
    isLoading: true,
    selected: {},
    tasksCount: 0,
    giftAidDetail: {},
    waiversDetail: {},
    loansWorkStudyDetail: {}
  };

  $scope.financialAidSummary.changeAidYear = function() {
    finaidService.setFinaidYear($scope.financialAidSummary.selected.finaidYear);
    updateSummary();
    updateUrl();
  };

  var updateUrl = function() {
    if (!$scope.financialAidSummary.selected.finaidYear) {
      return;
    }
    if ($scope.isMainFinaid) {
      $location.path('finances/finaid/' + $scope.financialAidSummary.selected.finaidYear.id, false);
    }
  };

  var updateSummary = function() {
    angular.extend($scope.financialAidSummary.selected, _.get($scope.financialAidSummary.aid, finaidService.options.finaidYear.id));
  };

  var selectFinaidYear = function() {
    $scope.financialAidSummary.selected.finaidYear = finaidService.options.finaidYear;
  };

  var setDefaultSelections = function(feed) {
    var aidYears = _.values(_.get(feed, 'financialAidSummary.aidYears'));
    if (!aidYears.length) {
      return;
    }
    finaidService.setDefaultFinaidYear(aidYears, $routeParams.finaidYearId);
    selectFinaidYear(feed);
    updateSummary();
  };

  var loadTasksIncompleteCount = function() {
    return tasksFactory.getFinaidTasks({
      finaidYearId: finaidService.options.finaidYear.id
    }).then(function(response) {
      var tasks = _.get(response, 'tasks') || [];
      var completedTasksCount = _.filter(tasks, {
        status: 'completed'
      }).length;
      $scope.financialAidSummary.tasksCount = tasks.length - completedTasksCount;
    });
  };

  var parseFinancialAidSummary = function(response) {
    var feed = _.get(response, 'data');
    angular.extend($scope.financialAidSummary, _.get(feed, 'financialAidSummary'));
    $scope.financialAidSummary.isMainPage = ($location.path() === '/finances');
    $scope.financialAidSummary.errored = _.get(feed, 'errored');
    setDefaultSelections(feed);
  };

  var loadFinancialAidSummary = function() {
    finaidFactory.getFinancialAidSummary()
    .then(
      parseFinancialAidSummary,
      function errorCallback() {
        $scope.financialAidSummary.errored = true;
      }
    )
    .then(
      loadTasksIncompleteCount
    )
    .finally(function() {
      $scope.financialAidSummary.isLoading = false;
    });
  };

  loadFinancialAidSummary();
});
