import React, { useState, useEffect } from 'react';

import { react2angular } from 'react2angular';
import Widget from 'react/components/Widget/Widget';

import axios from 'axios';

import 'icons/clipboard-list.svg';
import ReduxProvider from 'react/components/ReduxProvider';
import APILink from 'react/components/APILink';

import styles from './LawDegreeAudit.module.scss';

const LawDegreeAudit = () => {
  const [errored, setErrored] = useState(false);
  const [isLoading, setIsLoading] = useState(true);
  const [linkObj, setLinkObj] = useState({});
  const [faqLink, setFaqLink] = useState({});

  const widgetConfig = {
    errored: errored,
    errorMessage: 'The Law Degree Audit is not available right now.',
    isLoading: isLoading,
    padding: true,
    title: 'Law Degree Audit',
    visible: true,
  };

  const fetchLinks = () => {
    const auditLink = axios.get(
      '/api/campus_solutions/link?urlId=UC_AA_LAW_DEGREE_AUDIT'
    );
    const faqLink = axios.get(
      '/api/campus_solutions/link?urlId=UC_AA_LAW_DEGREE_AUDIT_FAQ'
    );

    Promise.all([auditLink, faqLink])
      .then(responses => {
        setLinkObj(responses[0].data.link);
        setFaqLink(responses[1].data.link);
        setIsLoading(false);
      })
      .catch(_err => {
        setErrored(true);
        setIsLoading(false);
      });
  };

  useEffect(() => {
    fetchLinks();
  }, []);

  return (
    <Widget config={{ ...widgetConfig }}>
      <div className={styles.textContainer}>
        <h1>Law Degree Audit</h1>
        <p className={styles.helpText}>
          Review your progress in meeting degree requirements.
        </p>

        <p>
          <APILink {...linkObj} />
        </p>

        <p>
          Learn more at <APILink {...faqLink} />
        </p>
      </div>
    </Widget>
  );
};

const LawDegreeAuditContainer = () => (
  <ReduxProvider>
    <LawDegreeAudit />
  </ReduxProvider>
);

angular
  .module('calcentral.react')
  .component('lawDegreeAudit', react2angular(LawDegreeAuditContainer));
