'use strict';

var _ = require('lodash');
var angular = require('angular');

/**
 * Controller populates academic dates from TBD calendar API.
 */
angular.module('calcentral.controllers').controller('AcademicDatesController', function(apiService, academicDatesFactory, $scope) {
  angular.extend($scope, {
    academicDates: {
      items: [],
      isLoading: true
    }
  });

  var formatItemTitles = function(items) {
    var formattedItems = _.map(items, function(item) {
      item.isList = _.isArray(item.title);
      return item;
    });
    return formattedItems;
  };

  var getAcademicDates = function() {
    academicDatesFactory.getAcademicDates().then(
      function successCallback(response) {
        var items = _.get(response, 'data.feed.academicDates');
        $scope.academicDates.items = formatItemTitles(items);
        $scope.academicDates.isLoading = false;
      }
    );
  };

  getAcademicDates();
});
