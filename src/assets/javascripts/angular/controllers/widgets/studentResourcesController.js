'use strict';

var angular = require('angular');
var _ = require('lodash');

angular.module('calcentral.controllers').controller('StudentResourcesController', function(studentResourcesFactory, userService, $scope) {
  $scope.isLoading = true;

  var loadStudentResources = function() {
    return studentResourcesFactory.getStudentResources();
  };

  var parseStudentResources = function(data) {
    var resources = _.get(data, 'data.feed.resources');
    if (!_.isEmpty(resources)) {
      $scope.studentResources = resources;
    }
  };

  // Identify Law students to suppress withdrawal link
  var setStudentRole = function() {
    $scope.isLawStudent = userService.profile.roles.law;
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
