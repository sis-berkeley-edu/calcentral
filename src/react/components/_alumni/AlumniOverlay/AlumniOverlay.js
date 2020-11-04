import React, { useState, useEffect } from 'react';
import { connect } from 'react-redux';
import { react2angular } from 'react2angular';
import axios from 'axios';
import PropTypes from 'prop-types';

import Widget from 'react/components/Widget/Widget';
import 'icons/clipboard-list.svg';
import ReduxProvider from 'components/ReduxProvider';

import styles from './AlumniOverlay.module.scss';
import '../../../../assets/images/svg/calcentral_logo_whitebg.svg';

const defaultAlumData = {
  homepageLinkObj: {},
  landingPageMessage: '',
  landingPageSubTitle: '',
  skipLandingPage: false
}

const AlumniOverlay = (props) => {
  const [errored, setErrored] = useState(false);
  const [dontShowAgain, setDontShowAgain] = useState(false);
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
      .then(_res => {
        setAlumData(
          {
            homepageLinkObj: _res[0].data.homepageLink,
            landingPageMessage: _res[0].data.landingPageMessage.descrlong,
            landingPageSubTitle: _res[0].data.landingPageSubTitle.descrlong,
            skipLandingPage: _res[0].data.skipLandingPage
          }
        );
        if (_res[0].data.skipLandingPage) {
          navigateToLandingPage(false, _res[0].data.homepageLink);
        } else {
          setIsLoading(false);
        }
      })
      .catch(_err => {
        setErrored(true);
        setIsLoading(false);
      });
  };

  const navigateToLandingPage = (saveDontShowAgain, homepageURL) => {
    const setSkipFlag = axios.get(
      '/api/alumni/set_skip_landing_page'
    );
    const callLogout = axios.post(
      '/logout'
    );
    let promiseList = [callLogout];
    if (saveDontShowAgain) promiseList = [setSkipFlag, callLogout];
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

  const handleInputChange = (e) => {
    setDontShowAgain(e.target.checked);
  }

  const handleOnClick = () => {
    navigateToLandingPage(dontShowAgain, alumData.homepageLinkObj);
  }

  const landingPage = <div className={styles.lightbox}>
    <Widget cardStyle={{ width: "300px", borderRadius: "5px", textAlign: "center" }} hideHeader={true} config={{ ...widgetConfig }}>
      <div className={styles.cardDiv}>
        <img className={styles.logo} src="/assets/images/calcentral_logo_whitebg.svg" />
        <h2>{alumData.landingPageSubTitle}</h2>
        <div width="100%" >
          <p className={styles.messageText}>{alumData.landingPageMessage}</p>
        </div>
        <br />
        <a
          title={alumData.homepageLinkObj.title}
          target="_self"
          className="cc-react-button cc-react-button--blue"
          onClick={handleOnClick}
        >
          {alumData.homepageLinkObj.name}
        </a>
        <p className={styles.showCheck}>
          <span className={styles.showCheckbox}><input
            name="numberOfGuests"
            type="checkbox"
            value={dontShowAgain}
            onChange={handleInputChange} /></span><span> Don’t show me this again.</span>
        </p>
      </div>
    </Widget>
  </div>

  return landingPage;
};

AlumniOverlay.propTypes = {
  csrfToken: PropTypes.string
};

const mapStateToProps = ({
  config: { csrfToken }
}) => {
  return { csrfToken };
};

const ConnectedAlumniOverlay = connect(mapStateToProps)(AlumniOverlay);

const AlumniOverlayContainer = () => (
  <ReduxProvider>
    <ConnectedAlumniOverlay />
  </ReduxProvider>
);

angular
  .module('calcentral.react')
  .component('alumniOverlay', react2angular(AlumniOverlayContainer));
