'use strict';

var angular = require('angular');
var _ = require('lodash');

/**
 * Tasks controller
 */
angular.module('calcentral.controllers').controller('TasksController', function(apiService, linkService, tasksFactory, $http, $interval, $filter, $scope) {
  // Initial mode for Tasks view
  $scope.currentTaskMode = 'incomplete';
  $scope.taskModes = ['incomplete', 'completed'];
  $scope.taskSections = [
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
      id: 'student',
      title: 'Student Tasks',
      show: false
    },
    {
      type: 'campusSolutions',
      id: 'newStudent',
      title: 'New Student Tasks',
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

  var getTasks = function(options) {
    return tasksFactory.getTasks(options).then(function(data) {
      var tasks = _.get(data, 'tasks');
      if (tasks) {
        $scope.tasks = tasks;
        linkService.addCurrentPagePropertiesToResources($scope.tasks, $scope.currentPage.name, $scope.currentPage.url);
        $scope.updateTaskLists();
        $scope.isLoading = false;
      }
    });
  };

  var isCanvasTask = function(task) {
    return (task.emitter === 'bCourses');
  };

  var isCompletedTask = function(task) {
    return (task.status === 'completed');
  };

  var isIncompleteTask = function(task) {
    return (task.status !== 'completed');
  };

  var isGoogleTask = function(task) {
    return (task.emitter === 'Google');
  };

  var isOverdueTask = function(task) {
    return (task.bucket === 'Overdue');
  };

  var isCsFurtherActionNeededTask = function(task) {
    return (task.emitter === 'Campus Solutions' && task.cs.displayStatus === 'furtherActionNeeded');
  };

  var isCsBeingProcessedTask = function(task) {
    return (task.emitter === 'Campus Solutions' && task.cs.displayStatus === 'beingProcessed');
  };

  var sortByTitle = function(a, b) {
    return apiService.util.naturalSort(a.title, b.title);
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

  var sortByCompletedDateReverse = function(a, b) {
    return sortByDate(a, b, 'completedDate', true);
  };

  var sortByDueDate = function(a, b) {
    return sortByDate(a, b, 'dueDate', false);
  };

  var toggleStatus = function(task) {
    if (task.status === 'completed') {
      task.status = 'needsAction';
    } else {
      task.status = 'completed';
    }
  };

  /**
   * If completed, give task a completed date epoch *after* sending to
   * backend (and successful response) so model can reflect correct changes.
   * Otherwise, remove completedDate prop after backend response.
   */
  $scope.changeTaskState = function(task) {
    var changedTask = angular.copy(task);
    // Reset task back to original state.
    toggleStatus(task);

    // Disable checkbox while processing.
    task.editorIsProcessing = true;

    if (changedTask.status === 'completed') {
      changedTask.completedDate = {
        'epoch': (new Date()).getTime() / 1000
      };
    } else {
      delete changedTask.completedDate;
    }

    apiService.analytics.sendEvent('Tasks', 'Set completed', 'completed: ' + !!changedTask.completedDate);
    tasksFactory.update(changedTask).then(
      function successCallback(response) {
        task.editorIsProcessing = false;
        angular.extend(task, response.data);
        $scope.updateTaskLists();
      },
      function errorCallback() {
        apiService.analytics.sendEvent('Error', 'Set completed failure', 'completed: ' + !!changedTask.completedDate);
        // Some error notification would be helpful.
      }
    );
  };

  // Delete Google tasks
  $scope.deleteTask = function(task) {
    task.isDeleting = true;
    task.editorIsProcessing = true;

    // Payload for proxy
    var deltask = {
      'task_id': task.id,
      'emitter': 'Google'
    };

    tasksFactory.remove(deltask).then(
      function successCallback() {
        // task.$index is duplicated between buckets, so need to iterate through ALL tasks
        for (var i = 0; i < $scope.tasks.length; i++) {
          if ($scope.tasks[i].id === task.id) {
            $scope.tasks.splice(i, 1);
            break;
          }
        }
        $scope.updateTaskLists();
        apiService.analytics.sendEvent('Tasks', 'Delete', task);
      },
      function errorCallback() {
        apiService.analytics.sendEvent('Error', 'Delete task failure');
        // Some error notification would be helpful.
      }
    );
  };

  $scope.incompleteTaskTotal = function() {
    if ($scope.lists && $scope.lists.incomplete && $scope.lists.furtherActionNeeded && $scope.lists.overdue) {
      return $scope.lists.incomplete.length + $scope.lists.furtherActionNeeded.length && $scope.lists.overdue.length;
    } else {
      return 0;
    }
  };

  // Switch mode for scheduled/unscheduled/completed tasks
  $scope.switchTasksMode = function(tasksMode) {
    apiService.analytics.sendEvent('Tasks', 'Switch mode', tasksMode);
    $scope.currentTaskMode = tasksMode;
  };

  $scope.taskModeCount = function(taskMode) {
    if (_.get($scope, 'lists.' + taskMode)) {
      return $scope.lists[taskMode].length;
    } else {
      return 0;
    }
  };

  $scope.toggleTaskSection = function(taskSection) {
    taskSection.show = !taskSection.show;
  };

  $scope.updateTaskLists = function() {
    var incompleteTasks = $scope.tasks.filter(isIncompleteTask);
    var remainingIncompleteTasks = [];
    var furtherActionNeededTasks = [];
    var overdueTasks = [];

    // separate further action needed tasks
    if (incompleteTasks.length > 0) {
      var furtherActionNeededAndIncompleteTasks = _.partition(incompleteTasks, isCsFurtherActionNeededTask);
      furtherActionNeededTasks = furtherActionNeededAndIncompleteTasks[0] || [];
      remainingIncompleteTasks = furtherActionNeededAndIncompleteTasks[1] || [];
    }

    // separate overdue tasks
    if (remainingIncompleteTasks.length > 0) {
      var overdueAndIncompleteTasks = _.partition(remainingIncompleteTasks, isOverdueTask);
      overdueTasks = overdueAndIncompleteTasks[0] || [];
      remainingIncompleteTasks = overdueAndIncompleteTasks[1] || [];
    }

    $scope.lists = {
      completed: $scope.tasks.filter(isCompletedTask).sort(sortByCompletedDateReverse),
      incomplete: remainingIncompleteTasks,
      furtherActionNeeded: furtherActionNeededTasks,
      overdue: overdueTasks
    };

    // populate task sections
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
      var incompleteSectionTasks = $scope.lists.incomplete.filter(taskFilter).sort(sortByDueDate);
      var beingProcessedAndIncompleteSectionTasks = _.partition(incompleteSectionTasks, isCsBeingProcessedTask);
      var beingProcessedTasks = beingProcessedAndIncompleteSectionTasks[0] || 0;
      var remainingIncompleteSectionTasks = beingProcessedAndIncompleteSectionTasks[1] || 0;

      taskSection.tasks = {
        incomplete: remainingIncompleteSectionTasks,
        beingProcessed: beingProcessedTasks,
        completed: $scope.lists.completed.filter(taskFilter).sort(sortByDueDate)
      };
    });
  };

  getTasks();
});
