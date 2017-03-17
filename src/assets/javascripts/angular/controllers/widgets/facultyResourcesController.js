'use strict';

var angular = require('angular');
var _ = require('lodash');

angular.module('calcentral.controllers').controller('FacultyResourcesController', function(csLinkFactory, $scope) {
  $scope.facultyResources = {
    isLoading: true
  };

  var loadCsLinks = function() {
    csLinkFactory.getLink({
      urlId: 'UC_CX_GT_ACTION_CENTER'
    }).then(function(response) {
      var link = _.get(response, 'data.link');
      $scope.facultyResources.eformsReviewCenterLink = link;
      $scope.facultyResources.isLoading = false;
    });
  };

  var loadInformation = function() {
    loadCsLinks();
  };

  loadInformation();
});
