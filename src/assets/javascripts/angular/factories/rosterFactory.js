'use strict';

/**
 * Roster Factory
 */
angular.module('calcentral.factories').factory('rosterFactory', function($http) {
  /**
   * Get the roster information
   * @param {String} context 'canvas' or 'campus'
   * @param {String} courseId ID of the course
   */
  var getRoster = function(context, courseId) {
    var url = '/api/academics/rosters/' + context + '/' + courseId;
    // var url = '/dummy/json/canvas_rosters.json';
    // var url = '/dummy/json/campus_rosters.json';
    return $http.get(url);
  };

  return {
    getRoster: getRoster
  };
});
