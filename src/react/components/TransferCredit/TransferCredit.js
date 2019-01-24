import React, { Fragment } from 'react';
import PropTypes from 'prop-types';

import GenericTransferCredit from './GenericTransferCredit';
import LawTransferCredit from './LawTransferCredit';

import './TransferCredit.scss';

const propTypes = {
  graduate: PropTypes.object,
  undergraduate: PropTypes.object,
  law: PropTypes.object,
  semesters: PropTypes.array,
  isStudent: PropTypes.bool,
  reportLink: PropTypes.object
};

const TransferCredit = ({ semesters, isStudent, reportLink, ...careers }) => {
  return (
    <Fragment>
      <GenericTransferCredit {...careers.undergraduate}
        isStudent={isStudent}
        reportLink={reportLink}
      />
      <GenericTransferCredit {...careers.graduate}
        isStudent={isStudent}
        reportLink={reportLink}
      />
      <LawTransferCredit {...careers.law}
        semesters={semesters} 
        isStudent={isStudent}
        reportLink={reportLink}
      />
    </Fragment>
  );
};

TransferCredit.propTypes = propTypes;

export default TransferCredit;
