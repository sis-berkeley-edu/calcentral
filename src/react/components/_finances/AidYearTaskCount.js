import React, { useEffect } from 'react';
import PropTypes from 'prop-types';

import { react2angular } from 'react2angular';
import { connect } from 'react-redux';

import { fetchAgreements } from 'redux/actions/agreementsActions';
import { fetchChecklistItems } from 'redux/actions/checklistItemsActions';

import ReduxProvider from 'react/components/ReduxProvider';

const AidYearTasksCount = ({ currentUrl, fetchData, loaded, tasks, year }) => {
  useEffect(() => fetchData(), []);

  // If the path matches /finances$ then the component should link to the detail
  // page for the financial aid year (e.g., /finances/finaid/2020)
  //
  // If already on the detail page, there's no reason to include a link
  const onYearDetailPage = !currentUrl.match(/finances$/);

  if (loaded) {
    const tasksForYear = tasks.filter(task => task.aidYear === year);

    if (tasksForYear.length === 0) {
      return null;
    }

    if (onYearDetailPage) {
      return (
        <div>
          <i className="fa fa-bell cc-icon cc-non-anchored-link cc-icon-gold"></i>
          {tasksForYear.length} incomplete financial aid tasks
        </div>
      );
    }

    return (
      <div>
        <a href={`finances/finaid/${year}`}>
          <i className="fa fa-bell cc-icon cc-non-anchored-link"></i>
          {tasksForYear.length} incomplete
        </a>{' '}
        financial aid tasks
      </div>
    );
  }

  return null;
};

AidYearTasksCount.propTypes = {
  currentUrl: PropTypes.string,
  fetchData: PropTypes.func,
  loaded: PropTypes.bool,
  tasks: PropTypes.array,
  year: PropTypes.string,
};

const mapStateToProps = ({
  currentRoute: { url: currentUrl },
  myAgreements: { incompleteAgreements = [], loaded: agreementLoaded },
  myChecklistItems: { incompleteItems = [], loaded: checklistLoaded },
}) => {
  const tasks = [...incompleteAgreements, ...incompleteItems].filter(task => {
    return task.displayCategory === 'financialAid' && !task.isBeingProcessed;
  });

  const loaded = agreementLoaded && checklistLoaded;

  return { currentUrl, loaded, tasks };
};

const mapDispatchToProps = dispatch => {
  return {
    fetchData: () => {
      dispatch(fetchAgreements());
      dispatch(fetchChecklistItems());
    },
  };
};

const ConnectedAidYearTasksCount = connect(
  mapStateToProps,
  mapDispatchToProps
)(AidYearTasksCount);

const AidYearTasksCountContainer = ({ year }) => (
  <ReduxProvider>
    <ConnectedAidYearTasksCount year={year} />
  </ReduxProvider>
);

AidYearTasksCountContainer.propTypes = {
  year: PropTypes.string,
};

angular
  .module('calcentral.react')
  .component('aidYearTaskCount', react2angular(AidYearTasksCountContainer));
