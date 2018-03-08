'use strict';

var angular = require('angular');

angular.module('calcentral.services').service('tasksService', function() {
  var isCompletedTask = function(task) {
    return (task.status === 'completed');
  };

  var isCsBeingProcessedTask = function(task) {
    return (task.emitter === 'Campus Solutions' && task.cs.displayStatus === 'beingProcessed');
  };

  var isOverdueTask = function(task) {
    return (task.bucket === 'Overdue' && !(task.emitter === 'Campus Solutions' && task.cs.displayStatus === 'beingProcessed'));
  };

  return {
    isCompletedTask: isCompletedTask,
    isCsBeingProcessedTask: isCsBeingProcessedTask,
    isOverdueTask: isOverdueTask
  };
});
