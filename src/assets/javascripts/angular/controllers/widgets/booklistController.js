'use strict';

var _ = require('lodash');

/**
 * Textbook controller
 */
angular.module('calcentral.controllers').controller('BooklistController', function(academicsService, apiService, csLinkFactory, textbookFactory, $routeParams, $scope, $q) {
  $scope.semesterBooks = [];
  $scope.lawTextbooksLink = {};
  var requests = [];

  var getTextbook = function(courseInfo, courseNumber) {
    return textbookFactory.getTextbooks({
      params: courseInfo
    }).then(
      function successCallback(response) { 
        var data = _.get(response, 'data');
        data.course = courseNumber;
        if (data.statusCode && data.statusCode >= 400) {
          data.errorMessage = data.body;
        }
        $scope.semesterBooks.push(data);
        $scope.semesterBooks.sort(function(a, b) {
          return a.course.localeCompare(b.course);
        });
      }
    );
  };

  var addToRequests = function(semester) {
    var enrolledCourses = academicsService.getClassesSections(semester.classes, false);
    var waitlistedCourses = academicsService.getClassesSections(semester.classes, true);
    var courses = enrolledCourses.concat(waitlistedCourses);

    for (var c = 0; c < courses.length; c++) {
      // get textbooks for each course
      var selectedCourse = courses[c];
      var courseInfo = academicsService.textbookRequestInfo(selectedCourse, semester);
      var courseTitle = selectedCourse.course_code;
      if (selectedCourse.multiplePrimaries) {
        courseTitle = courseTitle + ' ' + selectedCourse.sections[0].section_label;
      }

      requests.push(getTextbook(courseInfo, courseTitle));
    }
  };

  var getSemesterTextbooks = function(semesters) {
    var semester = academicsService.findSemester(semesters, $routeParams.semesterSlug);
    addToRequests(semester);

    $scope.semesterName = semester.name;
    $scope.semesterSlug = semester.slug;

    $q.all(requests).then(function() {
      $scope.isLoading = false;
    });
  };

  $scope.isLawCourse = function(course) {
    return course.includes('LAW');
  };

  $scope.$watchCollection('[$parent.semesters, api.user.profile.features.textbooks]', function(returnValues) {
    if (returnValues[0] && returnValues[1] === true) {
      getSemesterTextbooks(returnValues[0]);

      if (apiService.user.profile.roles.law) {
        csLinkFactory.getLink({
          urlId: 'UC_CX_LAW_BOOK'
        }).then(function(response) {
          $scope.lawTextbooksLink = _.get(response, 'data.link');
        });
      }
    }
  });
});
