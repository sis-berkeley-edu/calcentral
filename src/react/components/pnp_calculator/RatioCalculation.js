import React from 'react';
import PropTypes from 'prop-types';

import RedTimesCircle from '../base/icon/RedTimesCircle';
import Spinner from '../base/Spinner';

import '../../stylesheets/buttons.scss';
import '../../stylesheets/widgets.scss';

const renderRatioCalculationMessage = (errored, isLoading, message) => {
  if (errored) {
    return (
      <React.Fragment>
        <RedTimesCircle />Unable to retrieve message or text.
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
    const {ratio, countedGpaUnits, countedNoGpaUnits, excessNoGpaUnits} = props.calculatedProjectedValues;
    const cepLabel = parseFloat(excessNoGpaUnits) > 0 ? '120 units - Transfer and Test units' : 'Berkeley units';
    return (
      <React.Fragment>
        <div className="cc-react-pnp-calculat-ratio-calc">
          <p>{`${ratio.toFixed(2)} = ${countedNoGpaUnits.toFixed(2)} units / ${(countedGpaUnits + countedNoGpaUnits).toFixed(2)} units`}</p>
          <p>&emsp;{`${countedNoGpaUnits.toFixed(2)} units: Berkeley P/NP (${excessNoGpaUnits} excess units)`}</p>
          <p>&emsp;{`${(countedGpaUnits + countedNoGpaUnits).toFixed(2)} units: ${cepLabel}`}</p>
        </div>
        {renderRatioCalculationMessage(props.ratioCalculation.errored, props.ratioCalculation.isLoading, props.ratioCalculation.message)}
      </React.Fragment>
    );
  } else {
    return (
      <div className="cc-react-text--align-right">
        <button className="cc-react-button--link" onClick={props.handleRatioCalculationButtonPressed}>How is this calculated?</button>
      </div>
    );
  }
};

const RatioCalculation = (props) => {
  return Number.isFinite(props.calculatedProjectedValues.ratio) ? renderRatioCalculationSection(props) : null;
};
RatioCalculation.propTypes = {
  calculatedProjectedValues: PropTypes.object.isRequired,
  calculatedTotals: PropTypes.object.isRequired,
  handleRatioCalculationButtonPressed: PropTypes.func.isRequired,
  ratioCalculation: PropTypes.object.isRequired
};

export default RatioCalculation;
