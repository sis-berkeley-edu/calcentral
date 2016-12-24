'use strict';

var angular = require('angular');
var _ = require('lodash');

angular.module('calcentral.controllers').controller('StudentResourcesController', function(apiService, linkService, academicStatusFactory, studentResourcesFactory, $scope) {
  $scope.isLoading = true;

  var backToText = 'My Dashboard';

  var loadStudentResources = function() {
    return studentResourcesFactory.getStudentResources();
  };

  var parseStudentResources = function(data) {
    var resources = _.get(data, 'data.feed.resources');
    if (!_.isEmpty(resources)) {
      $scope.studentResources = linkService.addBackToTextToResources(resources, backToText);
    }
  };

  var setStudentRole = function() {
    $scope.isLawStudent = apiService.user.profile.roles.law;
    $scope.isGraduateStudent = apiService.user.profile.roles.graduate;
    $scope.isUndergraduate = apiService.user.profile.roles.undergrad;
  };

  var loadAcademicRoles = function() {
    return academicStatusFactory.getAcademicRoles()
      .then(function(data) {
        $scope.isSummerVisitor = data.roles.summerVisitor;
      });
  };

  var loadInformation = function() {
    loadAcademicRoles()
      .then(loadStudentResources)
      .then(parseStudentResources)
      .then(setStudentRole)
      .then(function() {
        $scope.isLoading = false;
      });
  };

  loadInformation();
});
