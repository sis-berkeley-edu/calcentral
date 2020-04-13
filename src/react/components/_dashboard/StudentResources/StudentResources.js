import React from 'react';
import PropTypes from 'prop-types';

import CampusSolutionsLinkContainer from '../../CampusSolutionsLink/CampusSolutionsLinkContainer';
import Widget from '../../Widget/Widget';

import '../../../stylesheets/box_model.scss';
import '../../../stylesheets/lists.scss';
import '../../../stylesheets/student_resources.scss';

const propTypes = {
  resources: PropTypes.array.isRequired,
  widgetConfig: PropTypes.object.isRequired,
  analyticsObj: PropTypes.object
};

const renderLinkSectionList = (linkObj, analyticsObj) => {
  // TODO: Temp for Spring 2020 only, should be removed after Spring 2020
  var link = '';
  if (linkObj.urlId == 'UC_CX_GT_SRLATEDROP_ADD')
    link = <span><CampusSolutionsLinkContainer
                    linkObj={{...linkObj}}
                    onClickHandler={() => analyticsObj.sendEvent('Open eform page', 'Click', 'Request Spring 2020 Drop')}
                    />: L&S students may use this form to drop a Spring 2020 class. This form closes May 6, 11:59pm.</span>
  else
    link = <CampusSolutionsLinkContainer linkObj={{...linkObj}}/>

  return (
    <li key={linkObj.urlId}>
      {link}
    </li>
  );
};

const renderLinkSection = (resource, analyticsObj) => {
  return (
    <div className="cc-react-student-resources-list" key={resource.section}>
      <h3 className="cc-react--no-margin">{resource.section}</h3>
      <ul className="cc-react-list-bullets">
        {resource.links.map(linkObj => renderLinkSectionList(linkObj, analyticsObj))}
      </ul>
    </div>
  );
};

const StudentResources = (props) => {
  return (
    <Widget config={{...props.widgetConfig}}>
      <div>
        {props.resources.map(resource => renderLinkSection(resource, props.analyticsObj))}
        <div className="cc-react-student-resources-list">
          <h3 className="cc-react--no-margin">Financial Aid Forms</h3>
          <p className="cc-react--no-margin">Financial aid forms can be found in My Finances under Financial Resources</p>
        </div>
      </div>
    </Widget>
  );
};
StudentResources.propTypes = propTypes;

export default StudentResources;
