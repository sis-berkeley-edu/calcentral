'use strict';

var _ = require('lodash');

angular.module('calcentral.services').service('committeesService', function() {
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

  var decorateCommittees = function(committees) {
    _.forEach(committees, function(committee) {
      decorateWithLoadingError(committee);
    });
    return committees;
  };

  var decorateWithLoadingError = function(obj) {
    angular.extend(
      obj,
      {
        loadError: false
      });
  };

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
