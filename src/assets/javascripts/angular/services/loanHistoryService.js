'use strict';


var _ = require('lodash');

angular.module('calcentral.services').service('loanHistoryService', function($q, loanHistoryFactory) {

  var checkLoanActiveStatus = function() {
    return $q(function(resolve) {
      loanHistoryFactory.getSummary()
      .then(function(data) {
        var active = _.get(data, 'data.active');
        resolve(active);
      });
    });
  };

  var scrollToDefinition = function(termCode, clickEvent, location, anchorScroll) {
    clickEvent.preventDefault();
    clickEvent.stopPropagation();
    location.hash(termCode);
    anchorScroll();
  };

  return {
    checkLoanActiveStatus: checkLoanActiveStatus,
    scrollToDefinition: scrollToDefinition
  };

});
