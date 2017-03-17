'use strict';

var angular = require('angular');
var _ = require('lodash');

angular.module('calcentral.controllers').controller('ClassInfoEnrollmentController', function(rosterFactory, $scope) {
  var partitionStudentsByEnrollmentStatus = function() {
    var partitions = _.partition($scope.students, {
      'enroll_status': 'E'
    });
    $scope.enrolledStudents = partitions[0];
    $scope.waitlistedStudents = partitions[1];
  };

  var getStudents = function() {
    rosterFactory.getRoster('campus', $scope.campusCourseId).then(
      function successCallback(response) {
        angular.extend($scope, _.get(response, 'data'));
        partitionStudentsByEnrollmentStatus();
      },
      function errorCallback(response) {
        angular.extend($scope, _.get(response, 'data'));
        $scope.errorStatus = _.get(response, 'status');
      }
    );
  };

  $scope.tableSort = {
    'column': ['!is_primary', 'section_label'],
    'reverse': false
  };

  $scope.groupedTableHeading = function(groupName, header, showGroupHeader) {
    var groupHeaderClass = showGroupHeader ? '' : 'cc-visuallyhidden';
    var groupHeader = '<div class="cc-academics-class-enrollment-grouped-header-label ' + groupHeaderClass + '">' + groupName + '</div>';
    var columnHeader = '<span class="cc-academics-class-enrollment-grouped-header-sublabel">' + header + '</span>';
    return [groupHeader, columnHeader].join('');
  };

  getStudents();
});
