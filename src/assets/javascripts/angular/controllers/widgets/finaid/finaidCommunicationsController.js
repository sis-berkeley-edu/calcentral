'use strict';

var _ = require('lodash');

/**
 * Finaid Communications controller
 */
angular.module('calcentral.controllers').controller('FinaidCommunicationsController', function($q, $scope, activityFactory, csLinkFactory, finaidFactory, finaidService, linkService, tasksFactory, tasksService) {
  $scope.communicationsInfo = {
    csLinks: {},
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

  // Initializes methods required by dashboard_task_loop.html
  var initializeServiceMethods = function() {
    $scope.isCompletedTask = tasksService.isCompletedTask;
    $scope.isCsBeingProcessedTask = tasksService.isCsBeingProcessedTask;
    $scope.isOverdueTask = tasksService.isOverdueTask;
  };

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

  var getVerificationAndAppealsLink = csLinkFactory.getLink({
    urlId: 'UC_CX_FA_COMM_FAFSA'
  }).then(
    function successCallback(response) {
      $scope.communicationsInfo.csLinks.verificationAndAppeals = _.get(response, 'data.link');
    }
  );

  var getOptionalDocumentsLink = csLinkFactory.getLink({
    urlId: 'UC_CX_FA_COMM_FORMS'
  }).then(
    function successCallback(response) {
      $scope.communicationsInfo.csLinks.optionalDocuments = _.get(response, 'data.link');
    }
  );

  var getOptionalDocumentsUploadLink = function(options) {
    return csLinkFactory.getLink({
      urlId: 'UC_CX_FA_FORM_UPLOAD',
      placeholders: {
        'AID_YEAR': options.finaidYearId
      }
    }).then(
      function successCallback(response) {
        $scope.communicationsInfo.csLinks.optionalDocumentsUpload = _.get(response, 'data.link');
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
      getOptionalDocumentsUploadLink({
        finaidYearId: finaidYearId
      }),
      getVerificationAndAppealsLink,
      getOptionalDocumentsLink
    ])
    .then(function() {
      $scope.communicationsInfo.isLoading = false;
    }
    );
  };

  initializeServiceMethods();
  $scope.$on('calcentral.custom.api.finaid.finaidYear', loadCommunications);
});
