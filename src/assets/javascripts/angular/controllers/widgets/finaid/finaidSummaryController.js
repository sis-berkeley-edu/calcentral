'use strict';

var _ = require('lodash');

import 'icons/info.svg';

import { fetchAgreements } from 'redux/actions/agreementsActions';
import { fetchChecklistItems } from 'redux/actions/checklistItemsActions';

/**
 * Finaid Summary controller
 */
angular
  .module('calcentral.controllers')
  .controller('FinaidSummaryController', function(
    finaidFactory,
    finaidService,
    tasksFactory,
    $location,
    $q,
    $route,
    $routeParams,
    $scope,
    $ngRedux
  ) {
    const checkLoading = () => {
      const {
        myAgreements: { loaded: agreementsLoaded },
        myChecklistItems: { loaded: checklistsLoaded },
      } = $ngRedux.getState();

      if (agreementsLoaded && checklistsLoaded) {
        $scope.financialAidSummary.isLoading = false;
      }
    };

    $scope.financialAidSummary = {
      isLoading: true,
      factoriesLoading: true,
      selected: {},
      tasksCount: 0,
      giftAidDetail: {},
      waiversDetail: {},
      loansWorkStudyDetail: {},
      tipVisibleGiftAid: false,
      tipVisibleNetCost: false,
      tipVisibleThirdParty: false,
      showDecimals: false,
    };

    $scope.financialAidSummary.changeAidYear = function() {
      finaidService.setFinaidYear(
        $scope.financialAidSummary.selected.finaidYear
      );
      updateSummary();
      updateUrl();
      checkForDecimalValues($scope.financialAidSummary.selected);
    };

    var formatCurrency = function(amount) {
      return $scope.financialAidSummary.showDecimals
        ? amount.toFixed(2)
        : amount;
    };

    var toggleTipGiftAid = function() {
      $scope.financialAidSummary.selected.tipVisibleGiftAid = !$scope
        .financialAidSummary.selected.tipVisibleGiftAid;
    };

    var toggleTipNetCost = function() {
      $scope.financialAidSummary.selected.tipVisibleNetCost = !$scope
        .financialAidSummary.selected.tipVisibleNetCost;
    };

    var toggleTipThirdParty = function() {
      $scope.financialAidSummary.selected.tipVisibleThirdParty = !$scope
        .financialAidSummary.selected.tipVisibleThirdParty;
    };

    var updateUrl = function() {
      if (!$scope.financialAidSummary.selected.finaidYear) {
        return;
      }
      if ($scope.isMainFinaid) {
        $location.path(
          'finances/finaid/' +
            $scope.financialAidSummary.selected.finaidYear.id,
          false
        );
      }
    };

    var updateSummary = function() {
      angular.extend(
        $scope.financialAidSummary.selected,
        _.get(
          $scope.financialAidSummary.aid,
          finaidService.options.finaidYear.id
        )
      );
    };

    var checkForDecimalValues = function(incoming) {
      let b = false;
      const values = Object.values(incoming);

      values.forEach(function(amount) {
        if (typeof amount === 'number') {
          if (!Number.isInteger(amount) && !b) {
            b = true;
          }
        }
      });
      $scope.financialAidSummary.showDecimals = b;
    };

    var selectFinaidYear = function() {
      $scope.financialAidSummary.selected.finaidYear =
        finaidService.options.finaidYear;
    };

    var setDefaultSelections = function(feed) {
      var aidYears = _.values(_.get(feed, 'financialAidSummary.aidYears'));
      if (!aidYears.length) {
        return;
      }
      finaidService.setDefaultFinaidYear(aidYears, $routeParams.finaidYearId);
      selectFinaidYear(feed);
      updateSummary();
      checkForDecimalValues($scope.financialAidSummary.selected);
    };

    var parseFinancialAidSummary = function(response) {
      var feed = _.get(response, 'data');
      angular.extend(
        $scope.financialAidSummary,
        _.get(feed, 'financialAidSummary')
      );

      checkLoading();
      $scope.financialAidSummary.isMainPage = $location.path() === '/finances';
      $scope.financialAidSummary.errored = _.get(feed, 'errored');
      setDefaultSelections(feed);
    };

    var loadFinancialAidSummary = function() {
      $ngRedux.subscribe(checkLoading);
      $ngRedux.dispatch(fetchChecklistItems());
      $ngRedux.dispatch(fetchAgreements());

      finaidFactory
        .getFinancialAidSummary()
        .then(parseFinancialAidSummary, function errorCallback() {
          $scope.financialAidSummary.errored = true;
        })
        .finally(function() {
          $scope.financialAidSummary.factoriesLoading = false;
          $scope.financialAidSummary.formatCurrency = formatCurrency;
          $scope.financialAidSummary.toggleTipGiftAid = toggleTipGiftAid;
          $scope.financialAidSummary.toggleTipNetCost = toggleTipNetCost;
          $scope.financialAidSummary.toggleTipThirdParty = toggleTipThirdParty;
        });
    };

    loadFinancialAidSummary();
  });
