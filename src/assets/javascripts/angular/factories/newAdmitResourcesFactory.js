'use strict';



/**
 * SIR Factory
 */
angular.module('calcentral.factories').factory('newAdmitResourcesFactory', function(apiService) {
  var urlNewAdmitResources = '/api/my/new_admit_resources';
  // var urlNewAdmitResources = '/dummy/json/new_admit_resources.json';

  var getNewAdmitResources = function(options) {
    return apiService.http.request(options, urlNewAdmitResources);
  };

  return {
    getNewAdmitResources: getNewAdmitResources
  };
});
