'use strict';

var _ = require('lodash');

/**
 * Footer controller
 */
angular.module('calcentral.controllers').controller('FinancesLinksController', function(apiService, campusLinksFactory, finaidService, financesLinksFactory, sirFactory, userService, $scope, $q) {
  $scope.isLoading = true;
  $scope.canViewEftLink = false;
  $scope.canViewEmergencyLoanLink = false;
  $scope.canViewSummerEstimatorLink = false;

  $scope.campusLinks = {
    data: {},
    linkOrder: ['Payment Options', 'Tuition and Fees', 'Billing FAQ', 'FAFSA', 'Dream Act Application', 'Financial Aid & Scholarships Office',
      'MyFinAid (aid prior to Fall 2016)', 'Cost of Attendance', 'Graduate Financial Support', 'Work-Study', 'Financial Literacy',
      'National Student Loan Database System', 'Loan Repayment Calculator', 'Federal Student Loans', 'Student Advocate\'s Office',
      'Berkeley International Office', 'Have a loan?', 'Withdrawing or Canceling?', 'Summer Fees', 'Canceling and Withdrawing from Summer',
      'Summer Schedule & Deadlines', 'Summer Sessions Website', 'Cal Student Central']
  };
  $scope.delegateAccess = {
    title: 'Authorize others to access your billing information'
  };
  $scope.eft = {
    data: {},
    studentActive: true,
    eftLink: {
      url: 'http://studentbilling.berkeley.edu/eft.htm',
      title: 'Some refunds, payments, and paychecks may be directly deposited to your bank account'
    },
    manageAccountLink: {
      url: 'https://eftstudent.berkeley.edu/',
      title: 'Manage your electronic fund transfer accounts'
    }
  };
  $scope.fpp = {
    data: {},
    fppLink: {
      url: 'http://studentbilling.berkeley.edu/deferredPay.htm',
      title: 'Details about tuition and fees payment plan'
    },
    activatePlanLink: {
      title: 'Activate your tuition and fees payment plan'
    }
  };
  $scope.taxForm = {
    taxFormLink: {
      url: 'http://studentbilling.berkeley.edu/taxpayer.htm',
      title: 'Reduce your federal income tax based upon qualified tuition and fees paid'
    },
    viewFormLink: {
      url: 'https://www.1098t.com/',
      title: 'Start here to access your 1098-T form'
    }
  };

  var parseCampusLinks = function(response) {
    angular.extend($scope.campusLinks.data, response);
    $scope.campusLinks.data.links = sortCampusLinks(response.links);
  };

  var sortCampusLinks = function(campusLinks) {
    var orderedLinks = [];
    for (var i = 0; i < $scope.campusLinks.linkOrder.length; i++) {
      var matchedLink = matchLinks(campusLinks, $scope.campusLinks.linkOrder[i]);
      orderedLinks.push(matchedLink);
    }
    return _.filter(orderedLinks);
  };

  var matchLinks = function(campusLinks, matchLink) {
    return _.find(campusLinks, function(link) {
      return link.name === matchLink;
    });
  };

  /*
   Parse incoming response from EFT.  If the response returns a 404 for the searched
   SID, this likely means the SID has never logged on to the EFT web app before,
   so we parse it the same way we would an 'inactive' student.
   */
  var parseEftEnrollment = function(response) {
    angular.merge($scope.eft, response);
    if (_.get($scope.eft, 'data.statusCode') === 404 || _.get($scope.eft, 'data.data.eftStatus') === 'inactive') {
      $scope.eft.studentActive = false;
    }
  };

  var parseFppEnrollment = function(response) {
    angular.extend($scope.fpp.data, response.data.feed.ucSfFppEnroll);
  };

  var parseEmergencyLoanLink = function(response) {
    var links = _.get(response, 'data');
    $scope.emergencyLoanLink = _.get(links, 'emergencyLoan');
  };

  var parseSummerEstimatorLink = function(response) {
    var links = _.get(response, 'data');
    $scope.summerEstimatorLink = _.get(links, 'summerEstimator');
  };

  var parseSirStatuses = function(response) {
    return $q(function(resolve) {
      var hasUndergraduateRole = userService.profile.roles.undergrad;
      var sirStatuses = _.get(response, 'data.sirStatuses');
      var hasUndergraduateSir = !!_.find(sirStatuses, {
        isUndergraduate: true
      });
      var canViewSummerEstimatorLink = hasUndergraduateRole || hasUndergraduateSir;
      resolve(canViewSummerEstimatorLink);
    });
  };

  var setSummerEstimatorVisibility = function() {
    return $q(function(resolve) {
      $scope.canViewSummerEstimatorLink = false;
      if (!userService.profile.delegateActingAsUid) {
        sirFactory.getSirStatuses()
        .then(parseSirStatuses)
        .then(function(canViewSummerEstimatorLink) {
          $scope.canViewSummerEstimatorLink = canViewSummerEstimatorLink;
          resolve();
        });
      } else {
        resolve();
      }
    });
  };

  var setLinkVisibilities = function() {
    return $q(function(resolve) {
      $scope.canViewEftLink = userService.profile.roles.student && (userService.profile.roles.undergrad || userService.profile.roles.graduate || userService.profile.academicRoles.current.law);
      $scope.canViewEmergencyLoanLink = !userService.profile.delegateActingAsUid && !userService.profile.academicRoles.current.summerVisitor;
      $scope.canViewFppEnrollment = !(userService.profile.actingAsUid || userService.profile.advisorActingAsUid || userService.profile.delegateActingAsUid) && userService.profile.roles.student &&
                                    (userService.profile.roles.undergrad || userService.profile.roles.grad || userService.profile.roles.law) && !userService.profile.academicRoles.current.summerVisitor; 
      resolve();
    });
  };

  var initialize = function() {
    var getCampusLinks = campusLinksFactory.getLinks({
      category: 'finances'
    }).then(parseCampusLinks);

    var requests = [getCampusLinks];

    if ($scope.canViewFppEnrollment) {
      var getFppEnrollment = financesLinksFactory.getFppEnrollment().then(parseFppEnrollment);
      requests.push(getFppEnrollment);
    }
    if ($scope.canViewEftLink) {
      var getEftEnrollment = financesLinksFactory.getEftEnrollment().then(parseEftEnrollment);
      requests.push(getEftEnrollment);
    }
    if ($scope.canViewEmergencyLoanLink) {
      var getEmergencyLoanLink = financesLinksFactory.getEmergencyLoan().then(parseEmergencyLoanLink);
      requests.push(getEmergencyLoanLink);
    }
    if ($scope.canViewSummerEstimatorLink) {
      var getSummerEstimatorLink = financesLinksFactory.getSummerEstimator().then(parseSummerEstimatorLink);
      requests.push(getSummerEstimatorLink);
    }

    $q.all(requests).finally(function() {
      $scope.isLoading = false;
    });
  };

  setSummerEstimatorVisibility().then(setLinkVisibilities).then(initialize);
});
