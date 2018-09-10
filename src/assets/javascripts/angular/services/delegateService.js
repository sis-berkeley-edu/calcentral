'use strict';

angular.module('calcentral.services').service('delegateService', function($q) {
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

  var save = function($scope, action, item) {
    $scope.errorMessage = '';
    $scope.isSaving = true;
    return action(item);
  };

  return {
    actionCompleted: actionCompleted,
    save: save
  };
});
