'use strict';

/**
 * Webcast controller
 */
angular.module('calcentral.controllers').controller('WebcastController', function(apiService, webcastFactory, $routeParams, $scope) {
  var outerTabs = ['Course Capture Sign-up', 'Course Captures'];
  $scope.accessibilityAnnounce = apiService.util.accessibilityAnnounce;

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
    return '/api/media/' + courseId;
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

  $scope.$watchCollection('[$parent.selectedCourse.sections, api.user.profile.features.videos]', function(returnValues) {
    if (returnValues[0] && returnValues[1] === true) {
      formatClassTitle();
      $scope.outerTabOptions = outerTabs;
    }
  });
});
