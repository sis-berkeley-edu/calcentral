/* jshint camelcase: false */
'use strict';

var angular = require('angular');

/**
 * Canvas roster photos LTI app controller
 */
angular.module('calcentral.controllers').controller('RosterController', function(apiService, rosterFactory, rosterService, $routeParams, $scope, $window) {
  if ($routeParams.canvasCourseId) {
    apiService.util.setTitle('Roster Photos');
  }
  $scope.accessibilityAnnounce = apiService.util.accessibilityAnnounce;
  $scope.bmailLink = rosterService.bmailLink;
  $scope.currentRosterViewType = 'photos';
  $scope.searchOptions = {
    text: '',
    section: null,
    enrollStatus: 'all'
  };
  $scope.tableSort = {
    'column': ['last_name', 'first_name'],
    'reverse': false
  };

  $scope.sectionChangeActions = function(filterType) {
    $scope.accessibilityAnnounce('Rosters filtered by ' + filterType);
    refreshFilteredStudents();
  };

  var getRoster = function() {
    $scope.context = $scope.campusCourseId ? 'campus' : 'canvas';
    $scope.courseId = $scope.campusCourseId || $routeParams.canvasCourseId || 'embedded';
    $scope.origin = $window.location.origin;

    rosterFactory.getRoster($scope.context, $scope.courseId).then(
      function successCallback(response) {
        angular.extend($scope, response.data);
        $scope.course = $scope[$scope.context + '_course'];
        apiService.util.iframeUpdateHeight();
        refreshFilteredStudents();
      },
      function errorCallback(response) {
        angular.extend($scope, response.data);
        $scope.errorStatus = response.status;
      }
    );
  };

  var refreshFilteredStudents = function() {
    $scope.filteredStudents = rosterService.getFilteredStudents($scope.students, $scope.sections, $scope.searchOptions, false);
  };

  getRoster();
});
