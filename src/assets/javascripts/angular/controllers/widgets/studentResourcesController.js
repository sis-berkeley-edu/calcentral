'use strict';

var angular = require('angular');
var _ = require('lodash');

angular.module('calcentral.controllers').controller('StudentResourcesController', function(studentResourcesFactory, $scope) {
  $scope.studentResources = {};
  $scope.isLoading = true;

  var loadStudentResources = function() {
    return studentResourcesFactory.getStudentResources();
  };

  var parseStudentResources = function(data) {
    var resources = _.get(data, 'data.feed.resources');
    angular.extend($scope.studentResources, resources);
  };

  var loadInformation = function() {
    loadStudentResources()
    .then(parseStudentResources)
    .then(function() {
      $scope.isLoading = false;
    });
  };

  loadInformation();
});
