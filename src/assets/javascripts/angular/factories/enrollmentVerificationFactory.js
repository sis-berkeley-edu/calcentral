'use strict';

var angular = require('angular');

/**
 * Factory for the enrollment verification messages.
 */
angular.module('calcentral.factories').factory('enrollmentVerificationFactory', function(apiService) {
  // var urlMessages = '/dummy/json/enrollment_verification_messages.json';
  var urlMessages = '/api/campus_solutions/enrollment_verification_messages';

  var getEnrollmentVerificationMessages = function(options) {
    return apiService.http.request(options, urlMessages);
  };

  return {
    getEnrollmentVerificationMessages: getEnrollmentVerificationMessages
  };
});
