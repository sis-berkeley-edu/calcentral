'use strict';

var angular = require('angular');
var _ = require('lodash');

/**
 * Holds controller
 */
angular.module('calcentral.controllers').controller('HoldsController', function(academicStatusFactory, $scope, $route) {
  $scope.holdsInfo = {
    isLoading: true
  };

  var init = function(options) {
    academicStatusFactory.getAcademicStatus(options).then(function(data) {
      $scope.holdsInfo.isLoading = false;
      $scope.holds = _.get(data, 'data.feed.student.holds');
    });

    if ($route.current.isAdvisingStudentLookup) {
      $scope.holds = $scope.$parent.holds;
      $scope.holdsInfo = $scope.$parent.holdsInfo;
    }
  };

  init();
});
