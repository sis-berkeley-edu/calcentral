'use strict';

var angular = require('angular');
var _ = require('lodash');

angular.module('calcentral.services').service('statusHoldsService', function() {
  /**
   * Parses any terms past the legacy cutoff.  Mirrors current functionality for now, but this will be changed in redesigns slated
   * for GL6.
   */
  var parseCsTerm = function(term) {
    _.merge(term, {
      summary: null,
      explanation: null,
      positiveIndicators: {}
    });

    var totalTermUnits = _.find(_.get(term, 'termUnits'), {
      type: {
        description: 'Total'
      }
    });
    var careerCode = _.get(term, 'academicCareer.code');

    if (term.registered === true) {
      term.summary = 'Officially Registered';
      term.explanation = term.isSummer ? 'You are officially registered for this term.' : 'You are officially registered and are entitled to access campus services.';
    }
    if (term.registered === false) {
      term.summary = 'Not Officially Registered';
      term.explanation = 'You are not entitled to access campus services until you are officially registered.  In order to be officially registered, you must pay your Tuition and Fees, and have no outstanding holds.';
    }
    if (!totalTermUnits.unitsEnrolled && !totalTermUnits.unitsTaken) {
      term.summary = 'Not Enrolled';
      term.explanation = (careerCode === 'UGRD') ? 'You are not enrolled in any classes for this term.' : 'You are not enrolled in any classes for this term. Fees will not be assessed, and any expected fee remissions or fee payment credits cannot be applied until you are enrolled in classes.  For more information, please contact your departmental graduate advisor.';
    }
    if (term.registered !== true && term.isSummer) {
      term.explanation = 'You are not officially registered for this term.';
    }
    return term;
  };

  /**
   * Parses any terms on or before the legacy cutoff.  Mirrors current functionality, this should be able to be removed in Fall 2016.
   */
  var parseLegacyTerm = function(term) {
    _.merge(term, {
      summary: null,
      explanation: null,
      positiveIndicators: {}
    });
    term.summary = term.regStatus.summary;
    term.explanation = term.regStatus.explanation;

    // Special summer parsing for the last legacy term (Summer 2016)
    if (term.isSummer) {
      if (term.regStatus.summary !== 'Registered') {
        term.summary = 'Not Officially Registered';
        term.explanation = 'You are not officially registered for this term.';
      } else {
        term.summary = 'Officially Registered';
        term.explanation = 'You are officially registered for this term.';
      }
    }

    return term;
  };

  /**
   * Matches positive indicator to registration status object by term.
   */
  var matchTermIndicators = function(positiveIndicators, registrations) {
    _.forEach(registrations, function(registration) {
      _.forEach(positiveIndicators, function(indicator) {
        if (indicator.fromTerm.id === registration.id) {
          var indicatorCode = _.trimStart(indicator.type.code, '+');
          _.set(registration.positiveIndicators, indicatorCode, true);
          if (indicator.reason.description) {
            _.set(registration.positiveIndicators, indicatorCode + 'descr', indicator.reason.description);
          }
        }
      });
    });
  };

  var getRegStatusMessages = function(messages) {
    var returnedMessages = {};
    returnedMessages.notRegistered = _.find(messages, {
      'messageNbr': '100'
    });
    returnedMessages.cnpNotificationUndergrad = _.find(messages, {
      'messageNbr': '101'
    });
    returnedMessages.cnpNotificationGrad = _.find(messages, {
      'messageNbr': '102'
    });
    returnedMessages.cnpWarningUndergrad = _.find(messages, {
      'messageNbr': '103'
    });
    returnedMessages.cnpWarningGrad = _.find(messages, {
      'messageNbr': '104'
    });
    returnedMessages.notEnrolledUndergrad = _.find(messages, {
      'messageNbr': '105'
    });
    returnedMessages.notEnrolledGrad = _.find(messages, {
      'messageNbr': '106'
    });
    return returnedMessages;
  };

  var showCNP = function(registration) {
    // Only consider showing CNP status for non-legacy, non-summer terms in which a student is not already Officially Registered
    if (!registration.isLegacy && !registration.isSummer && registration.summary !== 'Officially Registered') {
      // If a student is Not Enrolled and does not have CNP protection through R99 or ROP, do not show CNP warning as there are no classes to be dropped from.
      // We need to run this block first, as it is possible for these conditions to be met and still return 'true' in the next block.
      if (registration.summary === 'Not Enrolled' && (!registration.positiveIndicators.R99 && !registration.positiveIndicators.ROP)) {
        return false;
      }
      // If a student is not Officially Registered but is protected from CNP via R99, show protected status regardless of where we are in the term timeline.
      // Otherwise, show CNP status until CNP action is taken (start of classes for undergrads, 5 weeks into the term for grad/law)
      if ((registration.summary !== 'Officially Registered' && registration.positiveIndicators.R99) ||
          (registration.academicCareer.code === 'UGRD' && !registration.pastClassesStart) ||
          (registration.academicCareer.code !== 'UGRD' && !registration.pastAddDrop)) {
        return true;
      // If none of these conditions are met, do not show CNP status
      } else {
        return false;
      }
    } else {
      return false;
    }
  };

  var checkShownRegistrations = function(registrations) {
    var hasShown = false;
    _.forEach(registrations, function(registration) {
      if ((registration.isLegacy || registration.positiveIndicators.S09) && !registration.pastEndOfInstruction && (registration.academicCareer.code !== 'UCBX')) {
        registration.isShown = true;
        hasShown = true;
      }
    });
    return hasShown;
  };

  return {
    checkShownRegistrations: checkShownRegistrations,
    getRegStatusMessages: getRegStatusMessages,
    matchTermIndicators: matchTermIndicators,
    parseCsTerm: parseCsTerm,
    parseLegacyTerm: parseLegacyTerm,
    showCNP: showCNP
  };
});
