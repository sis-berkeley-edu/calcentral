'use strict';

var _ = require('lodash');
var angular = require('angular');

/**
 * Controller for Confidential Student section
 */
angular.module('calcentral.controllers').controller('ConfidentialStudentController', function(profileFactory, $scope) {
  $scope.confidentialStudent = {
    isLoading: true
  };

  var loadInformation = function() {
    profileFactory.getConfidentialStudentMessage().then(function(response) {
      angular.extend($scope.confidentialStudent, _.get(response, 'data.feed'));
      $scope.confidentialStudent.isLoading = false;
    });
  };

  loadInformation();
});
