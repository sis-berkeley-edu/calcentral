'use strict';

var angular = require('angular');
var _ = require('lodash');

angular.module('calcentral.controllers').controller('StudentResourcesController', function(apiService, linkService, studentResourcesFactory, $scope) {
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

  var setStudentRoles = function() {
    $scope.isLawStudent = apiService.user.profile.roles.law;
    $scope.isGraduateStudent = apiService.user.profile.roles.graduate;
    $scope.isUndergraduate = apiService.user.profile.roles.undergrad;
    $scope.isSummerVisitor = apiService.user.profile.academicRoles.summerVisitor;
    $scope.isJdLlmOnly = (apiService.user.profile.academicRoles.lawJdLlm && !apiService.user.profile.academicRoles.lawJspJsd && !apiService.user.profile.academicRoles.grad);
    $scope.isLawVisiting = (apiService.user.profile.academicRoles.lawVisiting && !apiService.user.profile.academicRoles.grad);
    $scope.isNonDegreeSeekingSummerVisitor = apiService.user.profile.academicRoles.nonDegreeSeekingSummerVisitor;
  };

  var loadInformation = function() {
    loadStudentResources()
      .then(parseStudentResources)
      .then(setStudentRoles)
      .finally(function() {
        $scope.isLoading = false;
      });
  };

  loadInformation();
});
