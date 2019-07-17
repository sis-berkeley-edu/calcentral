import React from 'react';
import PropTypes from 'prop-types';

import 'icons/search.svg';
import './BillingItemSearch.scss';

const BillingItemSearch = ({ search, setSearch }) => ( 
  <div className="BillingItemSearch">
    <label>Search</label>
    <input type="search" value={search} onChange={(e) => setSearch(e.currentTarget.value)} />
  </div>
);
BillingItemSearch.propTypes = {
  search: PropTypes.string,
  setSearch: PropTypes.func
};

export default BillingItemSearch;
