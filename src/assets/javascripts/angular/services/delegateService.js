'use strict';

angular.module('calcentral.services').service('delegateService', function($q) {
  /**
   * Fired after an action (e.g., save) has finished
   */
  var actionCompleted = function(data) {
    var deferred = $q.defer();
    if (data.data.errored) {
      deferred.reject(data.data.feed.errmsgtext);
    } else {
      deferred.resolve({
        refresh: true
      });
    }
    return deferred.promise;
  };

  /**
   * Save a certain item in a section
   */
  var save = function($scope, action, item) {
    $scope.errorMessage = '';
    $scope.isSaving = true;
    return action(item);
  };

  // Expose methods
  return {
    actionCompleted: actionCompleted,
    save: save
  };
});
