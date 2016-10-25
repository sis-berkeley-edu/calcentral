'use strict';

var angular = require('angular');
var _ = require('lodash');

angular.module('calcentral.controllers').controller('DegreeProgressController', function(degreeProgressFactory, $scope) {

  $scope.degreeProgress = {
    isLoading: true
  };

  var loadDegreeProgress = function() {
    degreeProgressFactory.getDegreeProgress()
      .then(function(data) {
        $scope.degreeProgress.progresses = _.get(data, 'data.feed.degreeProgress');
        $scope.degreeProgress.links = _.get(data, 'data.feed.links');
        $scope.degreeProgress.errored = _.get(data, 'data.errored');
      })
      .finally(function() {
        $scope.degreeProgress.isLoading = false;
      });
  };

  loadDegreeProgress();
});
