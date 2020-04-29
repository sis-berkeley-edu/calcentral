import React, { useState, useEffect } from 'react';
import { react2angular } from 'react2angular';
import Widget from '../../Widget/Widget';
import _ from 'lodash';
import CampusSolutionsLinkContainer from '../../CampusSolutionsLink/CampusSolutionsLinkContainer';

const LawDegreeAudit = (prop) => {

  const [errored, setErrored] = useState(false);
  const [isLoading, setIsLoading] = useState(true);
  const [linkObj, setLinkObj] = useState({});

  const widgetConfig =  {
    errored: errored,
    errorMessage: "The Law Degree Audit is not available right now.",
    isLoading: isLoading,
    padding: true,
    title: 'Law Degree Audit',
    visible: true
  };

  let fetchLawAuditLink = () => {
    prop.csLinkFactory.getLink({
      urlId: 'UC_AA_LAW_DEGREE_AUDIT'
    }).then(function(response) {
      const linkObj = _.get(response, 'data.link');
      setLinkObj(linkObj);
      if (!linkObj) {
        setErrored(true);
      }
    }).catch(function() {
      setErrored(true);
      setIsLoading(false);
    }).finally(function() {
      setIsLoading(false);
    });
  };

  useEffect(() => {
    fetchLawAuditLink();
  }, []);

  return (
    <Widget config={{...widgetConfig}}>
      <p>The Law Degree Audit shows your progress in meeting degree requirements.</p>
      { linkObj && <CampusSolutionsLinkContainer linkObj={linkObj} /> }
    </Widget>
  );
}

angular.module('calcentral.react').component('lawDegreeAudit', react2angular(LawDegreeAudit,  [], ['csLinkFactory']));


