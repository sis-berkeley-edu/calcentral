'use strict';

var angular = require('angular');
var _ = require('lodash');

angular.module('calcentral.controllers').controller('UndergraduateDegreeProgressController', function(degreeProgressFactory, $scope) {
  $scope.degreeProgress = {
    undergraduate: {
      isLoading: true
    }
  };

  var loadDegreeProgress = function() {
    degreeProgressFactory.getUndergraduateRequirements()
      .then(function(data) {
        $scope.degreeProgress.undergraduate.progresses = _.get(data, 'data.feed.degreeProgress.progresses');
        $scope.degreeProgress.undergraduate.errored = _.get(data, 'data.errored');
      })
      .finally(function() {
        $scope.degreeProgress.undergraduate.isLoading = false;
      });
  };

  loadDegreeProgress();
});
