import React from 'react';
import PropTypes from 'prop-types'; 
import { usdFilter } from '../../../helpers/filters';

import '../../../stylesheets/billing_summary.scss';
import '../../../stylesheets/box_model.scss';
import '../../../stylesheets/tables.scss';
import '../../../stylesheets/text.scss';
import '../../../stylesheets/widgets.scss';

const proptypes = {
  amountDueNow: PropTypes.number,
  chargesNotYetDue: PropTypes.number,
  pastDueAmount: PropTypes.number,
  totalUnpaidBalance: PropTypes.number
};

const renderOverdueAmount = (amount) => {
  let value = parseFloat(amount);
  if (value > 0) {
    return (
      <p className="cc-react-text--red cc-react--no-margin">{`Includes Overdue: ${usdFilter(amount)}`}</p>
    );
  }
};

const Balances = (props) => {
  return (
    <div>
      <div className="summary-section cc-react-widget--padding">
        Due Now
        <h2 className="cc-react-text--callout" >{ usdFilter(props.amountDueNow) }</h2>
        { renderOverdueAmount(props.pastDueAmount) }
      </div>

      <div className="cc-react-table cc-react-widget--padding-sides">
        <table className="billing-summary-table">
          <tbody>
            <tr>
              <td>Due Now</td>
              <td className="cc-react-table--right">{usdFilter(props.amountDueNow)}</td>
            </tr>
            <tr>
              <td>Not Yet Due</td>
              <td className="cc-react-table--right">{usdFilter(props.chargesNotYetDue)}</td>
            </tr>
            <tr>
              <td className="total-unpaid-balance"><strong>Total Unpaid Balance</strong></td>
              <td className="cc-react-table--right total-unpaid-balance total-unpaid-balance-value">{usdFilter(props.totalUnpaidBalance)}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  );
};
Balances.propTypes = proptypes;

export default Balances;
