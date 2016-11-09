'use strict';

var angular = require('angular');
var _ = require('lodash');

angular.module('calcentral.controllers').controller('StudentResourcesController', function(linkService, studentResourcesFactory, userService, $scope) {
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
    $scope.isLawStudent = userService.profile.roles.law;
    $scope.isGraduateStudent = userService.profile.roles.graduate;
    $scope.isUndergraduate = userService.profile.roles.undergrad;
  };

  var loadInformation = function() {
    loadStudentResources()
    .then(parseStudentResources)
    .then(setStudentRole)
    .then(function() {
      $scope.isLoading = false;
    });
  };

  loadInformation();
});
