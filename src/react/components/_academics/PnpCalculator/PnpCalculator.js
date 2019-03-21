import PropTypes from 'prop-types';
import React from 'react';

import Widget from '../../Widget/Widget';
import WidgetSectionHeader from '../../Widget/WidgetSectionHeader';
import CurrentGradePercentage from './CurrentGradePercentage';
import PassedGradeLimitEstimator from './PassedGradeLimitEstimator';
import RatioCalculation from './RatioCalculation';

import '../../../stylesheets/widgets.scss';

const propTypes = {
  calculator: PropTypes.object.isRequired,
  calculatedProjectedValues: PropTypes.object.isRequired,
  calculatedTotals: PropTypes.object.isRequired,
  handleEstimateButtonPressed: PropTypes.func.isRequired,
  handleInputChange: PropTypes.func.isRequired,
  handleRatioCalculationButtonPressed: PropTypes.func.isRequired,
  inputStatus: PropTypes.object.isRequired,
  ratioCalculation: PropTypes.object.isRequired,
  widgetConfig: PropTypes.object.isRequired
};

const PnpCalculator = (props) => {
  return (
    <Widget config={{...props.widgetConfig}}>
      <div className="cc-react-widget--padding">
        <CurrentGradePercentage pnpPercentage={props.calculator.pnpPercentage} hasExcessNoGpaUnits={props.calculator.hasExcessNoGpaUnits} />
      </div>
      <WidgetSectionHeader title="Percentage Estimator" />
      <div className="cc-react-widget--padding">
        <PassedGradeLimitEstimator
          calculatedProjectedValues={{...props.calculatedProjectedValues}}
          calculatedTotals={{...props.calculatedTotals}}
          calculator={{...props.calculator}}
          handleEstimateButtonPressed={props.handleEstimateButtonPressed}
          handleInputChange={props.handleInputChange}
          inputStatus={props.inputStatus}
        />
        <RatioCalculation
          calculatedProjectedValues={{...props.calculatedProjectedValues}}
          calculatedTotals={{...props.calculatedTotals}}
          handleRatioCalculationButtonPressed={props.handleRatioCalculationButtonPressed}
          ratioCalculation={props.ratioCalculation}
        />
      </div>
    </Widget>
  );
};
PnpCalculator.propTypes = propTypes;

export default PnpCalculator;
