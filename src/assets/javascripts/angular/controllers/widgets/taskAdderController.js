'use strict';

var angular = require('angular');
var _ = require('lodash');

/**
 * Task adder controller
 */
angular.module('calcentral.controllers').controller('TaskAdderController', function(errorService, taskAdderService, $scope) {
  $scope.addEditTask = taskAdderService.getTaskState();
  $scope.addTaskPanelState = taskAdderService.getState();

  $scope.addTaskCompleted = function(data) {
    var task = _.get(data, 'data');
    taskAdderService.resetState();

    $scope.tasks.push(task);
    $scope.updateTaskLists();

    // Go the the right tab when adding a task
    if (task.dueDate) {
      $scope.switchTasksMode('scheduled');
    } else {
      $scope.switchTasksMode('unscheduled');
    }
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
