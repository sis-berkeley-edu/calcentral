import React, { useState } from 'react';
import PropTypes from 'prop-types';
import APILink from 'React/components/APILink';
import HasAccessTo from './HasAccessTo';
import FinancialResourcesCategoryHeader from './FinancialResourcesCategoryHeader';
import './FinancialResources.scss';

const FinaidFormsInfo = ({ links, getLink, status, expanded }) => {
  const [isExpanded, setIsExpanded] = useState(expanded);
  const isDelegate = status.delegateActingAsUid ? true : false;

  return (
    <HasAccessTo
      linkNames={[
        'fafsaVerify',
        'fafsaVerify',
        'finaidForms',
        'fafsa',
        'dreamActApplication',
        'emergencyLoan',
        'emergencyLoanApply',
        'finaidSummary',
        'finaidSummaryDelegate',
        'finaidOffice',
        'costOfAttendance',
        'gradFinancialSupport',
        'workStudy',
        'studentAdvocateOffice',
        'berkeleyInternationalOffice',
      ]}
      links={links}
    >
      <div className="FinancialResources__categoryContainer">
        <div onClick={() => setIsExpanded(!isExpanded)}>
          <FinancialResourcesCategoryHeader
            title="Financial Aid Forms and Information"
            expanded={isExpanded}
          />
        </div>
        {isExpanded && (
          <ul className="FinancialResources">
            <HasAccessTo linkNames={['fafsaVerify']} links={links}>
              {links && (
                <li>
                  <APILink {...getLink('fafsaVerify', links)} />
                </li>
              )}
            </HasAccessTo>
            <HasAccessTo linkNames={['finaidForms']} links={links}>
              {links && (
                <li>
                  <APILink {...getLink('finaidForms', links)} />
                </li>
              )}
            </HasAccessTo>
            <HasAccessTo linkNames={['fafsa']} links={links}>
              {links && (
                <li>
                  <APILink {...getLink('fafsa', links)} />
                </li>
              )}
            </HasAccessTo>
            <HasAccessTo linkNames={['dreamActApplication']} links={links}>
              {links && (
                <li>
                  <APILink {...getLink('dreamActApplication', links)} />
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

            {!isDelegate && (
              <HasAccessTo linkNames={['finaidSummary']} links={links}>
                {links && (
                  <li>
                    <APILink {...getLink('finaidSummary', links)} />
                  </li>
                )}
              </HasAccessTo>
            )}
            {isDelegate ? (
              <HasAccessTo linkNames={['finaidSummaryDelegate']} links={links}>
                {links && (
                  <li>
                    <APILink {...getLink('finaidSummaryDelegate', links)} />
                  </li>
                )}
              </HasAccessTo>
            ) : (
              <HasAccessTo linkNames={['finaidSummary']} links={links}>
                {links && (
                  <li>
                    <APILink {...getLink('finaidSummary', links)} />
                  </li>
                )}
              </HasAccessTo>
            )}
            <HasAccessTo linkNames={['finaidOffice']} links={links}>
              {links && (
                <li>
                  <APILink {...getLink('finaidOffice', links)} />
                </li>
              )}
            </HasAccessTo>
            <HasAccessTo linkNames={['costOfAttendance']} links={links}>
              {links && (
                <li>
                  <APILink {...getLink('costOfAttendance', links)} />
                </li>
              )}
            </HasAccessTo>
            <HasAccessTo linkNames={['gradFinancialSupport']} links={links}>
              {links && (
                <li>
                  <APILink {...getLink('gradFinancialSupport', links)} />
                </li>
              )}
            </HasAccessTo>
            <HasAccessTo linkNames={['workStudy']} links={links}>
              {links && (
                <li>
                  <APILink {...getLink('workStudy', links)} />
                </li>
              )}
            </HasAccessTo>
            <HasAccessTo linkNames={['studentAdvocateOffice']} links={links}>
              {links && (
                <li>
                  <APILink {...getLink('studentAdvocateOffice', links)} />
                </li>
              )}
            </HasAccessTo>
            <HasAccessTo
              linkNames={['berkeleyInternationalOffice']}
              links={links}
            >
              {links && (
                <li>
                  <APILink {...getLink('berkeleyInternationalOffice', links)} />
                </li>
              )}
            </HasAccessTo>
          </ul>
        )}
      </div>
    </HasAccessTo>
  );
};

FinaidFormsInfo.propTypes = {
  expanded: PropTypes.bool,
  getLink: PropTypes.func,
  status: PropTypes.object,
  links: PropTypes.object,
};

export default FinaidFormsInfo;
