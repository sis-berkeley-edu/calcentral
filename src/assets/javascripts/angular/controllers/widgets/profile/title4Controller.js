'use strict';

var _ = require('lodash');

angular.module('calcentral.controllers').controller('Title4Controller', function(finaidFactory, $rootScope, $scope) {
  $scope.title4 = {
    isLoading: true,
    showMessage: false
  };

  var sendEvent = function() {
    $rootScope.$broadcast('calcentral.custom.api.finaid.approvals');
  };

  $scope.sendResponseT4 = function(response) {
    $scope.title4.isLoading = true;
    $scope.title4.showMessage = false;
    finaidFactory.postT4Response(response).then(sendEvent);
  };

  // Parse the finaid information
  var parseFinaid = function(data) {
    angular.extend($scope.title4, {
      isApproved: _.get(data, 'feed.finaidSummary.title4.approved')
    });
  };

  var getFinaidPermissions = function(options) {
    return finaidFactory.getSummary(options).then(
      function successCallback(response) {
        $scope.title4.hasFinaid = !!_.get(response, 'data.feed.finaidSummary.finaidYears.length');
        if ($scope.title4.hasFinaid) {
          parseFinaid(response.data);
        }
        $scope.title4.isLoading = false;
        return response.data;
      }
    );
  };

  getFinaidPermissions();

  var refreshAidYearInfo = function(response) {
    var aidYears = _.get(response, 'data.feed.finaidSummary.finaidYears');
    var aidYearsIds = _.map(aidYears, 'id');
    _.forEach(aidYearsIds, function(aidYearId) {
      finaidFactory.getFinaidYearInfo({
        finaidYearId: aidYearId,
        refreshCache: true
      });
    });
  };

  $scope.$on('calcentral.custom.api.finaid.approvals', function() {
    getFinaidPermissions({
      refreshCache: true
    }).then(refreshAidYearInfo);
  });
});
