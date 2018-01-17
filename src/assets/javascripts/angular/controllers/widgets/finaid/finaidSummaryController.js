'use strict';

var angular = require('angular');
var _ = require('lodash');

/**
 * Finaid Summary controller
 */
angular.module('calcentral.controllers').controller('FinaidSummaryController', function(finaidFactory, finaidService, tasksFactory, $location, $q, $route, $routeParams, $scope) {
  // Keep a list of all the selected properties
  angular.extend($scope, {
    // Keep a list of all the selected properties
    selected: {},
    finaidSummaryInfo: {
      tasksCount: 0,
      isLoadingOptions: true,
      isLoadingData: true
    },
    finaidSummaryData: {},
    showFundingOfferedDetails: false,
    shoppingSheet: {}
  });

  /**
   * Set the default selections on the finaid year
   */
  var setDefaultSelections = function(data) {
    if (!_.get(data, 'finaidSummary.finaidYears.length')) {
      return;
    }
    finaidService.setDefaultFinaidYear(data, $routeParams.finaidYearId);
    selectFinaidYear();
    updateFinaidUrl();
  };

  var updateFinaidUrl = function() {
    if (!$scope.selected.finaidYear) {
      return;
    }
    $scope.finaidUrl = 'finances/finaid/' + $scope.selected.finaidYear.id;

    if ($scope.isMainFinaid) {
      $location.path($scope.finaidUrl, false);
    }
  };

  var getFinaidYearData = function() {
    $q.all([
      getFinAidYearInfo(),
      getTasksIncompleteCount()
    ]).then(function() {
      $scope.finaidSummaryInfo.isLoadingData = false;
    });
  };

  var getFinAidYearInfo = function() {
    return finaidFactory.getFinaidYearInfo({
      finaidYearId: finaidService.options.finaidYear.id
    }).then(parseFinaidYearInfo);
  };

  var parseFinaidYearInfo = function(response) {
    angular.extend($scope.finaidSummaryData, _.get(response, 'data.feed.financialAidSummary'));
    angular.extend($scope.shoppingSheet, _.get(response, 'data.feed.shoppingSheet'));
    $scope.finaidSummaryInfo.errored = _.get(response, 'data.errored');
  };

  var selectFinaidYear = function() {
    $scope.finaidSummaryInfo.isLoadingData = true;
    $scope.selected.finaidYear = finaidService.options.finaidYear;
    getFinaidYearData();
  };

  $scope.$on('calcentral.custom.api.finaid.finaidYear', selectFinaidYear);

  /**
   * Update the finaid year selection
   */
  $scope.updateFinaidYear = function() {
    finaidService.setFinaidYear($scope.selected.finaidYear);
    updateFinaidUrl();
  };

  var getTasksIncompleteCount = function() {
    return tasksFactory.getFinaidTasks({
      finaidYearId: finaidService.options.finaidYear.id
    }).then(function(response) {
      var tasks = _.get(response, 'tasks') || [];
      var completedTasksCount = _.filter(tasks, {
        status: 'completed'
      }).length;
      $scope.finaidSummaryInfo.tasksCount = tasks.length - completedTasksCount;
    });
  };

  /**
   * Get the financial aid summary information
   */
  var getFinaidSummary = function() {
    finaidFactory.getSummary().then(
      function successCallback(response) {
        var feed = _.get(response, 'data.feed');
        angular.extend($scope, feed);
        setDefaultSelections(feed);
        $scope.finaidSummaryInfo.isLoadingOptions = false;
      }
    );
  };

  getFinaidSummary();
});
