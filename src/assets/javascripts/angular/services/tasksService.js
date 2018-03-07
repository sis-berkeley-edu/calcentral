'use strict';

var angular = require('angular');

angular.module('calcentral.services').service('tasksService', function() {

  var isCanvasTask = function(task) {
    return (task.emitter === 'bCourses');
  };

  var isCompletedTask = function(task) {
    return (task.status === 'completed');
  };

  var isCsBeingProcessedTask = function(task) {
    return (task.emitter === 'Campus Solutions' && task.cs.displayStatus === 'beingProcessed');
  };

  var isCsFurtherActionNeededTask = function(task) {
    return (task.emitter === 'Campus Solutions' && task.cs.displayStatus === 'furtherActionNeeded');
  };

  var isDueWithinOneWeekTask = function(task) {
    return (task.dueDate && task.dueDate.withinOneWeek);
  };

  var isIncompleteTask = function(task) {
    return (task.status !== 'completed');
  };

  var isGoogleTask = function(task) {
    return (task.emitter === 'Google');
  };

  var isOverdueTask = function(task) {
    return (task.bucket === 'Overdue' && !isCsBeingProcessedTask(task));
  };

  return {
    isCanvasTask: isCanvasTask,
    isCompletedTask: isCompletedTask,
    isCsBeingProcessedTask: isCsBeingProcessedTask,
    isCsFurtherActionNeededTask: isCsFurtherActionNeededTask,
    isDueWithinOneWeekTask: isDueWithinOneWeekTask,
    isIncompleteTask: isIncompleteTask,
    isGoogleTask: isGoogleTask,
    isOverdueTask: isOverdueTask
  };
});
