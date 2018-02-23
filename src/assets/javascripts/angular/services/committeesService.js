'use strict';

var angular = require('angular');
var _ = require('lodash');

angular.module('calcentral.services').service('committeesService', function() {

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
      case 'exclamation-circle': {
        iconStyle = 'cc-icon fa fa-exclamation-circle cc-icon-red';
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
   * Loop through each committee and build terse model for UI
   * Add other UI state variables
   */
  var parseCommitteeData = function(committees, isFaculty) {
    var reducedCommitteeData = [];
    _.forEach(committees, function(committee) {
      var reducedData = {
          header: getCommitteeHeader(committee),
          milestoneAttempts: committee.milestoneAttempts,
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

  return {
    parseCommitteeData: parseCommitteeData
  };
});
