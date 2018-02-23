'use strict';

var angular = require('angular');
var _ = require('lodash');

/**
 * Academics Higher Degree Committees controller
 */
angular.module('calcentral.controllers').controller('AcademicsHigherDegreeCommitteesController', function(committeesService, higherDegreeCommitteeFactory, $scope) {
  $scope.committees = {
    isLoading: true
  };

  /**
   * Get API data from factory and parse for UI consumption
   */
  var getCommittees = higherDegreeCommitteeFactory.getCommittees;

  var parseCommittees = function(response) {
    var committeeData = _.get(response, 'data');

    if (!committeeData) {
      return;
    }
    var studentCommittees = committeesService.parseCommitteeData(committeeData.studentCommittees, false);
    var facultyActiveCommittiees = committeesService.parseCommitteeData(committeeData.facultyCommittees.active, true);
    var facultyCompletedCommittiees = committeesService.parseCommitteeData(committeeData.facultyCommittees.completed, true);

    /**
    * Add committee data to $scope
    */
    angular.extend($scope, {
      studentCommittees: studentCommittees,
      facultyCommittees: {
        active: facultyActiveCommittiees,
        completed: facultyCompletedCommittiees,
        activeToggle: true
      }
    });
  };

  var loadCommittees = function() {
    getCommittees()
    .then(parseCommittees)
    .finally(function() {
      $scope.committees.isLoading = false;
    });
  };

  loadCommittees();
});
