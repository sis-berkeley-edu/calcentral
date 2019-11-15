import React, { useState } from 'react';
import PropTypes from 'prop-types';
import APILink from 'React/components/APILink';
import HasAccessTo from './HasAccessTo';
import FinancialResourcesCategoryHeader from './FinancialResourcesCategoryHeader';
import VisuallyHidden from '../../VisuallyHidden';
import './FinancialResources.scss';

const BillingPayments = ({ links, eft, getLink, status, expanded }) => {
  const [isExpanded, setIsExpanded] = useState(expanded);
  const hasEft = eft.data
    ? eft.data.eftStatus === 'active' && eft.data.accountNumber
    : false;
  const isViewAs =
    status.actingAsUid ||
    status.advisorActingAsUid ||
    status.delegateActingAsUid
      ? true
      : false;

  return (
    <HasAccessTo
      linkNames={[
        'delegateAccess',
        'paymentOptions',
        'tuitionAndFees',
        'billingFAQ',
        'directDeposit',
        'directDepositManage',
        'directDepositEnroll',
        'tuitionAndFPP',
        'tenNinetyEightT',
        'tenNinetyEightTView',
      ]}
      links={links}
    >
      <div className="FinancialResources__categoryContainer">
        <div onClick={() => setIsExpanded(!isExpanded)}>
          <FinancialResourcesCategoryHeader
            title="Billing and Payments"
            expanded={isExpanded}
          />
        </div>
        {isExpanded && (
          <ul className="FinancialResources">
            <HasAccessTo linkNames={['delegateAccess']} links={links}>
              {links && (
                <li>
                  <APILink {...getLink('delegateAccess', links)} />
                </li>
              )}
            </HasAccessTo>
            <HasAccessTo linkNames={['paymentOptions']} links={links}>
              {links && (
                <li>
                  <APILink {...getLink('paymentOptions', links)} />
                </li>
              )}
            </HasAccessTo>
            <HasAccessTo linkNames={['tuitionAndFees']} links={links}>
              {links && (
                <li>
                  <APILink {...getLink('tuitionAndFees', links)} />
                </li>
              )}
            </HasAccessTo>
            <HasAccessTo linkNames={['billingFAQ']} links={links}>
              {links && (
                <li>
                  <APILink {...getLink('billingFAQ', links)} />
                </li>
              )}
            </HasAccessTo>
            <HasAccessTo linkNames={['directDeposit']} links={links}>
              {links && (
                <li>
                  <div className="FinancialResources__multipleLinks">
                    <APILink {...getLink('directDeposit', links)} />
                    <HasAccessTo
                      linkNames={['directDepositManage', 'directDepositEnroll']}
                      links={links}
                    >
                      <span className="FinancialResources__seperator">|</span>
                      <span className="FinancialResources__secondaryLink">
                        {hasEft ? (
                          <APILink {...getLink('directDepositManage', links)} />
                        ) : (
                          <APILink {...getLink('directDepositEnroll', links)} />
                        )}
                      </span>
                    </HasAccessTo>
                  </div>
                  {hasEft ? (
                    <>
                      <span className="FinancialResources__greenText FinancialResources__nestedDash FinancialResources__linksText">
                        Status:{' '}
                        <i className="fa fa-check FinancialResources__greenText"></i>{' '}
                        Active
                      </span>
                      <span className="FinancialResources__greenText FinancialResources__nestedDash FinancialResources__linksText">
                        Account <span aria-hidden="true">#: </span>
                        <VisuallyHidden>Number</VisuallyHidden>
                        {eft.data.accountNumber}
                      </span>
                    </>
                  ) : (
                    <span className="FinancialResources__nestedDash FinancialResources__linksText">
                      Status: Not Active
                    </span>
                  )}
                </li>
              )}
            </HasAccessTo>
            <HasAccessTo linkNames={['tuitionAndFPP']} links={links}>
              {links && (
                <li>
                  <div className="FinancialResources__multipleLinksContainer">
                    <APILink {...getLink('tuitionAndFPP', links)} />
                    <HasAccessTo linkNames={['activateFPP']} links={links}>
                      <span className="FinancialResources__seperator">|</span>
                      <span className="FinancialResources__secondaryLink">
                        <APILink
                          {...getLink('activateFPP', links)}
                          disabled={isViewAs}
                        />
                      </span>
                    </HasAccessTo>
                  </div>
                </li>
              )}
            </HasAccessTo>
            <HasAccessTo linkNames={['tenNinetyEightT']} links={links}>
              {links && (
                <li>
                  <div className="FinancialResources__multipleLinksContainer">
                    <APILink {...getLink('tenNinetyEightT', links)} />
                    <HasAccessTo
                      linkNames={['tenNinetyEightTView']}
                      links={links}
                    >
                      <>
                        <span className="FinancialResources__seperator">|</span>
                        <span className="FinancialResources__secondaryLink">
                          <APILink {...getLink('tenNinetyEightTView', links)} />
                        </span>
                      </>
                    </HasAccessTo>
                  </div>
                  <HasAccessTo
                    linkNames={['tenNinetyEightTView']}
                    links={links}
                  >
                    <span className="FinancialResources__nestedDash FinancialResources__linksText">
                      Use Site ID 11554
                    </span>
                  </HasAccessTo>
                </li>
              )}
            </HasAccessTo>
          </ul>
        )}
      </div>
    </HasAccessTo>
  );
};

BillingPayments.propTypes = {
  eft: PropTypes.object,
  expanded: PropTypes.bool,
  getLink: PropTypes.func,
  status: PropTypes.object,
  links: PropTypes.object,
};

export default BillingPayments;
