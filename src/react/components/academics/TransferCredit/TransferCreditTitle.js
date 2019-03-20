import React from 'react';
import PropTypes from 'prop-types';
import APILink from '../../APILink';

const propTypes = {
  description: PropTypes.string.isRequired,
  isStudent: PropTypes.bool,
  reportLink: PropTypes.object
};

const TransferCreditTitle = ({description, isStudent, reportLink}) => (
  <div className="TransferCredit__title cc-transfer-credit-summary__title">
    <h4>{description} Transfer Credit</h4>
    {isStudent && <APILink {...reportLink} ucFromText="My Academics" />}
  </div>
);

TransferCreditTitle.propTypes = propTypes;

export default TransferCreditTitle;
