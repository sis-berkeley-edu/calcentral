'use strict';

var _ = require('lodash');
var angular = require('angular');

/**
 * Controller gets students linked to a delegate user account
 */
angular.module('calcentral.controllers').controller('DelegateStudentsController', function(apiService, adminFactory, delegateFactory, $scope) {
  $scope.delegateStudents = {
    isLoading: true
  };

  /**
   * `delegateAccessPrivileges` here mean __only__ those that allow the delegate
   * "linkable" access to the student's profile. The `phone` privilege by itself
   * does not grant that access.
   */
  var delegateAccessPrivileges = [
    'financial',
    'phone',
    'viewEnrollments',
    'viewGrades'
  ];

  /**
   * setDelegateAccess() adds `delegateAccess` property on student, if and only
   * if the student has granted at least one `viewable` (i.e., other than phone)
   * privilege.
   */
  var setDelegateAccess = function(student) {
    var phone = 'phone';
    var viewable = _.some(delegateAccessPrivileges, function(key) {
      return student.privileges[key] && key !== phone;
    });
    student.selfDelegating = (student.uid === apiService.user.profile.uid || student.campusSolutionsId === apiService.user.profile.campusSolutionsID);
    if (student.selfDelegating) {
      $scope.showSelfDelegatingMessage = true;
    }

    student.delegateAccess = (viewable && !student.selfDelegating);
    student.limitedPrivileges = !viewable;

    /**
     * If at least one student grants no privileges, this flag lets us show the
     * global 'No privileges' explanatory paragraph in the template.
     */
    $scope.showNoPrivilegesMessage = $scope.showNoPrivilegesMessage || (!viewable && !student.privileges[phone]);

    /**
     * If at least one student grants only phone privilege, this flag lets us
     * show the global 'phone-and-in-person privileges' explanatory paragraph in
     * the template.
     */
    $scope.showPhoneInPersonPrivilegesMessage = $scope.showPhoneInPersonPrivilegesMessage || (!viewable && student.privileges[phone]);

    /**
     * If at least one student has a null UID, this flag lets us show the global
     * `Account Issue` explanatory paragraph in the template.
     */
    $scope.showAccountIssueMessage = $scope.showAccountIssueMessage || (!student.uid);
  };

  var getStudents = function() {
    return delegateFactory.getStudents().then(function(response) {
      angular.extend($scope, _.get(response, 'data.feed'));

      var students = _.get(response, 'data.feed.students');
      _.each(students, setDelegateAccess);
      $scope.students = students;
      $scope.delegateStudents.isLoading = false;
    });
  };

  $scope.delegateStudents.actAs = function(uid) {
    return adminFactory.delegateActAs({
      uid: uid
    }).then(apiService.util.redirectToHome);
  };

  getStudents();
});
