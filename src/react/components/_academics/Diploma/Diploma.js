import React, { useEffect, useState } from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';
import ReduxProvider from 'React/components/ReduxProvider';
import { fetchAcademicsDiploma } from 'Redux/actions/academics/diplomaActions';

import './Diploma.scss';
import 'icons/info.svg';

const propTypes = {
  dispatch: PropTypes.func.isRequired,
  diplomaEligible: PropTypes.bool,
  diplomaReady: PropTypes.bool,
  ssoUrl: PropTypes.string,
  paperDiplomaMessage: PropTypes.shape({
    messageText: PropTypes.string,
    descrlong: PropTypes.string
  }),
  electronicDiplomaHelpMessage: PropTypes.shape({
    messageText: PropTypes.string,
    descrlong: PropTypes.string
  }),
  electronicDiplomaNoticeMessage: PropTypes.shape({
    messageText: PropTypes.string,
    descrlong: PropTypes.string
  }),
  electronicDiplomaReadyMessage: PropTypes.shape({
    messageText: PropTypes.string,
    descrlong: PropTypes.string
  })
};

const Diploma = ({
  dispatch,
  diplomaEligible,
  diplomaReady,
  electronicDiplomaHelpMessage,
  electronicDiplomaNoticeMessage,
  electronicDiplomaReadyMessage,
  paperDiplomaMessage,
  ssoUrl
}) => {
  useEffect(() => {
    dispatch(fetchAcademicsDiploma());
  }, []);

  const [electronicDiplomaExpanded, setElectronicDiplomaExpanded] = useState(false);

  if (diplomaEligible) {
    return (
      <div className="cc-section-block">
        <div className="content-entry">
          <div
            className="header-text"
            dangerouslySetInnerHTML={{
            __html: paperDiplomaMessage.messageText,
          }} />
          <div dangerouslySetInnerHTML={{
            __html: paperDiplomaMessage.descrlong,
          }} />
        </div>
        <div className="content-entry">
          <div className="header-text">
            {!diplomaReady &&
              <span dangerouslySetInnerHTML={{
                __html: electronicDiplomaNoticeMessage.messageText,
              }} />
            }
            {diplomaReady && ssoUrl &&
              <span dangerouslySetInnerHTML={{
                __html: electronicDiplomaReadyMessage.messageText,
              }} />
            }
            <a
              onClick={() => setElectronicDiplomaExpanded(!electronicDiplomaExpanded)}
              aria-label="What is an electronic diploma?"
              role="button"
              tabIndex="0"
              aria-expanded={electronicDiplomaExpanded}
              className="icon-info button-link"
              style={{marginRight: '4px'}}
            ></a>
          </div>
          {electronicDiplomaExpanded &&
            <div
              className="electronic-diploma-info"
              dangerouslySetInnerHTML={{
                __html: electronicDiplomaHelpMessage.descrlong,
              }}
            />
          }
          {!diplomaReady &&
            <div dangerouslySetInnerHTML={{
              __html: electronicDiplomaNoticeMessage.descrlong,
            }} />
          }
          {diplomaReady && ssoUrl &&
            <div>
              <div dangerouslySetInnerHTML={{
                __html: electronicDiplomaReadyMessage.descrlong,
              }} />
              <div className="download-button-container">
                <a className="download-button" href={ssoUrl} target="_blank" rel="noopener noreferrer">Proceed to Download</a>
              </div>
            </div>
          }
        </div>
      </div>
    );
  } else {
    return null;
  }
};

Diploma.propTypes = propTypes;

const mapStateToProps = ({
  academics: {
    diploma: {
      diplomaEligible,
      diplomaReady,
      electronicDiplomaHelpMessage,
      electronicDiplomaNoticeMessage,
      electronicDiplomaReadyMessage,
      paperDiplomaMessage,
      ssoUrl,
    }
  }
}) => {
  return {
    diplomaEligible,
    diplomaReady,
    electronicDiplomaHelpMessage,
    electronicDiplomaNoticeMessage,
    electronicDiplomaReadyMessage,
    paperDiplomaMessage,
    ssoUrl,
  };
};

const ConnectedDiploma = connect(mapStateToProps)(
  Diploma
);

const DiplomaContainer = () => {
  return (
    <ReduxProvider>
      <ConnectedDiploma />
    </ReduxProvider>
  );
};

export default DiplomaContainer;
