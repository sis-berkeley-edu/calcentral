'use strict';

var angular = require('angular');
var _ = require('lodash');

angular.module('calcentral.services').service('statusHoldsService', function(userService) {
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
    if (term.registered === true) {
      term.summary = 'Officially Registered';
      term.explanation = term.isSummer ? 'You are officially registered for this term.' : 'You are officially registered and are entitled to access campus services.';
    }
    if (term.registered === false) {
      term.summary = 'Not Officially Registered';
      term.explanation = term.isSummer ? 'You are not officially registered for this term.' : 'You are not entitled to access campus services until you are officially registered.  In order to be officially registered, you must pay your Tuition and Fees, and have no outstanding holds.';
    }
    if (term.registered === false && userService.profile.roles.undergrad && term.pastClassesStart) {
      term.summary = 'Not Enrolled';
      term.explanation = term.isSummer ? 'You are not officially registered for this term.' : 'You are not enrolled in any classes for this term.';
    }
    if (term.registered === false && (userService.profile.roles.graduate || userService.profile.roles.law) && term.pastAddDrop) {
      term.summary = 'Not Enrolled';
      term.explanation = term.isSummer ? 'You are not officially registered for this term.' : 'You are not enrolled in any classes for this term. Fees will not be assessed, and any expected fee remissions or fee payment credits cannot be applied until you are enrolled in classes.  For more information, please contact your departmental graduate advisor.';
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

  return {
    getRegStatusMessages: getRegStatusMessages,
    matchTermIndicators: matchTermIndicators,
    parseCsTerm: parseCsTerm,
    parseLegacyTerm: parseLegacyTerm
  };
});
