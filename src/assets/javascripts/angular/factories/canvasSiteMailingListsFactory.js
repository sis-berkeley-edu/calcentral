'use strict';

var angular = require('angular');

/**
 * Canvas Site Mailing Lists Factory - API interface for the admin-level 'Manage bCourses Site Mailing Lists' tool.
 */
angular.module('calcentral.factories').factory('canvasSiteMailingListsFactory', function($http) {
  var deleteSiteMailingList = function(canvasCourseId) {
    return $http.post('/api/academics/canvas/mailing_lists/' + canvasCourseId + '/delete');
  };

  var getSiteMailingList = function(canvasCourseId) {
    return $http.get('/api/academics/canvas/mailing_lists/' + canvasCourseId);
  };

  var populateSiteMailingList = function(canvasCourseId) {
    return $http.post('/api/academics/canvas/mailing_lists/' + canvasCourseId + '/populate');
  };

  var registerSiteMailingList = function(canvasCourseId, list) {
    return $http.post('/api/academics/canvas/mailing_lists/' + canvasCourseId + '/create', {
      listName: list.name,
      listType: list.listType
    });
  };

  return {
    deleteSiteMailingList: deleteSiteMailingList,
    getSiteMailingList: getSiteMailingList,
    populateSiteMailingList: populateSiteMailingList,
    registerSiteMailingList: registerSiteMailingList
  };
});
