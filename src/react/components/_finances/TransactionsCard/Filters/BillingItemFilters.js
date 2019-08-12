import React from 'react';
import PropTypes from 'prop-types';

import { ButtonGroup, GroupedButton } from 'react/components/ButtonGroup';

import TermDropdown from './TermDropdown';
import BillingItemSearch from './BillingItemSearch';

import './BillingItemFilters.scss';

import {
  BILLING_VIEW_ALL,
  BILLING_VIEW_UNPAID,
  BILLING_VIEW_PAYMENTS_AID
} from '../billingItemViews';

const ButtonForTab = ({ tab, activeTab, setTab }) => {
  return (
    <GroupedButton
      active={activeTab === tab}
      onClick={() => setTab(tab)}>
      {tab}
    </GroupedButton>
  );
};
ButtonForTab.propTypes = {
  tab: PropTypes.string,
  activeTab: PropTypes.string,
  setTab: PropTypes.func
};

const BillingItemFilters = ({ tab, setTab, termIds, termId, setTermId, search, setSearch }) => (
  <div className='BillingItemFilters'>
    <ButtonGroup>
      <ButtonForTab tab={BILLING_VIEW_ALL} activeTab={tab} setTab={setTab} />
      <ButtonForTab tab={BILLING_VIEW_UNPAID} activeTab={tab} setTab={setTab} />
      <ButtonForTab tab={BILLING_VIEW_PAYMENTS_AID} activeTab={tab} setTab={setTab} />
    </ButtonGroup>

    <TermDropdown termIds={termIds} value={termId} onChange={setTermId} />

    <BillingItemSearch search={search} setSearch={setSearch} />
  </div>
);

BillingItemFilters.propTypes = {
  tab: PropTypes.string,
  setTab: PropTypes.func,
  termIds: PropTypes.array,
  termId: PropTypes.string,
  setTermId: PropTypes.func,
  search: PropTypes.string,
  setSearch: PropTypes.func
};

export default BillingItemFilters;
