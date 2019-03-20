import PropTypes from 'prop-types';
import React from 'react';
import _ from 'lodash';
import { react2angular } from 'react2angular';
import { updateStateProperty } from '../../../helpers/state';

import Icon from '../../Icon/Icon';
import { ICON_TIMES_CIRCLE } from '../../Icon/IconTypes';
import PnpCalculator from './PnpCalculator';

const propTypes = {
  $scope: PropTypes.object.isRequired,
  degreeProgressFactory: PropTypes.object.isRequired
};

class PnpCalculatorContainer extends React.Component {
  constructor(props) {
    super(props);
    const errorMessage = (
      <React.Fragment>
        <Icon name={ICON_TIMES_CIRCLE} />This estimator is unavailable. Please try again later.
      </React.Fragment>
    );
    this.state = {
      calculator: {},
      calculatedProjectedValues: {
        maxRatioBase: null,
        countedGpaUnits: null,
        countedNoGpaUnits: null,
        excessNoGpaUnits: null,
        percentage: null
      },
      calculatedTotals: {
        totalGpaUnits: null,
        totalNoGpaUnits: null,
        totalSum: null,
        totalTransferUnits: null
      },
      estimateButtonDisabled: true,
      inputStatus: {
        errored: false,
        estimateButtonDisabled: true,
        hasTransferUnitInput: false
      },
      inputValues: {
        totalTransferUnits: null,
        totalGpaUnits: null,
        totalNoGpaUnits: null
      },
      ratioCalculation: {
        errored: false,
        isLoading: true,
        message: null,
        show: false
      },
      widgetConfig: {
        errored: false,
        errorMessage: errorMessage,
        isLoading: true,
        padding: false,
        title: '1/3 Passed (P) Grade Limit',
        visible: false
      }
    };
    this.calculateProjectedValues = this.calculateProjectedValues.bind(this);
    this.calculateTotals = this.calculateTotals.bind(this);
    this.handleAngularBroadcast = this.handleAngularBroadcast.bind(this);
    this.handleEstimateButtonPressed = this.handleEstimateButtonPressed.bind(this);
    this.handleInputChange = this.handleInputChange.bind(this);
    this.handleRatioCalculationButtonPressed = this.handleRatioCalculationButtonPressed.bind(this);
    this.isValidInput = this.isValidInput.bind(this);
    this.parseCalculatorValues = this.parseCalculatorValues.bind(this);
    this.updateStateFromInput = this.updateStateFromInput.bind(this);
    this.updateVisibility = this.updateVisibility.bind(this);
  }
  componentDidMount() {
    this.props.$scope.$on('calcentral.custom.api.showPnpCalculator', this.handleAngularBroadcast);
  }
  calculateProjectedValues() {
    const projectedValues = {...this.state.calculatedProjectedValues};
    const totals = {...this.state.calculatedTotals};
    projectedValues.maxRatioBase = 120 - totals.totalTransferUnits;
    projectedValues.countedGpaUnits = Math.min(totals.totalGpaUnits, projectedValues.maxRatioBase);
    projectedValues.countedNoGpaUnits = Math.min(totals.totalNoGpaUnits, (projectedValues.maxRatioBase - projectedValues.countedGpaUnits));
    projectedValues.excessNoGpaUnits = totals.totalNoGpaUnits - projectedValues.countedNoGpaUnits;
    
    const percentage = Math.round((projectedValues.countedNoGpaUnits / (projectedValues.countedGpaUnits + projectedValues.countedNoGpaUnits)) * 100);
    projectedValues.percentage = Math.max(0, percentage);
    
    updateStateProperty(this, {
      calculatedProjectedValues: {$set: projectedValues},
      inputStatus: {estimateButtonDisabled: {$set: true}}
    });
  }
  calculateTotals() {
    const calculatedTotals = {...this.state.calculatedTotals};
    const calculatorValues = {...this.state.calculator};
    const inputValues = {...this.state.inputValues};
    let totalSum = 0;
    for (const name of Object.keys(inputValues)) {
      calculatedTotals[name] = calculatorValues[name] + (inputValues[name] || 0);
      totalSum += calculatedTotals[name];
    }
    calculatedTotals.totalSum = totalSum;
    updateStateProperty(this, {calculatedTotals: {$set: calculatedTotals}});
  }
  handleAngularBroadcast() {
    this.updateVisibility()
    .then(() => {
      return this.props.degreeProgressFactory.getPnpCalculatorValues();
    }).then(response => {
      return this.parseCalculatorValues(response);
    }).then(calculatorValues => {
      const totalUnits = calculatorValues.totalGpaUnits + calculatorValues.totalNoGpaUnits + calculatorValues.totalTransferUnits;
      const excessNoGpaUnits = calculatorValues.totalNoGpaUnits - calculatorValues.noGpaRatioUnits;
      calculatorValues.hasExcessNoGpaUnits = totalUnits > 120 && excessNoGpaUnits > 0;
      return updateStateProperty(this, {calculator: {$set: calculatorValues}});
    }).then(() => {
      return this.calculateTotals();
    }).catch(() => {
      return updateStateProperty(this, {widgetConfig: {errored: {$set: true}}});
    }).finally(() => {
      return updateStateProperty(this, {widgetConfig: {isLoading: {$set: false}}});
    });
  }
  handleEstimateButtonPressed(event) {
    event.preventDefault();
    this.calculateProjectedValues();
  }
  handleInputChange(event) {
    this.updateStateFromInput(event).then(this.calculateTotals);
  }
  handleRatioCalculationButtonPressed(event) {
    event.preventDefault();
    updateStateProperty(this, {ratioCalculation: {show: {$set: true}}});

    this.props.degreeProgressFactory.getPnpCalculatorMessage()
    .then(response => {
      const message = _.get(response, 'data.descrlong');
      return updateStateProperty(this, {ratioCalculation: {message: {$set: message}}});
    })
    .catch(() => {
      return updateStateProperty(this, {ratioCalculation: {errored: {$set: true}}});
    })
    .finally(() => {
      return updateStateProperty(this, {ratioCalculation: {isLoading: {$set: false}}});
    });
  }
  isValidInput(input) {
    const inputValues = Object.values(input);
    let isValid = false;
    let hasNegativeTransferUnit = false;
    let hasTransferUnitInput = false;
    if (inputValues.some(value => Number.isFinite(value))) {
      if (Number.isFinite(input.totalTransferUnits) && parseFloat(input.totalTransferUnits) < 0) {
        hasNegativeTransferUnit = true;
      } else {
        hasTransferUnitInput = Number.isFinite(input.totalTransferUnits);
        isValid = true;
      }
    }
    return {
      hasNegativeTransferUnit: hasNegativeTransferUnit,
      hasTransferUnitInput: hasTransferUnitInput,
      isValid: isValid
    };
  }
  updateStateFromInput(event) {
    return new Promise(resolve => {
      const {value, name} = event.target;
      const inputValues = {...this.state.inputValues};
      inputValues[name] = parseFloat(value);
      const {hasNegativeTransferUnit, hasTransferUnitInput, isValid} = this.isValidInput(inputValues);
      updateStateProperty(this, {
        inputStatus: {
          errored: {$set: hasNegativeTransferUnit},
          estimateButtonDisabled: {$set: !isValid},
          hasTransferUnitInput: {$set: hasTransferUnitInput}
        },
        inputValues: {$set: inputValues}
      });
      resolve();
    });
  }
  updateVisibility() {
    return new Promise(resolve => {
      updateStateProperty(this, {widgetConfig: {visible: {$set: true}}});
      resolve();
    });
  }
  parseCalculatorValues(response) {
    return new Promise(resolve => {
      const values = _.get(response, 'data');
      delete values.isLoading;
      const parsed = _.mapValues(values, value => {
        return parseFloat(value);
      });
      resolve(parsed);
    });
  }
  render() {
    return (
      <PnpCalculator
        calculator={{...this.state.calculator}}
        calculatedProjectedValues={{...this.state.calculatedProjectedValues}}
        calculatedTotals={{...this.state.calculatedTotals}}
        handleEstimateButtonPressed={this.handleEstimateButtonPressed}
        handleInputChange={this.handleInputChange}
        handleRatioCalculationButtonPressed={this.handleRatioCalculationButtonPressed}
        inputStatus={{...this.state.inputStatus}}
        ratioCalculation={{...this.state.ratioCalculation}}
        widgetConfig={{...this.state.widgetConfig}} 
      />
    );
  }
}
PnpCalculatorContainer.propTypes = propTypes;

angular.module('calcentral.react').component('pnpCalculatorContainer', react2angular(PnpCalculatorContainer, [], ['$scope', 'degreeProgressFactory']));
