import PropTypes from 'prop-types';
import React from 'react';

import GreenCheckmark from '../base/icon/GreenCheckmark';
import RedExclamationCircle from '../base/icon/RedExclamationCircle';

import '../../stylesheets/box_model.scss';
import '../../stylesheets/buttons.scss';
import '../../stylesheets/forms.scss';
import '../../stylesheets/pnp_calculator.scss';
import '../../stylesheets/tables.scss';
import '../../stylesheets/text.scss';
import '../../stylesheets/widgets.scss';

const renderInputErrorMessage = (errored) => {
  if (errored) {
    return (
      <div>
        <p className="cc-react-text--align-right cc-react-text--red">
          <RedExclamationCircle /> Please use valid numeric values
        </p>
      </div>
    );
  } else {
    return null;
  }
};

const renderTransferUnitNote = (hasTransferUnitInput) => {
  if (hasTransferUnitInput) {
    return (
      <p className="cc-react-text--small cc-react--no-margin">
        Note: Only exams completed as a high school student are eligible for test credit. Lower division transfer credit may not exceed 70 semester units.
      </p>
    );
  } else {
    return null;
  }
};

const renderProjectedRatio = (projectedRatio) => {
  if (Number.isFinite(projectedRatio)) {
    const icon = projectedRatio.toPrecision(2) > 0.33 ? <RedExclamationCircle /> : <GreenCheckmark />;
    return (
      <div className="cc-react-widget__highlighted-section cc-react-text--align-right">
        <p className="cc-react--no-margin">Projected Ratio</p>
        <h2 className='cc-react--no-margin cc-react-text--bold'>
          {icon} {projectedRatio.toFixed(2)}
        </h2>
      </div>
    );
  } else {
    return null;
  }
};

const PassedGradeLimitEstimator = (props) => {
  return (
    <div>
      <p className="cc-react--no-margin">
        Add units you plan to earn by your Expected Graduation:
      </p>
      <div className="cc-react-table cc-react-pnp-calculator-table">
        <form className="cc-react-form">
          <table>
            <thead>
              <tr>
                <th className="cc-react-text--small">Unit Type</th>
                <th className="cc-react-table--right cc-react-text--small">Current Units</th>
                <th className="cc-react-table--right cc-react-text--small">Units to Add</th>
                <th className="cc-react-table--right cc-react-text--small">Total</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td>Transfer and Test</td>
                <td className="cc-react-table--right">{props.calculator.totalTransferUnits.toFixed(2)}</td>
                <td>
                  <input className="cc-react-form__input" type="number" min="0" name="totalTransferUnits" onChange={props.handleInputChange}/>
                </td>
                <td className="cc-react-table--right">
                  {props.calculatedTotals.totalTransferUnits.toFixed(2)}
                </td>
              </tr>
              <tr>
                <td>Berkeley Letter Grade</td>
                <td className="cc-react-table--right">{props.calculator.totalGpaUnits.toFixed(2)}</td>
                <td>
                  <input className="cc-react-form__input" type="number" min="0" name="totalGpaUnits" onChange={props.handleInputChange}/>
                </td>
                <td className="cc-react-table--right">
                  {props.calculatedTotals.totalGpaUnits.toFixed(2)}
                </td>
              </tr>
              <tr>
                <td>Berkeley P/NP</td>
                <td className="cc-react-table--right">{props.calculator.totalNoGpaUnits.toFixed(2)}</td>
                <td>
                  <input className="cc-react-form__input" type="number" min="0" name="totalNoGpaUnits" onChange={props.handleInputChange}/>
                </td>
                <td className="cc-react-table--right">
                  {props.calculatedTotals.totalNoGpaUnits.toFixed(2)}
                </td>
              </tr>
              <tr>
                <td colSpan="3" className="cc-react-table--right">
                  Total Sum
                </td>
                <td className="cc-react-table--right">
                  <strong>{props.calculatedTotals.totalSum.toFixed(2)}</strong>
                </td>
              </tr>
            </tbody>
          </table>
          {renderTransferUnitNote(props.inputStatus.hasTransferUnitInput)}
          {renderInputErrorMessage(props.inputStatus.errored)}
          <div className="cc-react--float-right">
            <button className="cc-react-button cc-react-button--blue" disabled={props.inputStatus.estimateButtonDisabled} onClick={props.handleEstimateButtonPressed}>Estimate</button>
          </div>
        </form>
      </div>
      {renderProjectedRatio(props.calculatedProjectedValues.ratio)}
    </div>
  );
};
PassedGradeLimitEstimator.propTypes = {
  calculator: PropTypes.object.isRequired,
  calculatedProjectedValues: PropTypes.object.isRequired,
  calculatedTotals: PropTypes.object.isRequired,
  handleEstimateButtonPressed: PropTypes.func.isRequired,
  handleInputChange: PropTypes.func.isRequired,
  inputStatus: PropTypes.object.isRequired
};

export default PassedGradeLimitEstimator;
