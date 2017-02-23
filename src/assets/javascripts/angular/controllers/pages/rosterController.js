/* jshint camelcase: false */
'use strict';

var angular = require('angular');
var _ = require('lodash');

/**
 * Canvas roster photos LTI app controller
 */
angular.module('calcentral.controllers').controller('RosterController', function(apiService, rosterFactory, rosterService, $routeParams, $scope, $window) {
  if ($routeParams.canvasCourseId) {
    apiService.util.setTitle('Roster Photos');
  }
  $scope.accessibilityAnnounce = apiService.util.accessibilityAnnounce;
  $scope.bmailLink = rosterService.bmailLink;
  $scope.searchOptions = {
    text: '',
    section: null,
    type: 'all'
  };

  $scope.rosterTypeFilter = function(student) {
    switch ($scope.searchOptions.type) {
      case 'enrolled': {
        return (!_.get(student, 'waitlist_position'));
      }
      case 'waitlist': {
        return (_.get(student, 'waitlist_position'));
      }
      default: {
        return true;
      }
    }
  };

  $scope.studentInSectionFilter = function(student) {
    if (!$scope.searchOptions.section) {
      return true;
    }
    return (student.section_ccns.indexOf($scope.searchOptions.section.ccn) !== -1);
  };

  var getRoster = function() {
    $scope.context = $scope.campusCourseId ? 'campus' : 'canvas';
    $scope.courseId = $scope.campusCourseId || $routeParams.canvasCourseId || 'embedded';
    $scope.origin = $window.location.origin;

    rosterFactory.getRoster($scope.context, $scope.courseId).success(function(data) {
      angular.extend($scope, data);
      $scope.course = $scope[$scope.context + '_course'];
      apiService.util.iframeUpdateHeight();
    }).error(function(data, status) {
      angular.extend($scope, data);
      $scope.errorStatus = status;
    });
  };

  getRoster();
});
