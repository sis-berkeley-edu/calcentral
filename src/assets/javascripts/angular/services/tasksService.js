'use strict';

var angular = require('angular');
var _ = require('lodash');

angular.module('calcentral.services').service('tasksService', function(apiService) {
  var taskSections = [
    {
      type: 'campusSolutions',
      id: 'admission',
      title: 'Admission Tasks',
      show: false
    },
    {
      type: 'campusSolutions',
      id: 'residency',
      title: 'Residency Tasks',
      show: false
    },
    {
      type: 'campusSolutions',
      id: 'finaid',
      title: 'Financial Aid Tasks',
      show: false
    },
    {
      type: 'campusSolutions',
      id: 'newStudent',
      title: 'New Student Tasks',
      show: false
    },
    {
      type: 'campusSolutions',
      id: 'student',
      title: 'Student Tasks',
      show: false
    },
    {
      type: 'google',
      id: 'google',
      title: 'bTasks',
      show: false
    },
    {
      type: 'canvas',
      id: 'canvas',
      title: 'bCourses Tasks',
      show: false
    }
  ];

  var csCategoryFilterFactory = function(categoryString) {
    return function(task) {
      var category = categoryString;
      return (task.emitter === 'Campus Solutions' && task.cs.displayCategory === category);
    };
  };

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

  var isGoogleTask = function(task) {
    return (task.emitter === 'Google');
  };

  var isIncompleteTask = function(task) {
    return (task.status !== 'completed');
  };

  var isOverdueTask = function(task) {
    return (task.bucket === 'Overdue' && isIncompleteTask(task) && !isCsBeingProcessedTask(task));
  };

  var sortByCompletedDateReverse = function(a, b) {
    return sortByDate(a, b, 'completedDate', true);
  };

  var sortByDate = function(a, b, date, reverse) {
    if (a[date] && b[date] && a[date].epoch !== b[date].epoch) {
      if (!reverse) {
        return a[date].epoch - b[date].epoch;
      } else {
        return b[date].epoch - a[date].epoch;
      }
    } else {
      return sortByTitle(a, b);
    }
  };

  var sortByDueDate = function(a, b) {
    return sortByDate(a, b, 'dueDate', false);
  };

  var sortByTitle = function(a, b) {
    return apiService.util.naturalSort(a.title, b.title);
  };

  var updateTaskLists = function($scope) {
    var incompleteTasks = _.clone($scope.tasks.filter(isIncompleteTask));
    var furtherActionNeededTasks = [];
    var overdueTasks = [];

    // separate further action needed tasks
    if (incompleteTasks.length > 0) {
      furtherActionNeededTasks = _.remove(incompleteTasks, isCsFurtherActionNeededTask).sort(sortByDueDate);
    }

    // separate overdue tasks
    if (incompleteTasks.length > 0) {
      overdueTasks = _.remove(incompleteTasks, isOverdueTask);
    }

    $scope.lists = {
      completed: $scope.tasks.filter(isCompletedTask),
      incomplete: incompleteTasks,
      furtherActionNeeded: furtherActionNeededTasks,
      overdue: overdueTasks
    };

    // populate task sections
    $scope.taskSections = taskSections;
    angular.forEach($scope.taskSections, function(taskSection) {
      var taskFilter;
      switch (taskSection.type) {
        case 'campusSolutions': {
          taskFilter = csCategoryFilterFactory(taskSection.id);
          break;
        }
        case 'google': {
          taskFilter = isGoogleTask;
          break;
        }
        case 'canvas': {
          taskFilter = isCanvasTask;
          break;
        }
      }
      var incompleteSectionTasks = _.clone($scope.lists.incomplete.filter(taskFilter).sort(sortByDueDate));
      var beingProcessedTasks = _.remove(incompleteSectionTasks, isCsBeingProcessedTask);

      taskSection.dueWithinWeekCount = incompleteSectionTasks.filter(isDueWithinOneWeekTask).length;

      taskSection.tasks = {
        incomplete: incompleteSectionTasks,
        beingProcessed: beingProcessedTasks,
        completed: $scope.lists.completed.filter(taskFilter).sort(sortByCompletedDateReverse)
      };
    });
  };

  return {
    isCompletedTask: isCompletedTask,
    isCsBeingProcessedTask: isCsBeingProcessedTask,
    isOverdueTask: isOverdueTask,
    updateTaskLists: updateTaskLists
  };
});
