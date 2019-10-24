import React, { useEffect, useState } from 'react';
import PropTypes from 'prop-types';
import store from 'Redux/store';
import Spinner from '../../Spinner';
import TopResources from './TopResources';
import BillingPayments from './BillingPayments';
import FinaidFormsInfo from './FinaidFormsInfo';
import FinaidLoans from './FinaidLoans';
import FinancialPlanningLiteracy from './FinancialPlanningLiteracy';
import CalOneCard from './CalOneCard';
import WithdrawalCancellation from './WithdrawalCancellation';
import SummerSessions from './SummerSessions';
import HaveAQuestion from './HaveAQuestion';
import { Provider, connect } from 'react-redux';
import { react2angular } from 'react2angular';
import { fetchFinresLinks } from 'Redux/actions/financialResourcesLinksActions';
import { fetchEftEnrollment } from 'Redux/actions/eftEnrollmentActions';
import { fetchSirStatus } from 'Redux/actions/sirStatusActions';
import { fetchStatus } from 'Redux/actions/statusActions';
import WithAccess from './WithAccess';
import getLink from './getLink';

const propTypes = {
  dispatch: PropTypes.func.isRequired,
  financialResourcesLinks: PropTypes.object,
  myEftEnrollment: PropTypes.object,
  myStatus: PropTypes.object,
  sirStatus: PropTypes.object,
};

const FinancialResources = ({
  dispatch,
  financialResourcesLinks,
  myEftEnrollment,
  myStatus,
  sirStatus,
}) => {
  useEffect(() => {
    dispatch(fetchFinresLinks());
    dispatch(fetchEftEnrollment());
    dispatch(fetchStatus());
    dispatch(fetchSirStatus());
  }, []);

  const [isAccessReady, setIsAccessReady] = useState(false);
  const linksReady = financialResourcesLinks.loaded;
  const eftReady = myEftEnrollment.loaded;
  const sirStatusReady = sirStatus.loaded;
  const statusReady = myStatus.loaded;

  return (
    <WithAccess onReady={() => setIsAccessReady(true)}>
      {linksReady &&
      eftReady &&
      isAccessReady &&
      sirStatusReady &&
      statusReady ? (
        <div className="FinancialResources__container">
          <TopResources
            eft={myEftEnrollment}
            expanded={true}
            getLink={getLink}
            links={financialResourcesLinks.links}
            status={myStatus}
          />
          <BillingPayments
            eft={myEftEnrollment}
            expanded={false}
            getLink={getLink}
            links={financialResourcesLinks.links}
            status={myStatus}
          />
          <FinaidFormsInfo
            expanded={false}
            getLink={getLink}
            links={financialResourcesLinks.links}
          />
          <FinaidLoans
            expanded={false}
            getLink={getLink}
            links={financialResourcesLinks.links}
          />
          <FinancialPlanningLiteracy
            expanded={false}
            getLink={getLink}
            links={financialResourcesLinks.links}
          />
          <CalOneCard
            expanded={false}
            getLink={getLink}
            links={financialResourcesLinks.links}
          />
          <WithdrawalCancellation
            expanded={false}
            getLink={getLink}
            links={financialResourcesLinks.links}
          />
          <SummerSessions
            expanded={false}
            getLink={getLink}
            links={financialResourcesLinks.links}
            sirStatus={sirStatus}
          />
          <HaveAQuestion
            getLink={getLink}
            links={financialResourcesLinks.links}
          />
        </div>
      ) : (
        <Spinner padded={false} />
      )}
    </WithAccess>
  );
};

FinancialResources.propTypes = propTypes;

const mapStateToProps = ({
  financialResourcesLinks = {},
  myEftEnrollment = {},
  myStatus = {},
  sirStatus = {},
}) => {
  return {
    financialResourcesLinks: financialResourcesLinks,
    myEftEnrollment: myEftEnrollment,
    myStatus: myStatus,
    sirStatus: sirStatus,
  };
};

const ConnectedFinancialResources = connect(mapStateToProps)(
  FinancialResources
);

const FinancialResourcesContainer = () => {
  return (
    <Provider store={store}>
      <ConnectedFinancialResources />
    </Provider>
  );
};

angular
  .module('calcentral.react')
  .component('financialResources', react2angular(FinancialResourcesContainer));
