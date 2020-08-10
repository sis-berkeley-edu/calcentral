import React, { useEffect } from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';

import APILink from 'react/components/APILink';
import ReadMore from 'react/components/ReadMore';

import 'react/../assets/images/bear_with_mask.png';
import 'icons/blue-bullet.svg';

import ErrorMessage from 'react/components/ErrorMessage';
import Spinner from 'react/components/Spinner';
import styles from './COVIDResponseCard.module.scss';

import { fetchCovidResponse } from 'redux/actions/covidResponseActions';

const COVIDCardWrapper = ({ children }) => (
  <div className={styles.wrapper}>
    <div className={styles.header}>
      <h1>COVID Response</h1>
      <div className={styles.headerDecorationWrapper}>
        <div className={styles.headerDecoration}>
          <img
            src="/assets/images/bear_with_mask.png"
            width="96"
            height="60"
            alt="Bear wearing mask"
          />
        </div>
      </div>
    </div>

    {children}
  </div>
);

COVIDCardWrapper.propTypes = {
  children: PropTypes.node,
};

const COVIDResponseCard = ({ covidResponse, fetchData }) => {
  useEffect(() => {
    fetchData();
  }, []);

  const {
    isLoading,
    error,
    screener,
    resourceLinks = [],
    campusUpdates: { descrlong: html, messageText: title } = {},
  } = covidResponse || {};

  return (
    <COVIDCardWrapper>
      {isLoading ? (
        <Spinner />
      ) : (
        <div className={styles.body}>
          {error ? (
            <ErrorMessage message="There was a problem loading this data, please try again later" />
          ) : (
            <>
              {screener && (
                <div className={styles.dailyScreener}>
                  <h2>{screener.message.messageText}</h2>
                  <p>{screener.message.descrlong}</p>
                  <APILink
                    {...screener.link}
                    gaSection="COVID Response Card"
                    className="cc-react-button cc-react-button--blue"
                  />
                </div>
              )}
              {html && (
                <div className={styles.campusUpdates}>
                  <h2>{title}</h2>
                  <ReadMore html={html} />
                </div>
              )}

              {resourceLinks.length > 0 && (
                <div className={styles.resources}>
                  <h2>Resources</h2>
                  <ul>
                    {resourceLinks.map(link => (
                      <li key={link.name}>
                        <APILink {...link} gaSection="COVID Response Card" />
                      </li>
                    ))}
                  </ul>
                </div>
              )}
            </>
          )}
        </div>
      )}
    </COVIDCardWrapper>
  );
};

COVIDResponseCard.propTypes = {
  covidResponse: PropTypes.shape({}),
  fetchData: PropTypes.func,
};

function mapStateToProps({ covidResponse }) {
  return { covidResponse };
}

function mapDispatchToProps(dispatch) {
  return {
    fetchData: () => {
      dispatch(fetchCovidResponse());
    },
  };
}

export default connect(
  mapStateToProps,
  mapDispatchToProps
)(COVIDResponseCard);
