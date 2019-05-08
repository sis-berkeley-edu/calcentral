'use strict';

/**
 * Roster Factory
 */
angular.module('calcentral.factories').factory('rosterFactory', function($http) {
  /**
   * Get the roster information
   * @param {String} courseId ID of the course
   * @return {Object} roster data
   */
  var getRoster = function(courseId) {
    var url = '/api/academics/rosters/campus/' + courseId;
    // var url = '/dummy/json/campus_rosters.json';
    return $http.get(url);
  };

  return {
    getRoster: getRoster
  };
});
