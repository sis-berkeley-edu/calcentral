import { setTargetUserId } from 'Redux/actions/advisingActions';

var _ = require('lodash');

angular
  .module('calcentral.controllers')
  .controller('UserOverviewController', function(
    academicStandingsFactory,
    academicsService,
    adminService,
    advisingFactory,
    apiService,
    committeesService,
    enrollmentVerificationFactory,
    linkService,
    statusHoldsService,
    $route,
    $routeParams,
    $scope,
    $ngRedux
  ) {
    linkService.addCurrentRouteSettings($scope);

    $scope.academics = {
      isLoading: true,
      excludeLinksToRegistrar: true,
    };
    $scope.committees = {
      isLoading: true,
      showCommittees: false,
    };
    $scope.ucAdvisingResources = {
      links: {},
      isLoading: true,
    };
    $scope.planSemestersInfo = {
      isLoading: true,
    };
    $scope.holdsInfo = {
      isLoading: true,
    };
    $scope.isAdvisingStudentLookup = $route.current.isAdvisingStudentLookup;
    $scope.regStatus = {
      registrations: [],
      show: false,
    };
    $scope.residency = {};
    $scope.visa = {
      code: '',
      description: '',
    };
    $scope.targetUser = {
      isLoading: true,
    };
    $scope.statusHolds = {
      isLoading: true,
    };
    $scope.highCharts = {
      dataSeries: [],
    };
    $scope.studentSuccess = {
      gpaChart: {
        series: {
          className: 'cc-student-success-color-blue',
        },
        xAxis: {
          floor: 0,
          visible: false,
        },
        yAxis: {
          min: 0,
          max: 4.0,
          visible: false,
        },
      },
      showChart: true,
      isLoading: true,
    };
    $scope.degreeProgress = {
      graduate: {},
      undergraduate: {},
      isLoading: true,
    };
    $scope.standingIsVisible = false;

    $scope.profilePicture = {};

    var parseAdvisingResources = function(response) {
      var links = $scope.ucAdvisingResources.links;
      angular.extend(links, _.get(response, 'data.feed'));
      linkService.addCurrentPagePropertiesToResources(
        links,
        $scope.currentPage.name,
        $scope.currentPage.url
      );
      $scope.ucAdvisingResources.isLoading = false;
    };

    var defaultErrorDescription = function(status) {
      if (status === 403) {
        return "You are not authorized to view this user's data.";
      } else {
        return "Sorry, there was a problem fetching this user's data. Contact CalCentral support if the error persists.";
      }
    };

    var errorReport = function(status, errorDescription) {
      return {
        summary: status === 403 ? 'Access Denied' : 'Unexpected Error',
        description: errorDescription || defaultErrorDescription(status),
      };
    };

    var loadProfile = function() {
      var targetUserUid = $routeParams.uid;

      $ngRedux.dispatch(setTargetUserId(targetUserUid));

      advisingFactory
        .getStudent({
          uid: targetUserUid,
        })
        .then(
          function successCallback(response) {
            angular.extend(
              $scope.targetUser,
              _.get(response, 'data.attributes')
            );
            angular.extend(
              $scope.residency,
              _.get(response, 'data.residency.residency')
            );
            setVisa(_.get(response, 'data.demographics.feed.usaCountry.visa'));
            $scope.targetUser.academicRoles = _.get(
              response,
              'data.academicRoles'
            );
            $scope.targetUser.ldapUid = targetUserUid;
            $scope.targetUser.addresses = apiService.profile.fixFormattedAddresses(
              _.get(response, 'data.contacts.feed.addresses')
            );
            $scope.targetUser.phones = _.get(
              response,
              'data.contacts.feed.phones'
            );
            $scope.targetUser.emails = _.get(
              response,
              'data.contacts.feed.emails'
            );
            // 'student.fullName' is expected by shared code (e.g., photo unavailable widget)
            $scope.targetUser.fullName = $scope.targetUser.defaultName;
            apiService.util.setTitle($scope.targetUser.defaultName);

            // Get links to advising resources
            advisingFactory
              .getAdvisingResources({
                uid: targetUserUid,
              })
              .then(parseAdvisingResources);
          },
          function errorCallback(response) {
            $scope.targetUser.error = errorReport(
              _.get(response, 'data.status'),
              _.get(response, 'data.error')
            );
          }
        )
        .finally(function() {
          $scope.targetUser.isLoading = false;
        });
    };

    var setVisa = function(visa) {
      if (!visa || visa.status !== 'G') {
        return;
      }
      switch (visa.type.code) {
        case 'F1': {
          $scope.visa.code = 'F-1';
          $scope.visa.description = 'International Student';
          break;
        }
        case 'J1': {
          $scope.visa.code = 'J-1';
          $scope.visa.description = 'International Student';
          break;
        }
        case 'PR': {
          $scope.visa.code = 'PR';
          $scope.visa.description = 'Verified';
          break;
        }
        default: {
          $scope.visa.code = '';
          $scope.visa.description = 'Other Verified';
        }
      }
    };

    var processSemesters = function(planSemesters) {
      _.forEach(planSemesters, function(semester) {
        angular.extend(semester, {
          show:
            ['current', 'previous', 'next'].indexOf(semester.timeBucket) > -1,
        });
      });
    };

    var prepareSchedulePlannerLink = function(
      studentPlans,
      currentRegistrationTermId
    ) {
      var uniqueCareerCodes = academicsService.getUniqueCareerCodes(
        studentPlans
      );
      if (uniqueCareerCodes.length > 0 && currentRegistrationTermId) {
        $scope.schedulePlanner = {
          careerCode: _.first(uniqueCareerCodes),
          termId: currentRegistrationTermId,
          studentUid: $routeParams.uid,
        };
      }
    };

    var loadAcademics = function() {
      advisingFactory
        .getStudentAcademics({
          uid: $routeParams.uid,
        })
        .then(
          function successCallback(response) {
            angular.extend($scope, _.get(response, 'data'));

            processSemesters($scope.planSemesters);
            prepareSchedulePlannerLink(
              _.get($scope, 'collegeAndLevel.plans'),
              _.get($scope, 'collegeAndLevel.termId')
            );
            $scope.isNonDegreeSeekingSummerVisitor = academicsService.isNonDegreeSeekingSummerVisitor(
              $scope.targetUser.academicRoles
            );
            $scope.showResidency =
              $scope.targetUser.roles.student &&
              academicsService.showResidency(
                $scope.targetUser.academicRoles.current
              );

            if (_.get($scope, 'updatePlanUrl.url')) {
              linkService.addCurrentPagePropertiesToLink(
                $scope.updatePlanUrl,
                $scope.currentPage.name,
                $scope.currentPage.url
              );
            }
          },
          function errorCallback(response) {
            $scope.academics.error = errorReport(
              _.get(response, 'status'),
              _.get(response, 'data.error')
            );
          }
        )
        .finally(function() {
          $scope.academics.isLoading = false;
          $scope.planSemestersInfo.isLoading = false;
        });
    };

    var loadRegistrations = function() {
      advisingFactory
        .getStudentRegistrations({
          uid: $routeParams.uid,
        })
        .then(function(response) {
          var registrations = _.get(response, 'data.registrations');
          _.forEach(registrations, function(registration) {
            if (_.get(registration, 'showRegStatus')) {
              $scope.regStatus.registrations.push(registration);
            }
          });
          if ($scope.regStatus.registrations.length) {
            $scope.regStatus.show = true;
          }
        })
        .finally(function() {
          $scope.statusHolds.isLoading = false;
        });
    };

    var loadStudentSuccess = function() {
      advisingFactory
        .getStudentSuccess({
          uid: $routeParams.uid,
        })
        .then(function successCallback(response) {
          $scope.studentSuccess.outstandingBalance = _.get(
            response,
            'data.outstandingBalance'
          );
          parseTermGpa(response);
        })
        .finally(function() {
          $scope.studentSuccess.isLoading = false;
        });
    };

    var showTip = function() {
      $scope.degreeProgress.undergraduate.tipVisible = true;
      return false;
    };

    var loadDegreeProgresses = function() {
      advisingFactory
        .getDegreeProgressGraduate({
          uid: $routeParams.uid,
        })
        .then(function(response) {
          $scope.degreeProgress.graduate.progresses = _.get(
            response,
            'data.feed.degreeProgress'
          );
          $scope.degreeProgress.graduate.errored = _.get(response, 'errored');
        })
        .then(function() {
          advisingFactory
            .getDegreeProgressUndergrad({
              uid: $routeParams.uid,
            })
            .then(function(response) {
              $scope.degreeProgress.undergraduate.progresses = _.get(
                response,
                'data.feed.degreeProgress.progresses'
              );
              $scope.degreeProgress.undergraduate.transferCreditReviewDeadline = _.get(
                response,
                'data.feed.degreeProgress.transferCreditReviewDeadline'
              );
              $scope.degreeProgress.undergraduate.showTip = showTip;
              $scope.degreeProgress.undergraduate.links = _.get(
                response,
                'data.feed.links'
              );
              $scope.degreeProgress.undergraduate.errored = _.get(
                response,
                'errored'
              );
            })
            .finally(function() {
              $scope.degreeProgress.undergraduate.showCard =
                apiService.user.profile.features.csDegreeProgressUgrdAdvising &&
                ($scope.targetUser.academicRoles.historical.ugrd ||
                  $scope.degreeProgress.undergraduate.progresses.length);
              $scope.degreeProgress.graduate.showCard =
                apiService.user.profile.features.csDegreeProgressGradAdvising &&
                ($scope.degreeProgress.graduate.progresses.length ||
                  $scope.targetUser.academicRoles.current.grad ||
                  $scope.targetUser.academicRoles.current.law);
              $scope.degreeProgress.undergraduate.showCard = $scope
                .degreeProgress.graduate.showCard
                ? false
                : $scope.degreeProgress.undergraduate.showCard;
              $scope.degreeProgress.isLoading = false;
            });
        });
    };

    var chartGpaTrend = function(termGpas) {
      var chartData = _.map(termGpas, 'termGpa');

      // The last element of the data series must also contain custom marker information to show the GPA.
      chartData[chartData.length - 1] = {
        y: chartData[chartData.length - 1],
        dataLabels: {
          color: chartData[chartData.length - 1] >= 2 ? '#2b6281' : '#cf1715',
          enabled: true,
          style: {
            fontSize: '12px',
          },
        },
        marker: {
          enabled: true,
          fillColor:
            chartData[chartData.length - 1] >= 2 ? '#2b6281' : '#cf1715',
          radius: 3,
          symbol: 'circle',
        },
      };
      $scope.highCharts.dataSeries.push(chartData);
    };

    var parseTermGpa = function(response) {
      var termGpas = _.get(response, 'data.termGpa');
      var termGpasWithZero = _.get(response, 'data.termGpaWithZero');
      $scope.studentSuccess.termGpa = _.sortBy(termGpas, ['termId']);
      $scope.studentSuccess.termGpaWithZero = _.sortBy(termGpasWithZero, [
        'termId',
      ]);
      if (termGpas.length >= 2) {
        chartGpaTrend(termGpas);
      } else {
        $scope.studentSuccess.showChart = false;
      }
    };

    var loadCommittees = function() {
      advisingFactory
        .getStudentCommittees({
          uid: $routeParams.uid,
        })
        .then(function(response) {
          var committeeData = _.get(response, 'data');
          if (!committeeData) {
            return;
          }
          var studentCommittees = committeesService.parseCommitteeData(
            committeeData.studentCommittees,
            false
          );

          angular.extend($scope, {
            studentCommittees: studentCommittees,
          });
        })
        .finally(function() {
          $scope.committees.isLoading = false;
          $scope.committees.showCommittees =
            ($scope.targetUser.roles.student ||
              $scope.targetUser.roles.exStudent) &&
            $scope.studentCommittees.length > 0;
        });
    };

    var loadHasStanding = function() {
      return academicStandingsFactory.getStandings().then(function(response) {
        var currentStandings = _.get(response, 'data.feed.currentStandings');
        if (
          currentStandings.length !== 0 &&
          currentStandings[0].acadStandingStatus !== 'GST'
        ) {
          $scope.hasStandingAlert = true;
        }
        if (
          $scope.targetUser.academicRoles.current.ugrd &&
          !$scope.targetUser.academicRoles.current.ugrdNonDegree
        ) {
          $scope.standingIsVisible = true;
        }
      });
    };

    $scope.totalTransferUnits = function() {
      var unitsAdjusted = _.get(
        $scope,
        'transferCredit.ucTransferCrseSch.unitsAdjusted'
      );
      var totalTestUnits = _.get(
        $scope,
        'transferCredit.ucTestComponent.totalTestUnits'
      );
      return academicsService.totalTransferUnits(unitsAdjusted, totalTestUnits);
    };

    $scope.expireAcademicsCache = function() {
      advisingFactory.expireAcademicsCache({
        uid: $routeParams.uid,
      });
    };

    $scope.targetUser.actAs = function() {
      adminService.actAs($scope.targetUser);
    };

    $scope.$on('calcentral.api.user.isAuthenticated', function(
      event,
      isAuthenticated
    ) {
      // Set necessary function declarations.
      $scope.cnpStatusIcon = statusHoldsService.cnpStatusIcon;
      $scope.regStatusIcon = statusHoldsService.regStatusIcon;

      if (isAuthenticated) {
        // Refresh user properties because the canSeeCSLinks property is sensitive to the current route.
        apiService.user
          .fetch()
          .then(loadProfile)
          .then(loadAcademics)
          .then(loadStudentSuccess)
          .then(loadRegistrations)
          .then(loadDegreeProgresses)
          .then(loadCommittees)
          .then(loadHasStanding);
      }
    });
  });
