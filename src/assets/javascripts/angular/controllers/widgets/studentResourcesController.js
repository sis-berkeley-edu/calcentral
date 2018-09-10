'use strict';

var _ = require('lodash');

angular.module('calcentral.controllers').controller('StudentResourcesController', function(academicsService, apiService, linkService, studentResourcesFactory, $scope) {
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
    $scope.isUcbxStudent = apiService.user.profile.roles.concurrentEnrollmentStudent;
    $scope.isGeneralStudent = apiService.user.profile.roles.law || apiService.user.profile.roles.graduate || apiService.user.profile.roles.undergrad;
    $scope.isSummerVisitor = apiService.user.profile.academicRoles.current.summerVisitor;
    $scope.isJdLlmOnly = ((apiService.user.profile.academicRoles.current.lawJdLlm || apiService.user.profile.academicRoles.current.lawJdCdp) && !apiService.user.profile.academicRoles.current.lawJspJsd && !apiService.user.profile.academicRoles.current.grad);
    $scope.isLawVisiting = (apiService.user.profile.academicRoles.current.lawVisiting && !apiService.user.profile.academicRoles.current.grad);
    $scope.isNonDegreeSeekingSummerVisitor = academicsService.isNonDegreeSeekingSummerVisitor(apiService.user.profile.academicRoles);
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
