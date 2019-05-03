'use strict';

/**
 * Roster photos controller
 */
angular.module('calcentral.controllers').controller('RosterController', function(apiService, emailService, rosterFactory, rosterService, $routeParams, $scope, $window) {
  $scope.accessibilityAnnounce = apiService.util.accessibilityAnnounce;
  $scope.bmailLink = emailService.bmailLink;
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
    // TODO: Further refactor to remove 'canvas' context and possibly 'embedded' support
    $scope.context = 'campus';
    $scope.courseId = $scope.campusCourseId || 'embedded';
    $scope.origin = $window.location.origin;

    rosterFactory.getRoster($scope.courseId).then(
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
