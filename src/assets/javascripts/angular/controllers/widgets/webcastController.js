'use strict';

var angular = require('angular');

/**
 * Webcast controller
 */
angular.module('calcentral.controllers').controller('WebcastController', function(apiService, webcastFactory, $route, $routeParams, $scope) {
  // Is this for an official campus class or for a Canvas course site?
  var courseMode = 'campus';
  var outerTabs = ['Course Capture Sign-up', 'Course Captures'];
  $scope.accessibilityAnnounce = apiService.util.accessibilityAnnounce;

  /**
   * Dropdown defaults to first video in the list
   */
  var selectMediaOptions = function() {
    if ($scope.videos) {
      if ($routeParams.video) {
        for (var i = 0; i < $scope.videos.length; i++) {
          if ($scope.videos[i].youTubeId === $routeParams.video) {
            $scope.selectedVideo = $scope.videos[i];
            break;
          }
        }
      }
      $scope.selectedVideo = $scope.selectedVideo || $scope.videos[0];
    }
  };

  var webcastUrl = function(courseId) {
    // return '/dummy/json/media.json';
    if (courseMode === 'canvas') {
      return '/api/canvas/media/' + courseId;
    } else {
      return '/api/media/' + courseId;
    }
  };

  var getWebcasts = function(title) {
    webcastFactory.getWebcasts({
      url: webcastUrl(title)
    }).then(
      function(response) {
        angular.extend($scope, response.data);
        selectMediaOptions();
        var showSignUpTab = $scope.eligibleForSignUp && $scope.eligibleForSignUp.length > 0;
        $scope.currentTabSelection = showSignUpTab ? outerTabs[0] : outerTabs[1];
      }
    );
  };

  var formatClassTitle = function() {
    var courseYear = encodeURIComponent($scope.selectedSemester.termYear);
    var courseSemester = encodeURIComponent($scope.selectedSemester.termCode);
    var courseDepartment = encodeURIComponent($scope.selectedCourse.dept);
    var courseCatalog = encodeURIComponent($scope.selectedCourse.courseCatalog);
    var title = courseYear + '/' +
                courseSemester + '/' +
                apiService.util.encodeSlash(courseDepartment) + '/' +
                apiService.util.encodeSlash(courseCatalog);
    getWebcasts(title);
  };

  $scope.switchTabOption = function(tabOption) {
    $scope.currentTabSelection = tabOption;
  };

  $scope.announceVideoSelect = function() {
    $scope.accessibilityAnnounce('Selected video \'' + $scope.selectedVideo.lecture + '\' loaded');
  };

  if ($routeParams.canvasCourseId || $route.current.isEmbedded) {
    courseMode = 'canvas';
    var canvasCourseId;
    if ($route.current.isEmbedded) {
      canvasCourseId = 'embedded';
      $scope.isEmbedded = true;
    } else {
      canvasCourseId = $routeParams.canvasCourseId;
    }
    apiService.util.setTitle('Course Captures');
    getWebcasts(canvasCourseId);
    $scope.outerTabOptions = outerTabs;
  } else {
    $scope.$watchCollection('[$parent.selectedCourse.sections, api.user.profile.features.videos]', function(returnValues) {
      if (returnValues[0] && returnValues[1] === true) {
        formatClassTitle();
        $scope.outerTabOptions = outerTabs;
      }
    });
  }
});
