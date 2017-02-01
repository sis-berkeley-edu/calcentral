'use strict';

var angular = require('angular');
var _ = require('lodash');

/**
 * Academics Higher Degree Committees controller
 */
angular.module('calcentral.controllers').controller('AcademicsHigherDegreeCommitteesController', function(higherDegreeCommitteeFactory, $scope) {
  $scope.committees = {
    isLoading: true
  };

  /**
   * Apply the CSS style based on the icon needed
   */
  var getIconStyle = function(iconName) {
    var iconStyle;
    switch (iconName) {
      case 'check': {
        iconStyle = 'cc-icon fa fa-check cc-icon-green';
        break;
      }
      case 'exclamation-triangle': {
        iconStyle = 'cc-icon fa fa-exclamation-triangle cc-icon-gold';
        break;
      }
      default: {
        iconStyle = '';
      }
    }
    return iconStyle;
  };

  /**
   * Committee data parsing functions
   */
  var getCommitteeHeader = function(committeeData) {
    return {
      type: committeeData.committeeType,
      program: committeeData.program,
      statusTitle: committeeData.statusTitle,
      statusIcon: getIconStyle(committeeData.statusIcon),
      statusMessage: committeeData.statusMessage
    };
  };

  var getCommitteeStudent = function(committeeData) {
    return committeeData.student;
  };

  var getCommitteeChair = function(committeeData) {
    return committeeData.committeeMembers.chair;
  };

  var getCommitteeCoChair = function(committeeData) {
    return committeeData.committeeMembers.coChair;
  };

  var getCommitteeInsideMembers = function(committeeData) {
    return committeeData.committeeMembers.insideMembers;
  };

  var getCommitteeOutsideMembers = function(committeeData) {
    return committeeData.committeeMembers.outsideMembers;
  };

  var getCommitteeAdditionalReps = function(committeeData) {
    return committeeData.committeeMembers.additionalReps;
  };

  var getCommitteeSenate = function(committeeData) {
    return committeeData.committeeMembers.academicSenate;
  };

  var getCommitteeServiceRange = function(committeeData) {
    return committeeData.serviceRange;
  };

  /**
   * Loop through each committee and build terse model for UI
   * Add other UI state variables
   */
  var parseCommitteeData = function(committees, isFaculty) {
    var reducedCommitteeData = [];
    _.forEach(committees, function(committee) {
      var reducedData = {
          header: getCommitteeHeader(committee),
          chairs: decorateCommittees(getCommitteeChair(committee)),
          coChairs: decorateCommittees(getCommitteeCoChair(committee)),
          inside: decorateCommittees(getCommitteeInsideMembers(committee)),
          outside: decorateCommittees(getCommitteeOutsideMembers(committee)),
          reps: decorateCommittees(getCommitteeAdditionalReps(committee)),
          senate: decorateCommittees(getCommitteeSenate(committee)),
          show: false,
          loadError: false
        };
      // Add additional faculty info if faculty committees
      if (isFaculty) {
        angular.extend(reducedData, {
          student: getCommitteeStudent(committee),
          serviceRange: getCommitteeServiceRange(committee)
        });
      }
      reducedCommitteeData.push(reducedData);
    });
    return reducedCommitteeData;
  };

  /**
   * Add needed flags for UI state managment
   */
  var decorateCommittees = function(committees) {
    _.forEach(committees, function(committee) {
      decorateWithLoadingError(committee);
    });
    return committees;
  };

  /**
   * Add loadError flag to manage errors on photo loading
   */
  var decorateWithLoadingError = function(obj) {
    angular.extend(
      obj,
      {
        loadError: false
      });
  };

  /**
   * Get API data from factory and parse for UI consumption
   */
  var getCommittees = higherDegreeCommitteeFactory.getCommittees;

  var parseCommittees = function(data) {
    var committeeData = _.get(data, 'data');

    if (!committeeData) {
      return;
    }
    var studentCommittiees = parseCommitteeData(committeeData.studentCommittees, false);
    var facultyActiveCommittiees = parseCommitteeData(committeeData.facultyCommittees.active, true);
    var facultyCompletedCommittiees = parseCommitteeData(committeeData.facultyCommittees.completed, true);
    var committeeRequestChangeLink = committeeData.committeeRequestChangeLink;

    /**
    * Add committee data to $scope
    */
    angular.extend($scope, {
      committeeRequestChangeLink: committeeRequestChangeLink,
      studentCommittees: studentCommittiees,
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
