'use strict';

var angular = require('angular');

/**
 * Canvas Site Mailing List Factory; API endpoint for the course-level bCourses tool to create a single mailing list.
 */
angular.module('calcentral.factories').factory('canvasSiteMailingListFactory', function($http) {
  var createMailingList = function(canvasCourseId) {
    return $http.post('/api/academics/canvas/mailing_list/' + canvasCourseId + '/create');
  };

  var getMailingList = function(canvasCourseId) {
    return $http.get('/api/academics/canvas/mailing_list/' + canvasCourseId);
  };

  return {
    createMailingList: createMailingList,
    getMailingList: getMailingList
  };
});
