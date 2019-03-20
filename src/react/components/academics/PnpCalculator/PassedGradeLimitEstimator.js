import PropTypes from 'prop-types';
import React from 'react';

import Icon from '../../Icon/Icon';
import { ICON_CHECKMARK, ICON_EXCLAMATION } from '../../Icon/IconTypes';

import '../../../stylesheets/box_model.scss';
import '../../../stylesheets/buttons.scss';
import '../../../stylesheets/forms.scss';
import '../../../stylesheets/pnp_calculator.scss';
import '../../../stylesheets/tables.scss';
import '../../../stylesheets/text.scss';
import '../../../stylesheets/widgets.scss';

const propTypes = {
  calculator: PropTypes.object.isRequired,
  calculatedProjectedValues: PropTypes.object.isRequired,
  calculatedTotals: PropTypes.object.isRequired,
  handleEstimateButtonPressed: PropTypes.func.isRequired,
  handleInputChange: PropTypes.func.isRequired,
  inputStatus: PropTypes.object.isRequired
};

const renderInputErrorMessage = (errored) => {
  if (errored) {
    return (
      <div>
        <p className="cc-react-text--align-right cc-react-text--red">
          <Icon name={ICON_EXCLAMATION} /> Please use valid values
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
        *Note: Transfer credit includes both course and exam credit. Only exams completed as a high school student are eligible for exam credit. Lower division
        transfer course credit may not exceed 70 semester units.
      </p>
    );
  } else {
    return null;
  }
};

const renderProjectedPercentage = (projectedPercentage) => {
  if (Number.isFinite(projectedPercentage)) {
    let icon, message;
    if (projectedPercentage > 33) {
      icon = <Icon name={ICON_EXCLAMATION} />;
      message = 'You cannot exceed 33% by the time of graduation';
    } else {
      icon = <Icon name={ICON_CHECKMARK} />;
      message = 'Meets the 33% limit';
    }
    return (
      <div className="cc-react-widget__highlighted-section cc-react-text--align-right">
        <p className="cc-react--no-margin">Projected Percentage</p>
        <h2 className='cc-react--no-margin cc-react-text--bold'>
          {icon} {`${projectedPercentage}%`}
        </h2>
        <p className="cc-react--no-margin">{message}</p>
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
        Add units you expect to earn by your Expected Graduation Term:
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
                <td>Transfer Credit*</td>
                <td className="cc-react-table--right">{props.calculator.totalTransferUnits.toFixed(2)}</td>
                <td>
                  <input className="cc-react-form__input cc-react-text--align-right" type="number" min="0" name="totalTransferUnits" onChange={props.handleInputChange}/>
                </td>
                <td className="cc-react-table--right">
                  {props.calculatedTotals.totalTransferUnits.toFixed(2)}
                </td>
              </tr>
              <tr>
                <td>Berkeley Letter Grade</td>
                <td className="cc-react-table--right">{props.calculator.totalGpaUnits.toFixed(2)}</td>
                <td>
                  <input className="cc-react-form__input cc-react-text--align-right" type="number" min="0" name="totalGpaUnits" onChange={props.handleInputChange}/>
                </td>
                <td className="cc-react-table--right">
                  {props.calculatedTotals.totalGpaUnits.toFixed(2)}
                </td>
              </tr>
              <tr>
                <td>Berkeley P/NP</td>
                <td className="cc-react-table--right">{props.calculator.totalNoGpaUnits.toFixed(2)}</td>
                <td>
                  <input className="cc-react-form__input cc-react-text--align-right" type="number" min="0" name="totalNoGpaUnits" onChange={props.handleInputChange}/>
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
            <button className="cc-react-button cc-react-button--blue" disabled={props.inputStatus.estimateButtonDisabled} onClick={props.handleEstimateButtonPressed}>Estimate Percentage</button>
          </div>
        </form>
      </div>
      {renderProjectedPercentage(props.calculatedProjectedValues.percentage)}
    </div>
  );
};
PassedGradeLimitEstimator.propTypes = propTypes;

export default PassedGradeLimitEstimator;
