import React from 'react';
import PropTypes from 'prop-types';
import Spinner from 'react/components/Spinner';
import 'icons/warning.svg';
import './Card.scss';

const CardError = ({ message }) => {
  if (message) {
    return (
      <div className="Card__error">
        <img src="/assets/images/warning.svg" />
        {message}
      </div>
    );
  } else {
    return null;
  }
};

CardError.propTypes = {
  message: PropTypes.string,
  error: PropTypes.object,
};

CardError.displayName = 'CardError';

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
        <h2>{title}</h2>
        {secondaryContent}
      </div>
      <div className="Card__body">
        {loading ? <Spinner /> : <CardError {...error} />}

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
