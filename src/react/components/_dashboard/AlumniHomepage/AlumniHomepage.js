import React, { useState, useEffect } from 'react';
import { react2angular } from 'react2angular';
import axios from 'axios';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';


import Widget from 'react/components/Widget/Widget';
import 'icons/clipboard-list.svg';
import ReduxProvider from 'components/ReduxProvider';
import styles from './AlumniHomepage.module.scss';

const defaultAlumData = {
  homepageLinkObj: {},
  landingPageMessage: '',
}

const AlumniHomepage = (props) => {
  const [errored, setErrored] = useState(false);
  const [isLoading, setIsLoading] = useState(true);
  const [alumData, setAlumData] = useState(defaultAlumData);

  axios.defaults.headers.common = {
    'X-Requested-With': 'XMLHttpRequest',
    'X-CSRF-TOKEN': props.csrfToken
  };

  const widgetConfig = {
    errored: errored,
    errorMessage: 'The Alumni Homepage is not available right now.',
    isLoading: isLoading,
    padding: true,
    title: 'Alumni Homepage',
    visible: true,
  };

  const fetchData = () => {
    const alumData = axios.get(
      '/api/alumni/alumni_profiles'
    );

    Promise.all([alumData])
      .then(responses => {
        setAlumData(
          {
            homepageLinkObj: responses[0].data.homepageLink,
            landingPageMessage: responses[0].data.landingPageMessage.descrlong,
          }
        );
        setIsLoading(false);
      })
      .catch(_err => {
        setErrored(true);
        setIsLoading(false);
      });
  };

  const navigateToLandingPage = (homepageURL) => {
    const callLogout = axios.post(
      '/logout'
    );
    let promiseList = [callLogout];
    setIsLoading(true);
    Promise.all(promiseList)
      .then((_res) => {
        window.location.href = homepageURL;
      })
      .catch(_err => {
        setErrored(true);
        setIsLoading(false);
      });
  };

  useEffect(() => {
    fetchData();
  }, []);

  const handleOnClick = () => {
    navigateToLandingPage(alumData.homepageLinkObj.url);
  }

  return (
    <Widget config={{ ...widgetConfig }}>
      <p className={styles.messageText}>
        {alumData.landingPageMessage}
      </p>
      <div className={styles.buttonDiv}>
        <a
          title={alumData.homepageLinkObj.title}
          target="_self"
          className="cc-react-button cc-react-button--blue"
          onClick={handleOnClick}
        >
          {alumData.homepageLinkObj.name}
        </a>
      </div>
      <br />
    </Widget>
  );
};

AlumniHomepage.propTypes = {
  csrfToken: PropTypes.string
};

const mapStateToProps = ({
  config: { csrfToken }
}) => {
  return { csrfToken };
};

const ConnectedAlumniHomepage = connect(mapStateToProps)(AlumniHomepage);

const AlumniHomepageContainer = () => (
  <ReduxProvider>
    <ConnectedAlumniHomepage />
  </ReduxProvider>
);

angular
  .module('calcentral.react')
  .component('alumniHomepage', react2angular(AlumniHomepageContainer));
