import React, { useState } from 'react';
import PropTypes from 'prop-types';

import './DisclosureItem.scss';

export const DisclosureItemTitle = ({ children }) => <div>{children}</div>;
DisclosureItemTitle.propTypes = { children: PropTypes.node };

const propTypes = {
  title: PropTypes.node,
  children: PropTypes.arrayOf(PropTypes.node)
};

export const DisclosureItem = ({ children }) => {
  const title = children[0];
  const body = children[1];
  const [open, setOpen] = useState(false);

  const classNames = open ? 'DisclosureItem DisclosureItem--open' : 'DisclosureItem DisclosureItem--closed';

  return (
    <div className={classNames} onClick={() => setOpen(!open)} tabIndex='0'>
      { title }
      { open && body }
    </div>
  );
};

DisclosureItem.propTypes = propTypes;
