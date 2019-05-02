'use strict';

var _ = require('lodash');

/**
 * Footer controller
 */
angular.module('calcentral.controllers').controller('FinancesLinksController', function(campusLinksFactory, csLinkFactory, financesLinksFactory, sirFactory, userService, $scope, $q) {
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
      'Summer Schedule & Deadlines', 'Summer Sessions Website', 'Cal Student Central', 'Debit Account', 'Meal Plan Balance', 'Learn about meal plans']
  };
  $scope.csLinks = {
    eft: {},
    iGrad: {},
    verificationAndAppeals: {},
    optionalDocuments: {},
    taxCreditFormLink: {}
  };
  $scope.delegateAccess = {
    title: 'Authorize others to access your billing information'
  };
  $scope.eft = {
    data: {},
    studentActive: true,
    manageAccountLink: {
      url: 'https://eftstudent.berkeley.edu/',
      title: 'Manage direct deposit accounts',
      name: 'Enroll in Direct Deposit'
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
    }
  };

  var getCampusLinks = campusLinksFactory.getLinks({
    category: 'finances'
  }).then(
    function successCallback(response) {
      angular.extend($scope.campusLinks.data, response);
      $scope.campusLinks.data.links = sortCampusLinks(response.links);
    }
  );

  var getVerificationAndAppealsLink = csLinkFactory.getLink({
    urlId: 'UC_CX_FA_FINRES_FAFSA'
  }).then(
    function successCallback(response) {
      $scope.csLinks.verificationAndAppeals = _.get(response, 'data.link');
    }
  );

  var getOptionalDocumentsLink = csLinkFactory.getLink({
    urlId: 'UC_CX_FA_FINRES_FORMS'
  }).then(
    function successCallback(response) {
      $scope.csLinks.optionalDocuments = _.get(response, 'data.link');
    }
  );

  var getEftLink = csLinkFactory.getLink({
    urlId: 'UC_CX_STDNT_BPS_EFT'
  }).then(
    function successCallback(response) {
      $scope.csLinks.eft = _.get(response, 'data.link');
    }
  );

  var getTaxCreditFormLink = csLinkFactory.getLink({
    urlId: 'UC_CX_STDNT_1098T_TAX_FORM'
  }).then(
    function successCallback(response) {
      $scope.csLinks.taxCreditFormLink = _.get(response, 'data.link');
    }
  );

  var getIGradLink = csLinkFactory.getLink({
    urlId: 'UC_CX_FA_IGRAD'
  }).then(function(response) {
    $scope.csLinks.iGrad = _.get(response, 'data.link');
  });

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
    } else {
      if ($scope.eft.data.data.eftStatus === 'active') {
        $scope.eft.manageAccountLink.name = 'Manage Direct Deposit';
      }
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
                                    (userService.profile.roles.undergrad || userService.profile.roles.graduate || userService.profile.roles.law) && !userService.profile.academicRoles.current.summerVisitor;
      resolve();
    });
  };

  var initialize = function() {
    var requests = [getCampusLinks, getEftLink, getIGradLink, getTaxCreditFormLink, getVerificationAndAppealsLink, getOptionalDocumentsLink];

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
