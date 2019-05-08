import {
  fetchProfileStart,
  fetchProfileSuccess,
  fetchProfileFailure
} from 'Redux/actions/profileActions';

angular.module('calcentral.factories').factory('profileFactory', function(apiService, $http, $ngRedux) {
  var urlAddressFields = '/api/campus_solutions/address_label';
  var urlConfidentialStudentMessage = '/api/campus_solutions/confidential_student_message';
  var urlCountries = '/api/campus_solutions/country';
  var urlDeleteLanguage = '/api/campus_solutions/language';
  var urlEmergencyContacts = '/api/campus_solutions/emergency_contacts';
  // var urlLanguageCodes = '/dummy/json/language_codes.json';
  var urlLanguageCodes = '/api/campus_solutions/language_code';
  var urlCurrencies = '/api/campus_solutions/currency_code';
  var urlStates = '/api/campus_solutions/state';
  var urlTypes = '/api/campus_solutions/translate';
  var urlTypesPayFrequency = urlTypes + '?field_name=PAY_FREQ_ABBRV';
  var urlWorkExperience = '/api/edos/work_experience';

  var urlPostLanguage = '/api/campus_solutions/language';
  var urlPostWorkExperience = '/api/campus_solutions/work_experience';
  var urlProfileEditLink = '/api/my/profile/link';

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
    const url = '/api/my/profile';
    // const url = '/dummy/json/student_with_languages.json';

    const { myProfile } = $ngRedux.getState();

    if (myProfile.loaded || myProfile.isLoading) {
      return apiService.http.request(options, url);
    } else {
      $ngRedux.dispatch(fetchProfileStart());

      const promise = apiService.http.request(options, url);

      promise.then(({ data }) => {
        $ngRedux.dispatch(fetchProfileSuccess(data.feed.student));
      }).catch(error => {
        $ngRedux.dispatch(fetchProfileFailure({ status: error.status, statusText: error.statusText }));
      });

      return promise;
    }
  };
  var getProfileEditLink = function(options) {
    return apiService.http.request(options, urlProfileEditLink);
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

  // Post
  var postLanguage = function(options) {
    return $http.post(urlPostLanguage, options);
  };
  var postWorkExperience = function(options) {
    return $http.post(urlPostWorkExperience, options);
  };

  return {
    deleteLanguage: deleteLanguage,
    deleteWorkExperience: deleteWorkExperience,
    getConfidentialStudentMessage: getConfidentialStudentMessage,
    getCountries: getCountries,
    getCurrencies: getCurrencies,
    getAddressFields: getAddressFields,
    getEmergencyContacts: getEmergencyContacts,
    getLanguageCodes: getLanguageCodes,
    getPerson: getPerson,
    getProfileEditLink: getProfileEditLink,
    getStates: getStates,
    getTypesPayFrequency: getTypesPayFrequency,
    getWorkExperience: getWorkExperience,
    postLanguage: postLanguage,
    postWorkExperience: postWorkExperience
  };
});
