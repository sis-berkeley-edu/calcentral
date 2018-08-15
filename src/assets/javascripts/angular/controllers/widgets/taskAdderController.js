'use strict';

var _ = require('lodash');

/**
 * Task adder controller
 */
angular.module('calcentral.controllers').controller('TaskAdderController', function(errorService, tasksService, taskAdderService, $scope) {
  $scope.addEditTask = taskAdderService.getTaskState();
  $scope.addTaskPanelState = taskAdderService.getState();

  $scope.addTaskCompleted = function(data) {
    var task = _.get(data, 'data');
    taskAdderService.resetState();
    $scope.tasks.push(task);
    tasksService.updateTaskLists($scope);
    $scope.switchTasksMode('incomplete');
  };

  $scope.addTask = function() {
    taskAdderService.addTask().then($scope.addTaskCompleted, function() {
      taskAdderService.resetState();
      errorService.send('TaskAdderController - taskAdderService deferred object rejected on false-y title');
    });
  };

  $scope.toggleAddTask = taskAdderService.toggleAddTask;

  $scope.$watch('addTaskPanelState.showAddTask', function(newValue) {
    if (newValue) {
      $scope.addEditTask.focusInput = true;
    }
  }, true);
});
