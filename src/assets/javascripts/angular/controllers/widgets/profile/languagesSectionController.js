'use strict';

var _ = require('lodash');
var angular = require('angular');

/**
 * Language section controller
 */
angular.module('calcentral.controllers').controller('LanguagesSectionController', function(apiService, profileFactory, $scope) {
  angular.extend($scope, {
    currentObject: {},
    emptyObject: {},
    errorMessage: '',
    isLoading: true,
    isSaving: false,
    items: {
      content: [],
      editorEnabled: false
    },
    languageCodes: {
      content: []
    },
    languageLevels: [
      {
        label: 'Yes',
        postValue: 'Y',
        value: true
      },
      {
        label: 'No',
        postValue: 'N',
        value: false
      }
    ],
    proficiencyLevels: [
      {
        label: 'High',
        value: '3'
      },
      {
        label: 'Moderate',
        value: '2'
      },
      {
        label: 'Low',
        value: '1'
      }
    ]
  });

  var levelMapping = {
    native: 'native',
    teach: 'teacher',
    translate: 'translator'
  };

  var proficiencyKeys = ['speakingProficiency', 'readingProficiency', 'writingProficiency'];

  /**
   * Function maps a language level (native, teach, translate) boolean value to
   * either 'Y' or 'N', the only values accepted by the POST endpoint.
   * @param {Boolean} hasLevel Value indicating that student has this language level.
   * @return {String} The value to be sent to the POST endpoint.
   */
  var normalizeLanguageLevel = function(hasLevel) {
    var index = hasLevel ? 0 : 1;

    return $scope.languageLevels[index].postValue;
  };

  /**
   * Function guards against a proficiency object or its code field being null
   * or undefined. It returns a code if present; otherwise a blank string as a
   * safe default.
   * @param {Object} proficiency Proficiency object containing code and description fields.
   * @return {String} Proficiency's code value; otherwise, a blank string.
   */
  var normalizeProficiencyCode = function(proficiency) {
    var hasValidProficiencyCode = false;

    if (_.get(proficiency, 'code')) {
      hasValidProficiencyCode = _.some($scope.proficiencyLevels, function(node) {
        return node.value === proficiency.code;
      });
    }

    return hasValidProficiencyCode ? proficiency.code : '';
  };

  /**
   * Function insures each student language contains a `levels` with key-values
   * from `levelMapping`. It also checks any `proficiency` in the language and
   * normalizes its `code` field.
   * @param {Array} languages The student's languages field.
   * @return {Array} The populated and normalized languages.
   */
  var parseLanguages = function(languages) {
    languages = _.map(languages, function(language) {
      if (!language.levels) {
        language.levels = _.filter(levelMapping, function(value, level) {
          return language[level] && value;
        });
      }

      // Guard against unsafe or unsupported proficiency code. This mutates the
      // the language.proficiency object in place, only if one exists.
      _.each(proficiencyKeys, function(key) {
        var proficiency = language[key];
        if (_.get(proficiency, 'code')) {
          proficiency.code = normalizeProficiencyCode(proficiency);
        }
      });

      return language;
    });

    return languages;
  };

  var parsePerson = function(response) {
    var languages = parseLanguages(_.get(response, 'data.feed.student.languages'));

    languages = _.sortBy(languages, function(language) {
      return language.name;
    });

    angular.extend($scope, {
      items: {
        content: languages
      }
    });
  };

  /**
   * Function customizes the array of language codes, sorting it by `descr` or
   * language name (such as "Yiddish") in ascending order, and moving the entry
   * with `accomplishment` field set to `LOT` (representing `Other`) to the end
   * of the array. The sorted array is meant for display in a select element.
   * @param {Array} codes List of language code objects with `descr` and `accomplishment`
   * properties.
   * @return {Array} List of languages codes sorted by `descr` property.
   */
  var sortLanguageCodes = function(codes) {
    var sortedCodes = codes.sort(function(a, b) {
      // Guarantee ascending sort order by `descr` or label, while pushing the
      // 'LOT' ('Other') entry (if found) to the next position (return 1), so
      // that it is in last position after all comparisons complete.
      return a.accomplishment === 'LOT' ? 1 : a.descr > b.descr;
    });

    return sortedCodes;
  };

  var parseLanguageCodes = function(response) {
    var accomplishments = _.get(response, 'data.feed.accomplishments');
    var languageCodes = sortLanguageCodes(accomplishments);

    angular.extend($scope, {
      languageCodes: {
        content: languageCodes
      }
    });
  };

  var fetchLanguageCodes = function() {
    return profileFactory.getLanguageCodes();
  };

  var getPerson = function() {
    return profileFactory.getPerson({
      refreshCache: true
    });
  };

  var loadInformation = function() {
    $scope.isLoading = true;

    fetchLanguageCodes()
    .then(parseLanguageCodes)
    .then(getPerson)
    .then(parsePerson)
    .then(function() {
      $scope.isLoading = false;
    });
  };

  var actionCompleted = function(response) {
    apiService.profile.actionCompleted($scope, response, loadInformation);
  };

  var deleteCompleted = function(response) {
    $scope.isDeleting = false;
    actionCompleted(response);
  };

  $scope.closeEditor = function() {
    apiService.profile.closeEditor($scope);
  };

  $scope.cancelEdit = function() {
    $scope.isSaving = false;
    $scope.closeEditor();
  };

  $scope.deleteItem = function(item) {
    return apiService.profile.delete($scope, profileFactory.deleteLanguage, {
      languageCode: item.code
    }).then(deleteCompleted);
  };

  $scope.showAdd = function() {
    apiService.profile.showAdd($scope, $scope.emptyObject);
  };

  $scope.showEdit = function(item) {
    apiService.profile.showEdit($scope, item);
  };

  var saveCompleted = function(response) {
    $scope.isSaving = false;
    actionCompleted(response);
  };

  $scope.saveItem = function(item) {
    apiService.profile.save($scope, profileFactory.postLanguage, {
      languageCode: item.code,
      isNative: normalizeLanguageLevel(item.native),
      isTranslateToNative: normalizeLanguageLevel(item.translate),
      isTeachLanguage: normalizeLanguageLevel(item.teach),
      speakProf: normalizeProficiencyCode(item.speakingProficiency),
      readProf: normalizeProficiencyCode(item.readingProficiency),
      teachLang: normalizeProficiencyCode(item.writingProficiency)
    }).then(saveCompleted);
  };

  loadInformation();
});
