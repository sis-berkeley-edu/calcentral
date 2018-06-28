'use strict';

var angular = require('angular');

/**
 * Profile Factory
 */
angular.module('calcentral.factories').factory('profileFactory', function(apiService, $http) {
  var urlAddressFields = '/api/campus_solutions/address_label';
  var urlConfidentialStudentMessage = '/api/campus_solutions/confidential_student_message';
  var urlCountries = '/api/campus_solutions/country';
  var urlDeleteLanguage = '/api/campus_solutions/language';
  var urlEmergencyContacts = '/api/campus_solutions/emergency_contacts';
  // var urlLanguageCodes = '/dummy/json/language_codes.json';
  var urlLanguageCodes = '/api/campus_solutions/language_code';
  // var urlPerson = '/dummy/json/student_with_languages.json';
  var urlCurrencies = '/api/campus_solutions/currency_code';
  var urlPerson = '/api/my/profile';
  var urlStates = '/api/campus_solutions/state';
  var urlTypes = '/api/campus_solutions/translate';
  var urlTypesPayFrequency = urlTypes + '?field_name=PAY_FREQ_ABBRV';
  var urlTypesRelationship = urlTypes + '?field_name=RELATIONSHIP';
  var urlWorkExperience = '/api/edos/work_experience';

  var urlPostEmergencyContact = '/api/campus_solutions/emergency_contact';
  var urlPostEmergencyPhone = '/api/campus_solutions/emergency_phone';
  var urlPostLanguage = '/api/campus_solutions/language';
  var urlPostName = '/api/campus_solutions/person_name';
  var urlPostWorkExperience = '/api/campus_solutions/work_experience';

  var deleteEmergencyContact = function(options) {
    return $http.delete(urlPostEmergencyContact + '/' + options.contactName, options);
  };
  var deleteEmergencyPhone = function(options) {
    return $http.delete(urlPostEmergencyPhone + '/' + options.contactName + '/' + options.phoneType, options);
  };
  var deleteLanguage = function(options) {
    return $http.delete(urlDeleteLanguage + '/' + options.languageCode, options);
  };
  var deleteWorkExperience = function(options) {
    return $http.delete(urlPostWorkExperience + '/' + options.sequenceNbr, options);
  };

  // Get - General
  var getAddressFields = function(options) {
    return apiService.http.request(options, urlAddressFields + '?country=' + options.country);
  };
  var getConfidentialStudentMessage = function(options) {
    return apiService.http.request(options, urlConfidentialStudentMessage);
  };
  var getCountries = function(options) {
    return apiService.http.request(options, urlCountries);
  };
  var getEmergencyContacts = function(options) {
    return apiService.http.request(options, urlEmergencyContacts);
  };
  var getLanguageCodes = function(options) {
    return apiService.http.request(options, urlLanguageCodes);
  };
  var getCurrencies = function(options) {
    return apiService.http.request(options, urlCurrencies);
  };
  var getPerson = function(options) {
    return apiService.http.request(options, urlPerson);
  };
  var getStates = function(options) {
    return apiService.http.request(options, urlStates + '?country=' + options.country);
  };
  var getWorkExperience = function(options) {
    return apiService.http.request(options, urlWorkExperience);
  };
  var getTypesPayFrequency = function(options) {
    return apiService.http.request(options, urlTypesPayFrequency);
  };
  var getTypesRelationship = function(options) {
    return apiService.http.request(options, urlTypesRelationship);
  };

  // Post
  var postEmergencyContact = function(options) {
    return $http.post(urlPostEmergencyContact, options);
  };
  var postEmergencyPhone = function(options) {
    return $http.post(urlPostEmergencyPhone, options);
  };
  var postLanguage = function(options) {
    return $http.post(urlPostLanguage, options);
  };
  var postName = function(options) {
    return $http.post(urlPostName, options);
  };
  var postWorkExperience = function(options) {
    return $http.post(urlPostWorkExperience, options);
  };

  return {
    deleteEmergencyContact: deleteEmergencyContact,
    deleteEmergencyPhone: deleteEmergencyPhone,
    deleteLanguage: deleteLanguage,
    deleteWorkExperience: deleteWorkExperience,
    getConfidentialStudentMessage: getConfidentialStudentMessage,
    getCountries: getCountries,
    getCurrencies: getCurrencies,
    getAddressFields: getAddressFields,
    getEmergencyContacts: getEmergencyContacts,
    getLanguageCodes: getLanguageCodes,
    getPerson: getPerson,
    getStates: getStates,
    getTypesPayFrequency: getTypesPayFrequency,
    getTypesRelationship: getTypesRelationship,
    getWorkExperience: getWorkExperience,
    postEmergencyContact: postEmergencyContact,
    postEmergencyPhone: postEmergencyPhone,
    postLanguage: postLanguage,
    postName: postName,
    postWorkExperience: postWorkExperience
  };
});
