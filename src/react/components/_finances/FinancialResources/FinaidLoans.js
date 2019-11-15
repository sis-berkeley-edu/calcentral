import React, { useState } from 'react';
import PropTypes from 'prop-types';
import APILink from 'React/components/APILink';
import HasAccessTo from './HasAccessTo';
import FinancialResourcesCategoryHeader from './FinancialResourcesCategoryHeader';
import './FinancialResources.scss';

const FinaidLoans = ({ links, getLink, expanded }) => {
  const [isExpanded, setIsExpanded] = useState(expanded);

  return (
    <HasAccessTo
      linkNames={[
        'nslds',
        'loanRepaymentCalculator',
        'federalStudentLoans',
        'stateInstitutionalLoans',
        'leavingCal',
        'emergencyLoan',
        'emergencyLoanApply',
      ]}
      links={links}
    >
      <div className="FinancialResources__categoryContainer">
        <div onClick={() => setIsExpanded(!isExpanded)}>
          <FinancialResourcesCategoryHeader
            title="Financial Aid Loans"
            expanded={isExpanded}
          />
        </div>
        {isExpanded && (
          <ul className="FinancialResources">
            <HasAccessTo linkNames={['nslds']} links={links}>
              {links && (
                <li>
                  <APILink {...getLink('nslds', links)} />
                </li>
              )}
            </HasAccessTo>
            <HasAccessTo linkNames={['loanRepaymentCalculator']} links={links}>
              {links && (
                <li>
                  <APILink {...getLink('loanRepaymentCalculator', links)} />
                </li>
              )}
            </HasAccessTo>
            <HasAccessTo linkNames={['federalStudentLoans']} links={links}>
              {links && (
                <li>
                  <APILink {...getLink('federalStudentLoans', links)} />
                </li>
              )}
            </HasAccessTo>
            <HasAccessTo linkNames={['stateInstitutionalLoans']} links={links}>
              {links && (
                <li>
                  <APILink {...getLink('stateInstitutionalLoans', links)} />
                </li>
              )}
            </HasAccessTo>
            <HasAccessTo linkNames={['leavingCal']} links={links}>
              {links && (
                <li>
                  <APILink {...getLink('leavingCal', links)} />
                </li>
              )}
            </HasAccessTo>
            <HasAccessTo linkNames={['emergencyLoan']} links={links}>
              {links && (
                <li>
                  <div className="FinancialResources__multipleLinksContainer">
                    <APILink {...getLink('emergencyLoan', links)} />
                    <HasAccessTo
                      linkNames={['emergencyLoanApply']}
                      links={links}
                    >
                      <span className="FinancialResources__seperator">|</span>
                      <span className="FinancialResources__secondaryLink">
                        <APILink {...getLink('emergencyLoanApply', links)} />
                      </span>
                    </HasAccessTo>
                  </div>
                </li>
              )}
            </HasAccessTo>
          </ul>
        )}
      </div>
    </HasAccessTo>
  );
};

FinaidLoans.propTypes = {
  expanded: PropTypes.bool,
  getLink: PropTypes.func,
  links: PropTypes.object,
};

export default FinaidLoans;
