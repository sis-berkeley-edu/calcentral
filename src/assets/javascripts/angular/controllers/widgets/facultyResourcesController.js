'use strict';

var _ = require('lodash');

angular.module('calcentral.controllers').controller('FacultyResourcesController', function(facultyResourcesFactory, $scope) {
  $scope.facultyResources = {
    isLoading: true
  };

  var loadCsLinks = function() {
    facultyResourcesFactory.getFacultyResources()
    .then(function(response) {
      var links = _.get(response, 'data.feed.resources');
      angular.merge($scope.facultyResources, links);
    }).finally(function(){
      $scope.facultyResources.isLoading = false;
    });
  };

  loadCsLinks();
});
