'use strict';

var angular = require('angular');

/**
 * Canvas Site Mailing List app controller; for the course-level tool allowing creation of a single bCourses mailing list.
 */
angular.module('calcentral.controllers').controller('CanvasSiteMailingListController', function(apiService, canvasSharedFactory, canvasSiteMailingListFactory, $routeParams, $scope) {
  apiService.util.setTitle('Mailing List');

  var showMailingList = function(data) {
    angular.extend($scope, data);
    $scope.isCreating = false;
    $scope.isLoading = false;
    $scope.listCreated = (data.mailingList && data.mailingList.state === 'created');
  };

  var showError = function() {
    $scope.isCreating = false;
    $scope.isLoading = false;
    $scope.displayError = 'failure';
  };

  var getMailingList = function() {
    return canvasSiteMailingListFactory.getMailingList($scope.canvasCourseId).then(
      function successCallback(response) {
        showMailingList(response.data);
      },
      showError
    );
  };

  $scope.createMailingList = function() {
    $scope.isCreating = true;
    return canvasSiteMailingListFactory.createMailingList($scope.canvasCourseId).then(
      function successCallback(response) {
        showMailingList(response.data);
      },
      showError
    );
  };

  $scope.isLoading = true;
  $scope.canvasCourseId = $routeParams.canvasCourseId || 'embedded';

  // Wait until user profile is fully loaded before starting.
  $scope.$on('calcentral.api.user.isAuthenticated', function(event, isAuthenticated) {
    if (isAuthenticated) {
      getMailingList();
    }
  });
});
