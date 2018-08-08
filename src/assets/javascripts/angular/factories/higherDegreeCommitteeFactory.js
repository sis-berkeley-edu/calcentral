'use strict';



/**
 * Higher Degree Committees Factory
 */
angular.module('calcentral.factories').factory('higherDegreeCommitteeFactory', function(apiService) {
  // var url = '/dummy/json/committees.json';
  var url = '/api/my/committees/';

  var getCommittees = function(options) {
    return apiService.http.request(options, url);
  };

  return {
    getCommittees: getCommittees
  };
});
