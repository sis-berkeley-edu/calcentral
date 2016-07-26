'use strict';

var angular = require('angular');
var _ = require('lodash');

/**
 * Footer controller
 */
angular.module('calcentral.controllers').controller('FinancesLinksController', function(apiService, campusLinksFactory, financesLinksFactory, csLinkFactory, $scope) {
  $scope.isLoading = true;
  $scope.campusLinks = {
    data: {},
    linkOrder: ['Payment Options', 'Tuition and Fees', 'Billing FAQ', 'FAFSA', 'Dream Act Application', 'Financial Aid & Scholarships Office',
                'MyFinAid (aid prior to Fall 2016)', 'Cost of Attendance', 'Graduate Financial Support', 'Work-Study', 'Financial Literacy',
                'National Student Loan Database System', 'Loan Repayment Calculator', 'Federal Student Loans', 'Student Advocates Office',
                'Berkeley International Office', 'Have a loan?', 'Withdrawing or Canceling?', 'Schedule & Deadlines', 'Summer Session', 'Cal Student Central']
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
      backtoText: 'My Finances',
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

  var matchLinks = function(campusLinks, matchLink) {
    return _.find(campusLinks, function(link) {
      return link.name === matchLink;
    });
  };

  var sortCampusLinks = function(campusLinks) {
    var orderedLinks = [];
    for (var i = 0; i < $scope.campusLinks.linkOrder.length; i++) {
      var matchedLink = matchLinks(campusLinks, $scope.campusLinks.linkOrder[i]);
      orderedLinks.push(matchedLink);
    }
    $scope.campusLinks.data.links = orderedLinks;
  };

  var parseCampusLinks = function(data) {
    angular.extend($scope.campusLinks.data, data);
    sortCampusLinks($scope.campusLinks.data.links);
  };

  /**
   Parse incoming response from EFT.  If the response returns a 404 for the searched
   SID, this likely means the SID has never logged on to the EFT web app before,
   so we parse it the same way we would an 'inactive' student.
   **/
  var parseEftEnrollment = function(data) {
    angular.merge($scope.eft, data);
    if ($scope.eft.data.statusCode === 404 || $scope.eft.data.data.eftStatus === 'inactive') {
      $scope.eft.studentActive = false;
    }
  };

  var parseFppEnrollment = function(data) {
    angular.extend($scope.fpp.data, data.data.feed.ucSfFppEnroll);
  };

  var loadEftEnrollment = function() {
    financesLinksFactory.getEftEnrollment()
      .then(parseEftEnrollment);
  };

  var loadFppEnrollment = function() {
    if (apiService.user.profile.isDirectlyAuthenticated) {
      financesLinksFactory.getFppEnrollment()
        .then(parseFppEnrollment);
    }
    return;
  };

  var loadCsLinks = function() {
    csLinkFactory.getLink({
      urlId: 'UC_CX_EMERGENCY_LOAN_FORM'
    }).then(function(data) {
      var link = _.get(data, 'data.feed.link');
      if (link) {
        link.backToText = 'Back to My Finances';
      }
      $scope.emergencyLoanLink = link;
    });
  };

  var initialize = function() {
    campusLinksFactory.getLinks({
      category: 'finances'
    }).then(parseCampusLinks)
      .then(loadEftEnrollment)
      .then(loadFppEnrollment)
      .then(loadCsLinks)
      .finally(function() {
        $scope.isLoading = false;
      });
  };

  initialize();
});
