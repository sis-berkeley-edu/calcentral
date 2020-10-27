import React, { useState, useEffect } from 'react';

import { react2angular } from 'react2angular';
import Widget from 'react/components/Widget/Widget';

import axios from 'axios';

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

const AlumniOverlay = () => {
  const [errored, setErrored] = useState(false);
  const [dontShowAgain, setDontShowAgain] = useState(false);
  const [isLoading, setIsLoading] = useState(true);
  const [alumData, setAlumData] = useState(defaultAlumData);

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
            landingPageSubTitle: responses[0].data.landingPageSubTitle.descrlong,
            skipLandingPage: responses[0].data.skipLandingPage
          }
        );
        setIsLoading(false);
      })
      .catch(_err => {
        setErrored(true);
        setIsLoading(false);
      });
  };

  const setSkipLandingPage = () => {
    const setSkipFlag = axios.get(
      '/api/alumni/set_skip_landing_page'
    );
    setIsLoading(true);
    Promise.all([setSkipFlag])
      .then(() => {
        window.location.href = alumData.homepageLinkObj.url;
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
    if (dontShowAgain) {
      setSkipLandingPage();
    } else {
      window.location.href = alumData.homepageLinkObj.url;
    }
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

  if (!alumData.skipLandingPage) return landingPage;
  if (alumData.skipLandingPage) window.location.href = alumData.homepageLinkObj.url;
};

const AlumniOverlayContainer = () => (
  <ReduxProvider>
    <AlumniOverlay />
  </ReduxProvider>
);

angular
  .module('calcentral.react')
  .component('alumniOverlay', react2angular(AlumniOverlayContainer));
