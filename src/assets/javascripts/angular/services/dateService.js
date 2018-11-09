'use strict';

angular.module('calcentral.services').service('dateService', [function() {
  var dateService = {
    now: Date.now()
  };
  angular.extend(dateService, require('date-fns'));
  return dateService;
}]);
