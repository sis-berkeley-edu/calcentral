'use strict';

var angular = require('angular');
var _ = require('lodash');

/**
 * Factory for the enrollment information.
 * The second set of URLs relate to Advisors doing student lookup, NOT a view-as mode.
 */
angular.module('calcentral.factories').factory('enrollmentFactory', function(apiService, $route, $routeParams) {
  var urlEnrollmentInstructions = '/api/my/class_enrollments';
  // var urlEnrollmentInstructions = '/dummy/json/enrollment_instructions.json';
  var urlAdvisingEnrollmentInstructions = '/api/advising/class_enrollments/';
  // var urlAdvisingEnrollmentInstructions = '/dummy/json/enrollment_instructions.json';

  /**
   * Extracts update link and other information from academic planner object
   * @param {object} instructionType enrollment instruction object
   * @param {object} termId          term code for enrollment instruction object
   * @param {object} academicPlanner raw academic planner object
   */
  var setAcademicPlanner = function(instructionType, termId, academicPlanner) {
    var planner = _.get(academicPlanner, termId);
    instructionType.updatePlannerLink = _.get(planner, 'updateAcademicPlanner');
    var academicPlanners = _.get(planner, 'academicplanner');
    instructionType.academicPlanner = _.find(academicPlanners, {
      term: termId
    });
    return instructionType;
  };

  /**
   * Processes raw data feed for presentation
   * @param  {object} data enrollment instructions feed
   * @return {object} prepared enrollment instructions object
   */
  var parseEnrollmentInstructionDecks = function(data) {
    var enrollmentInstructionDecks = [];
    var instructionTypeDecks = _.get(data, 'data.enrollmentTermInstructionTypeDecks');
    var academicPlanner = _.get(data, 'data.enrollmentTermAcademicPlanner');
    var instructions = _.get(data, 'data.enrollmentTermInstructions');
    var hasHolds = _.get(data, 'data.hasHolds');
    var links = _.get(data, 'data.links');
    if (!instructionTypeDecks || !academicPlanner || !instructions) {
      return;
    }

    /* remove term id from each instruction to avoid merger over cards in deck */
    instructions = _.mapValues(instructions, function(instruction) {
      delete instruction.term;
      return instruction;
    });

    /* Merge the appropriate term-based instructions with each instruction type objects */
    if (_.get(instructionTypeDecks, 'length') > 0) {
      enrollmentInstructionDecks = _.mapValues(instructionTypeDecks, function(deck) {
        deck.terms = getDeckTerms(deck.cards);
        deck.selectedCardIndex = defaultSelectedCardIndex(deck.terms);
        deck.cards = _.mapValues(deck.cards, function(card) {
          var typeTermId = _.get(card, 'term.termId');
          angular.extend(card, instructions[typeTermId]);
          card.hasHolds = hasHolds;
          card.csLinks = links;
          card = setAcademicPlanner(card, typeTermId, academicPlanner);
          return card;
        });
        deck.cards = _.sortBy(deck.cards, ['term']);
        return deck;
      });
    }
    return {
      enrollmentInstructionDecks: enrollmentInstructionDecks
    };
  };

  var getDeckTerms = function(cards) {
    return _.map(cards, function(card, index) {
      return {
        index: index,
        termName: _.get(card, 'term.termName'),
        isSummer: _.get(card, 'term.termIsSummer')
      };
    });
  };

  /*
   * Returns the index integer for the card that should be selected by default.
   * Should be the latest term that is not a Summer term
   */
  var defaultSelectedCardIndex = function(deckTerms) {
    var relevantCards = _.reject(deckTerms, function(term) {
      return term.isSummer;
    });
    var selectedCard = _.last(relevantCards);
    return selectedCard ? selectedCard.index : 0;
  };

  var getEnrollmentInstructionDecks = function(options) {
    var url = $route.current.isAdvisingStudentLookup ? urlAdvisingEnrollmentInstructions + $routeParams.uid : urlEnrollmentInstructions;
    return apiService.http.request(options, url).then(function(response) {
      return parseEnrollmentInstructionDecks(response);
    });
  };

  return {
    getEnrollmentInstructionDecks: getEnrollmentInstructionDecks
  };
});
