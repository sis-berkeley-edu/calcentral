import React, { Fragment } from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';

import GenericTransferCredit from './GenericTransferCredit';
import LawTransferCredit from './LawTransferCredit';

import './TransferCredit.scss';

const propTypes = {
  graduate: PropTypes.object,
  undergraduate: PropTypes.object,
  law: PropTypes.object,
  semesters: PropTypes.array,
  isStudent: PropTypes.bool,
  reportLink: PropTypes.object,
  studentLinks: PropTypes.object,
  advisorLinks: PropTypes.object
};

const TransferCredit = ({
  semesters,
  isStudent,
  studentLinks,
  advisorLinks, ...careers
}) => {
  const reportLink = () =>{
    const links = advisorLinks || studentLinks;
    if (links) {
      return links.tcReportLink;
    }
  };

  return (
    <Fragment>
      {!careers.law.detailed && !careers.law.summary && <GenericTransferCredit {...careers.undergraduate}
        isStudent={isStudent}
        reportLink={reportLink()}
        />
      }
      <GenericTransferCredit {...careers.graduate}
        isStudent={isStudent}
        reportLink={reportLink()}
      />
      <LawTransferCredit {...careers.law}
        semesters={semesters}
        isStudent={isStudent}
        reportLink={reportLink()}
      />
    </Fragment>
  );
};

TransferCredit.propTypes = propTypes;

const mapStateToProps = ({ myAcademics, myTransferCredit, myStatus }) => {
  const {
    semesters,
    studentLinks,
    advisorLinks
  } = myAcademics;

  const {
    graduate,
    undergraduate,
    law
  } = myTransferCredit;

  const {
    roles: {
      student: isStudent
    }
  } = myStatus;

  return {
    law, undergraduate, graduate,
    semesters, isStudent,
    studentLinks,
    advisorLinks
  };
};

export default connect(mapStateToProps)(TransferCredit);
