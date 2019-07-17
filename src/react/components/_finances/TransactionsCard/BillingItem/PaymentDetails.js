import React, { Fragment, useState } from 'react';
import PropTypes from 'prop-types';

import ItemDetails from './ItemDetails';
import Tabs from 'react/components/Tabs';
import ChargesPaid from './ChargesPaid';

import './ItemDetails.scss';

const PaymentDetails = ({ item }) => {
  const tabs = [
    { name: 'Details', tab: <ItemDetails item={item} /> },
    { name: 'Charges Paid', tab: <ChargesPaid item={item}/> }
  ];

  const [currentTab, setTab] = useState(tabs[0].name);

  return (
    <Fragment>
      <Tabs tabs={tabs.map(tab => tab.name)} current={currentTab} setTab={setTab} />
      { tabs.find(tab => tab.name === currentTab).tab }
    </Fragment>
  );
};

PaymentDetails.propTypes = {
  item: PropTypes.object
};

export default PaymentDetails;
