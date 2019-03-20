import React from 'react';
import PropTypes from 'prop-types';

import Icon from '../../Icon/Icon';
import { ICON_TIMES_CIRCLE } from '../../Icon/IconTypes';
import Spinner from '../../Spinner';

import '../../../stylesheets/buttons.scss';
import '../../../stylesheets/widgets.scss';

const propTypes = {
  calculatedProjectedValues: PropTypes.object.isRequired,
  calculatedTotals: PropTypes.object.isRequired,
  handleRatioCalculationButtonPressed: PropTypes.func.isRequired,
  ratioCalculation: PropTypes.object.isRequired
};

const renderRatioCalculationMessage = (errored, isLoading, message) => {
  if (errored) {
    return (
      <React.Fragment>
        <Icon name={ICON_TIMES_CIRCLE} />Unable to retrieve message or text.
      </React.Fragment>
    );
  } else if (isLoading) {
    return (
      <Spinner />
    );
  } else {
    return (
      <div dangerouslySetInnerHTML={{__html: message}}></div>
    );
  }
};

const renderRatioCalculationSection = (props) => {
  if (props.ratioCalculation.show) {
    const {percentage, countedGpaUnits, countedNoGpaUnits, excessNoGpaUnits} = props.calculatedProjectedValues;
    const cepLabel = parseFloat(excessNoGpaUnits) > 0 ? '120 units - Transfer Credit' : 'Berkeley units';
    return (
      <React.Fragment>
        <strong>Percentage Calculation</strong>
        <div className="cc-react-pnp-calculat-ratio-calc">
          <p>{`${(percentage / 100).toFixed(2)} = ${countedNoGpaUnits.toFixed(2)} units / ${(countedGpaUnits + countedNoGpaUnits).toFixed(2)} units`}</p>
          <p>&emsp;{`${countedNoGpaUnits.toFixed(2)} units: Berkeley P/NP (${excessNoGpaUnits.toFixed(2)} excess units)`}</p>
          <p>&emsp;{`${(countedGpaUnits + countedNoGpaUnits).toFixed(2)} units: ${cepLabel}`}</p>
        </div>
        {renderRatioCalculationMessage(props.ratioCalculation.errored, props.ratioCalculation.isLoading, props.ratioCalculation.message)}
      </React.Fragment>
    );
  } else {
    return (
      <div className="cc-react-text--align-right">
        <button className="cc-react-button--link" onClick={props.handleRatioCalculationButtonPressed}>How is this percentage calculated?</button>
      </div>
    );
  }
};

const RatioCalculation = (props) => {
  return Number.isFinite(props.calculatedProjectedValues.percentage) ? renderRatioCalculationSection(props) : null;
};
RatioCalculation.propTypes = propTypes;

export default RatioCalculation;
