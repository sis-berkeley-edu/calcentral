import React, { useState, useEffect } from 'react';

import { react2angular } from 'react2angular';
import Widget from 'react/components/Widget/Widget';

import axios from 'axios';

import 'icons/clipboard-list.svg';
import ReduxProvider from 'react/components/ReduxProvider';
import APILink from 'react/components/APILink';

import styles from './AlumniHomepage.module.scss';

const defaultAlumData = {
  homepageLinkObj: {},
  landingPageMessage: '',
}

const AlumniHomepage = () => {
  const [errored, setErrored] = useState(false);
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
          }
        );
        setIsLoading(false);
      })
      .catch(_err => {
        setErrored(true);
        setIsLoading(false);
      });
  };


  useEffect(() => {
    fetchData();
  }, []);

  return (
    <Widget config={{ ...widgetConfig }}>
      <p className={styles.messageText}>
        {alumData.landingPageMessage}
      </p>
      <div className={styles.buttonDiv}>
        <APILink {...alumData.homepageLinkObj} style={{ display: 'block' }} className="cc-react-button cc-react-button--blue" />
      </div>
    </Widget>
  );
};

const AlumniHomepageContainer = () => (
  <ReduxProvider>
    <AlumniHomepage />
  </ReduxProvider>
);

angular
  .module('calcentral.react')
  .component('alumniHomepage', react2angular(AlumniHomepageContainer));
