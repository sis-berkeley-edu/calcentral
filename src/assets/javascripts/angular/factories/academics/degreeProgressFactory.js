'use strict';

angular.module('calcentral.factories').factory('degreeProgressFactory', function(apiService) {
  var undergraduateRequirementsUrl = '/api/academics/degree_progress/ugrd';
  // var undergraduateRequirementsUrl = '/dummy/json/degree_progress_ugrd.json';
  var graduateMilestonesUrl = '/api/academics/degree_progress/grad';
  // var graduateMilestonesUrl = '/dummy/json/degree_progress_grad.json';
  var pnpCalculatorValuesUrl = '/api/academics/pnp_calculator/calculator_values';
  // var pnpCalculatorValues = '/dummy/json/pnp_calculator_values.json';
  var pnpCalculatorMessageUrl = '/api/academics/pnp_calculator/ratio_message';
  // var pnpCalculatorMessageUrl = '/dummy/json/pnp_ratio_message.json';

  var getUndergraduateRequirements = function(options) {
    return apiService.http.request(options, undergraduateRequirementsUrl);
  };

  var getGraduateMilestones = function(options) {
    return apiService.http.request(options, graduateMilestonesUrl);
  };

  var getPnpCalculatorValues = function(options) {
    return apiService.http.request(options, pnpCalculatorValuesUrl);
  };

  var getPnpCalculatorMessage = function(options) {
    return apiService.http.request(options, pnpCalculatorMessageUrl);
  };

  return {
    getGraduateMilestones: getGraduateMilestones,
    getUndergraduateRequirements: getUndergraduateRequirements,
    getPnpCalculatorMessage: getPnpCalculatorMessage,
    getPnpCalculatorValues: getPnpCalculatorValues
  };
});
