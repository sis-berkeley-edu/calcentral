'use strict';

var angular = require('angular');
var _ = require('lodash');

/**
 * Tasks controller
 */
angular.module('calcentral.controllers').controller('TasksController', function(apiService, linkService, tasksFactory, $http, $interval, $filter, $scope) {
  // Initial mode for Tasks view
  $scope.currentTaskMode = 'incomplete';
  $scope.taskModes = ['incomplete', 'scheduled', 'unscheduled', 'completed'];
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

  var calculateCounts = function() {
    $scope.counts = {
      incomplete: $scope.lists.incomplete.count,
      scheduled: $scope.lists.overdue.length + $scope.lists.today.length + $scope.lists.future.length,
      unscheduled: $scope.lists.unscheduled.length,
      completed: $scope.lists.completed.count
    };
    setCounts();
  };

  var setCounts = function() {
    // var isScheduled = ($scope.currentTaskMode === 'scheduled');
    // $scope.counts.current = isScheduled ? $scope.counts.scheduled : $scope.counts.unscheduled;
    // $scope.counts.opposite = isScheduled ? $scope.counts.unscheduled : $scope.counts.scheduled;
    var isIncomplete = ($scope.currentTaskMode === 'incomplete');
    $scope.counts.current = isIncomplete ? $scope.counts.incomplete : $scope.counts.completed;
    $scope.counts.opposite = isIncomplete ? $scope.counts.completed : $scope.counts.incomplete;
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

  var sortByDueDate = function(a, b) {
    return sortByDate(a, b, 'dueDate', false);
  };

  var sortByUpdatedDateReverse = function(a, b) {
    return sortByDate(a, b, 'updatedDate', true);
  };

  var sortByCompletedDateReverse = function(a, b) {
    return sortByDate(a, b, 'completedDate', true);
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

  var toggleStatus = function(task) {
    if (task.status === 'completed') {
      task.status = 'needsAction';
    } else {
      task.status = 'completed';
    }
  };

  var filterOverdue = function(task) {
    return (task.bucket === 'Overdue');
  };

  var filterDueToday = function(task) {
    return (task.bucket === 'Today');
  };

  var filterFuture = function(task) {
    return (task.bucket === 'Future');
  };

  var filterUnScheduled = function(task) {
    return (!task.dueDate && task.status !== 'completed');
  };

  var filterGoogle = function(task) {
    return (task.emitter === 'Google');
  };

  var filterCanvas = function(task) {
    return (task.emitter === 'bCourses');
  };

  var csCategoryFilterFactory = function(categoryString) {
    return function(task) {
      var category = categoryString;
      return (task.emitter === 'Campus Solutions' && task.cs.displayCategory === category);
    };
  };

  var filterIncomplete = function(task) {
    return (task.status !== 'completed');
  };

  var filterCompleted = function(task) {
    return (task.status === 'completed');
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

  // Switch mode for scheduled/unscheduled/completed tasks
  $scope.switchTasksMode = function(tasksMode) {
    apiService.analytics.sendEvent('Tasks', 'Switch mode', tasksMode);
    $scope.currentTaskMode = tasksMode;
    setCounts();
  };

  $scope.toggleTaskSection = function(taskSection) {
    taskSection.show = !taskSection.show;
  };

  $scope.updateTaskLists = function() {
    var completedTasks = $scope.tasks.filter(filterCompleted).sort(sortByCompletedDateReverse);
    var incompleteTasks = $scope.tasks.filter(filterIncomplete);

    $scope.lists = {
      incomplete: {
        counts: incompleteTasks.length,
        tasks: incompleteTasks
      },
      completed: {
        counts: completedTasks.length,
        tasks: completedTasks
      },
      overdue: incompleteTasks.filter(filterOverdue).sort(sortByDueDate),
      today: incompleteTasks.filter(filterDueToday).sort(sortByTitle),
      future: incompleteTasks.filter(filterFuture).sort(sortByDueDate),
      unscheduled: incompleteTasks.filter(filterUnScheduled).sort(sortByUpdatedDateReverse)
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
          taskFilter = filterGoogle;
          break;
        }
        case 'canvas': {
          taskFilter = filterCanvas;
          break;
        }
      }

      var tasks = incompleteTasks.filter(taskFilter).sort(sortByDueDate);
      taskSection.tasks = tasks;
      taskSection.count = tasks.length;
    });

    calculateCounts();
  };

  getTasks();
});
