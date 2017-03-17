'use strict';

var angular = require('angular');
var _ = require('lodash');

/**
 * API Test controller
 */
angular.module('calcentral.controllers').controller('ApiTestController', function(apiTestFactory, $scope, $q) {
  // Crude way of testing against the http.success responses due to insufficient status codes.
  var responseDictionary = {
    '/api/my/academics': 'collegeAndLevel',
    '/api/my/activities': 'activities',
    '/api/my/badges': 'badges',
    '/api/my/campuslinks': 'links',
    '/api/my/classes': 'classes',
    '/api/my/groups': 'groups',
    '/api/my/status': 'isLoggedIn',
    '/api/my/tasks': 'tasks',
    '/api/my/up_next': 'items',
    '/api/server_info': 'firstVisited',
    '/api/smoke_test_routes': 'routes'
  };

  var routesWithStatus = {};

  $scope.apiTest = {
    data: [],
    isLoading: true,
    showTests: false,
    running: false
  };

  /**
   * Hit an actual API endpoint
   * We first check whether the endpoint is mentioned in the dictionary
   * If so, check whether we have that key as part of the response
   * If not, we rely on the http success status (2XX)
   */
  var hitEndpoint = function(route) {
    return apiTestFactory.request({
      url: route,
      refreshCache: true
    }).then(
      function successCallback(response) {
        var responseItem = responseDictionary[route];
        if (responseItem) {
          $scope.apiTest.data[route] = response.data[responseItem] ? 'success' : 'failed';
        } else {
          $scope.apiTest.data[route] = 'success';
        }
      },
      function errorCallback() {
        $scope.apiTest.data[route] = 'failed';
      }
    );
  };

  /**
   * Gets executed at the end of the test run
   */
  var runFinished = function() {
    $scope.apiTest.running = false;
  };

  /**
   * Run the API test
   * This will hit multiple endpoints and see whether we do get successful responses back
   */
  $scope.runApiTest = function() {
    $scope.apiTest.running = true;
    $scope.apiTest.showTests = true;

    // Copy the routes (to get a clean start every time)
    $scope.apiTest.data = angular.copy(routesWithStatus);

    return $q.all(_.map(_.keys(routesWithStatus), function(route) {
      return hitEndpoint(route);
    })).then(runFinished);
  };

  /**
   * Parse the routes so we can add a status to them
   */
  var parseRoutes = function(response) {
    routesWithStatus = {};
    _.forEach(response.data.routes, function(url) {
      routesWithStatus[url] = 'pending';
    });
    $scope.apiTest.isLoading = false;
  };

  /**
   * Get all the routes we need to test for the smoke test
   * We only need to get these once
   */
  var getRoutes = function() {
    apiTestFactory.smokeTest({
      refreshCache: true
    }).then(parseRoutes);
  };

  getRoutes();
});
