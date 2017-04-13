'use strict';

var angular = require('angular');
var _ = require('lodash');

/**
 * OEC Control Panel app controller
 */
angular.module('calcentral.controllers').controller('OecController', function(apiService, oecFactory, $scope, $timeout) {
  $scope.initialize = function() {
    oecFactory.getOecTasks().then(
      function successCallback(response) {
        apiService.util.setTitle('OEC Control Panel');
        angular.extend($scope, response.data);
        $scope.displayError = null;
        $scope.oecTaskStatus = null;
        $scope.participatingDepartments = _.filter(response.data.oecDepartments, 'participating');
        $scope.taskParameters = {
          selectedTask: {
            name: null
          },
          options: {
            term: response.data.currentTerm
          }
        };
      },
      function errorCallback(response) {
        $scope.isLoading = false;
        if (response.status === 403) {
          $scope.displayError = 'unauthorized';
        } else {
          $scope.displayError = 'failure';
        }
        $scope.errorMessage = response.data.error;
      }
    );
  };

  var handleTaskStatus = function(response) {
    angular.extend($scope.oecTaskStatus, _.get(response, 'data.oecTaskStatus'));
    if ($scope.oecTaskStatus.status === 'In progress') {
      pollTaskStatus();
    } else {
      $timeout.cancel(timeoutPromise);
      $scope.oecTaskStatus.log.push('Task completed with status \'' + $scope.oecTaskStatus.status + '.\'');
    }
  };

  var timeoutPromise;
  var pollTaskStatus = function() {
    timeoutPromise = $timeout(function() {
      return oecFactory.oecTaskStatus($scope.oecTaskStatus.id).then(
        handleTaskStatus,
        function errorCallback() {
          $scope.displayError = 'failure';
        }
      );
    }, 2000);
  };

  var sanitizeTaskOptions = function() {
    if (!$scope.taskParameters.selectedTask.departmentOptions) {
      $scope.taskParameters.options.departmentCode = null;
    }
  };

  $scope.runOecTask = function() {
    sanitizeTaskOptions();
    return oecFactory.runOecTask($scope.taskParameters.selectedTask.name, $scope.taskParameters.options).then(
      function successCallback(response) {
        angular.extend($scope, _.get(response, 'data'));
        pollTaskStatus();
      },
      function errorCallback() {
        $scope.displayError = 'failure';
      }
    );
  };

  // Wait until user profile is fully loaded before starting.
  $scope.$on('calcentral.api.user.isAuthenticated', function(event, isAuthenticated) {
    if (isAuthenticated) {
      $scope.initialize();
    }
  });
});
