'use strict';

var angular = require('angular');
var _ = require('lodash');

/**
 * Tasks controller
 */
angular.module('calcentral.controllers').controller('TasksController', function(apiService, linkService, tasksFactory, tasksService, $http, $interval, $filter, $scope) {
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
      }
    }).finally(function() {
      $scope.isLoading = false;
    });
  };

  // Initializes methods required by dashboard_task_loop.html
  var initializeServiceMethods = function() {
    $scope.isCompletedTask = tasksService.isCompletedTask;
    $scope.isCsBeingProcessedTask = tasksService.isCsBeingProcessedTask;
    $scope.isOverdueTask = tasksService.isOverdueTask;
  };

  var isCanvasTask = function(task) {
    return (task.emitter === 'bCourses');
  };

  var isDueWithinOneWeekTask = function(task) {
    return (task.dueDate && task.dueDate.withinOneWeek);
  };

  var isCsFurtherActionNeededTask = function(task) {
    return (task.emitter === 'Campus Solutions' && task.cs.displayStatus === 'furtherActionNeeded');
  };

  var isGoogleTask = function(task) {
    return (task.emitter === 'Google');
  };

  var isIncompleteTask = function(task) {
    return (task.status !== 'completed');
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

  $scope.incompleteTaskTotal = function(excludeBeingProcessed) {
    if ($scope.lists && $scope.lists.incomplete && $scope.lists.furtherActionNeeded && $scope.lists.overdue) {
      var incompleteFiltered = _.clone($scope.lists.incomplete);
      if (excludeBeingProcessed) {
        _.remove(incompleteFiltered, tasksService.isCsBeingProcessedTask);
      }
      return incompleteFiltered.length + $scope.lists.furtherActionNeeded.length + $scope.lists.overdue.length;
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
    if ($scope.lists && $scope.lists[taskMode]) {
      switch (taskMode) {
        case 'completed': {
          return $scope.lists.completed.length;
        }
        case 'incomplete': {
          return $scope.incompleteTaskTotal(true);
        }
        default: {
          return 0;
        }
      }
    } else {
      return 0;
    }
  };

  $scope.toggleTaskSection = function(taskSection) {
    taskSection.show = !taskSection.show;
  };

  $scope.updateTaskLists = function() {
    var incompleteTasks = _.clone($scope.tasks.filter(isIncompleteTask));
    var furtherActionNeededTasks = [];
    var overdueTasks = [];

    // separate further action needed tasks
    if (incompleteTasks.length > 0) {
      furtherActionNeededTasks = _.remove(incompleteTasks, isCsFurtherActionNeededTask);
    }

    // separate overdue tasks
    if (incompleteTasks.length > 0) {
      overdueTasks = _.remove(incompleteTasks, tasksService.isOverdueTask);
    }

    $scope.lists = {
      completed: $scope.tasks.filter(tasksService.isCompletedTask).sort(sortByCompletedDateReverse),
      incomplete: incompleteTasks,
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
      var incompleteSectionTasks = _.clone($scope.lists.incomplete.filter(taskFilter).sort(sortByDueDate));
      var beingProcessedTasks = _.remove(incompleteSectionTasks, tasksService.isCsBeingProcessedTask);

      taskSection.dueWithinWeekCount = incompleteSectionTasks.filter(isDueWithinOneWeekTask).length;

      taskSection.tasks = {
        incomplete: incompleteSectionTasks,
        beingProcessed: beingProcessedTasks,
        completed: $scope.lists.completed.filter(taskFilter).sort(sortByDueDate)
      };
    });
  };

  initializeServiceMethods();
  getTasks();
});
