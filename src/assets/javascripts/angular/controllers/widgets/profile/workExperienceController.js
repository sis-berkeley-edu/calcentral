'use strict';

var angular = require('angular');
var _ = require('lodash');

/**
 * Work Experience controller
 */
angular.module('calcentral.controllers').controller('WorkExperienceController', function(profileFactory, $scope) {
  $scope.workExperienceInformation = {
    isLoading: true,
    isErrored: false
  };

  var loadInformation = function() {
    profileFactory.getWorkExperience().then(function(response) {
      $scope.workExperienceInformation.isLoading = false;
      $scope.workExperienceInformation.isErrored = _.get(response, 'data.errored');
    });
  };

  loadInformation();
});
