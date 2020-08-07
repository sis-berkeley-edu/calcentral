import React from 'react';
import PropTypes from 'prop-types';
import Spinner from 'react/components/Spinner';
import 'icons/warning.svg';
import './Card.scss';

import ErrorMessage from './ErrorMessage';

const Card = ({
  children,
  title,
  loading,
  error,
  className,
  secondaryContent,
  node,
}) => {
  const classNames = ['Card', className].join(' ');

  return (
    <div ref={node} className={classNames}>
      <div className="Card__title">
        <h2 tabIndex="0">{title}</h2>
        {secondaryContent}
      </div>
      <div className="Card__body">
        {loading ? <Spinner /> : <ErrorMessage {...error} />}

        {!loading && !error && children}
      </div>
    </div>
  );
};

Card.propTypes = {
  title: PropTypes.string,
  children: PropTypes.node,
  loading: PropTypes.bool,
  className: PropTypes.string,
  secondaryContent: PropTypes.object,
  error: PropTypes.object,
  node: PropTypes.any,
};

Card.displayName = 'Card';

export default Card;
