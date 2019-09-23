import React, { useState } from 'react';
import PropTypes from 'prop-types';

import parseDate from 'date-fns/parse';
import BillingItem from '../BillingItem/BillingItem';
import ShowMore from './ShowMore';
import BillingItemsHeaders from './BillingItemsHeaders';
import NoItems from './NoItems';

const appendDate = items => items.map(item => ({ ...item, postedOn: parseDate(item.posted_on) }));
const sortItemsBy = (sortOrder, sortBy) => items => items.sort((a, b) => {
  if (sortOrder === 'ASC') {
    return a[sortBy] - b[sortBy];
  }

  return b[sortBy] - a[sortBy];
});

const limitIf = ({ shouldLimit, limit }) => {
  return items => shouldLimit ? items.slice(0, limit) : items;
};

import './BillingItemsTable.scss';

const BillingItemsTable = ({ items, tab, hasActiveFilters, expanded, setExpanded }) => {
  const [showAll, setShowAll] = useState(false);
  const [sortBy, setSortBy] = useState('postedOn');
  const [sortOrder, setSortOrder] = useState('DESC');
  const onExpand = (id) => expanded === id ? setExpanded(null) : setExpanded(id);

  const itemLimit = 25;
  const sortItems = sortItemsBy(sortOrder, sortBy);
  const limitItems = limitIf({ shouldLimit: !showAll, limit: itemLimit });

  const filteredItems = sortItems(appendDate(items));
  const shownItems = limitItems(filteredItems);
  const showMore = filteredItems.length > itemLimit;

  return (
    <div className="BillingItemsTable">
      <BillingItemsHeaders 
        sortBy={sortBy}
        setSortBy={setSortBy}
        sortOrder={sortOrder}
        setSortOrder={setSortOrder}
        tab={tab}
      />

      { shownItems.map(item => (
        <BillingItem item={item} key={item.id}
          tab={tab}
          expanded={expanded === item.id}
          setExpanded={setExpanded}
          onExpand={() => onExpand(item.id)}
        />
      ))}

      { showMore &&
        <ShowMore expanded={showAll} onClick={() => setShowAll(!showAll)} />
      }

      { filteredItems.length === 0 &&
        <NoItems tab={tab} hasActiveFilters={hasActiveFilters} />
      }
    </div>
  );
};

BillingItemsTable.propTypes = {
  items: PropTypes.array,
  tab: PropTypes.string,
  hasActiveFilters: PropTypes.bool,
  expanded: PropTypes.string,
  setExpanded: PropTypes.func
};

export default BillingItemsTable;
