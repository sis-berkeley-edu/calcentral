'use strict';

var angular = require('angular');

/**
 * Factory for the enrollment verification messages.
 */
angular.module('calcentral.factories').factory('enrollmentVerificationFactory', function(apiService) {
  var urlMessages = '/api/academics/enrollment_verification';
  // urlMessages = '/dummy/json/enrollment_verification.json';

  var getEnrollmentVerificationData = function(options) {
    return apiService.http.request(options, urlMessages);
  };

  return {
    getEnrollmentVerificationData: getEnrollmentVerificationData
  };
});
