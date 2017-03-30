'use strict';

var angular = require('angular');
var _ = require('lodash');

/**
 * Finaid Communications controller
 */
angular.module('calcentral.controllers').controller('FinaidCommunicationsController', function($q, $scope, activityFactory, finaidFactory, finaidService, linkService, tasksFactory) {
  $scope.communicationsInfo = {
    aidYear: '',
    isLoading: true,
    counts: {
      completed: 0,
      uncompleted: 0
    },
    taskStatus: '!completed'
  };

  $scope.toggleCompletedTasks = function() {
    var status = $scope.communicationsInfo.taskStatus;
    status = (status === 'completed' ? '!completed' : 'completed');
    $scope.communicationsInfo.taskStatus = status;
  };

  var getMyFinaidActivity = function(options) {
    $scope.activityInfo = {
      isLoading: true
    };
    return activityFactory.getFinaidActivity(options).then(function(data) {
      angular.extend($scope, data);
      if (_.get($scope, 'list')) {
        linkService.addCurrentPagePropertiesToResources($scope.list, $scope.currentPage.name, $scope.currentPage.url);
        _.forEach($scope.list, function(value) {
          if (_.get(value, 'elements')) {
            linkService.addCurrentPagePropertiesToResources(value.elements, $scope.currentPage.name, $scope.currentPage.url);
          }
        });
      }
      $scope.activityInfo.isLoading = false;
    });
  };

  /**
   * Calculate the counts for the completed and uncompleted tasks
   */
  var calculateCounts = function(data) {
    if (!_.get(data, 'tasks.length')) {
      return;
    }
    $scope.communicationsInfo.counts.completed = _.filter(data.tasks, {
      status: 'completed'
    }).length;
    $scope.communicationsInfo.counts.uncompleted = data.tasks.length - $scope.communicationsInfo.counts.completed;
  };

  var getMyFinaidTasks = function(options) {
    return tasksFactory.getFinaidTasks(options).then(function(data) {
      angular.extend($scope, data);
      calculateCounts(data);
    });
  };

  var getFinaidYearInfo = function(options) {
    return finaidFactory.getFinaidYearInfo({
      finaidYearId: options.finaidYearId
    }).then(
      function successCallback(response) {
        $scope.communicationsInfo.unsolicitedResourcesUrl = _.get(response, 'data.feed.communications.unsolicitedResourcesUrl');
      }
    );
  };

  var loadCommunications = function() {
    $scope.communicationsInfo.aidYear = finaidService.options.finaidYear;
    var finaidYearId = finaidService.options.finaidYear.id;
    $q.all([
        getMyFinaidActivity({
          finaidYearId: finaidYearId
        }),
        getMyFinaidTasks({
          finaidYearId: finaidYearId
        }),
        getFinaidYearInfo({
          finaidYearId: finaidYearId
        })
      ])
      .then(function() {
        $scope.communicationsInfo.isLoading = false;
      }
    );
  };

  $scope.$on('calcentral.custom.api.finaid.finaidYear', loadCommunications);
});
