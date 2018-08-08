'use strict';



/**
 * Academic Profile controller
 */
angular.module('calcentral.controllers').controller('AcademicProfileController', function(academicsService, apiService, $scope) {
  $scope.profilePicture = {};
  $scope.isNonDegreeSeekingSummerVisitor = academicsService.isNonDegreeSeekingSummerVisitor(apiService.user.profile.academicRoles);
});
