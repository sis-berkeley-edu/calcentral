'use strict';

var angular = require('angular');
var _ = require('lodash');

angular.module('calcentral.controllers').controller('StudentResourcesController', function(apiService, linkService, academicStatusFactory, studentResourcesFactory, $scope) {
  $scope.isLoading = true;

  var loadStudentResources = function() {
    return studentResourcesFactory.getStudentResources();
  };

  var parseStudentResources = function(response) {
    var resources = _.get(response, 'data.feed.resources');
    if (!_.isEmpty(resources)) {
      $scope.studentResources = linkService.addCurrentPagePropertiesToResources(resources, $scope.currentPage.name, $scope.currentPage.url);
    }
  };

  var setStudentRole = function() {
    $scope.isLawStudent = apiService.user.profile.roles.law;
    $scope.isGraduateStudent = apiService.user.profile.roles.graduate;
    $scope.isUndergraduate = apiService.user.profile.roles.undergrad;
  };

  var loadAcademicRoles = function() {
    return academicStatusFactory.getAcademicRoles().then(
      function(parsedAcademicRoles) {
        $scope.isSummerVisitor = _.get(parsedAcademicRoles, 'roles.summerVisitor');
      }
    );
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
