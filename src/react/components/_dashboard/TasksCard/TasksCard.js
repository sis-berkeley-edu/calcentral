import React, { useEffect, useState } from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';
import { react2angular } from 'react2angular';

import ReduxProvider from 'react/components/ReduxProvider';

import useFocus from 'react/useFocus';
import Card from 'react/components/Card';
import Spinner from 'react/components/Spinner';

import styles from './TasksCard.module.scss';

import CompletedTasks from './CompletedTasks/ByCategory';
import IncompleteTasks from './IncompleteTasks/ByCategory';

import Switcher from './Switcher';
import TasksContext from './TasksContext';

import { TAB_COMPLETE, TAB_INCOMPLETE } from './Switcher';

const TasksCard = ({ fetchData, loaded }) => {
  useEffect(() => {
    fetchData();
  }, []);

  // useFocus is used to track whether the user is interacting with the card or
  // has clicked somewhere else on the page
  const [node, hasFocus] = useFocus();

  const [tab, setTab] = useState(TAB_INCOMPLETE);
  const [selectedItem, setSelectedItem] = useState('');

  return (
    <Card title="Tasks Card" node={node} className={styles.tasksCard}>
      {loaded ? (
        <TasksContext.Provider
          value={{ hasFocus, selectedItem, setSelectedItem }}
        >
          <Switcher tab={tab} setTab={setTab} />

          <div className={styles.fullWidthContainer}>
            {tab === TAB_INCOMPLETE && <IncompleteTasks />}
            {tab === TAB_COMPLETE && <CompletedTasks />}
          </div>
        </TasksContext.Provider>
      ) : (
        <Spinner />
      )}
    </Card>
  );
};

TasksCard.propTypes = {
  fetchData: PropTypes.func.isRequired,
  loaded: PropTypes.bool,
  incompleteCount: PropTypes.number,
  completeCount: PropTypes.number,
};

import { fetchAgreements } from 'redux/actions/agreementsActions';
import { fetchChecklistItems } from 'redux/actions/checklistItemsActions';

const mapStateToProps = ({
  myAgreements: {
    activeAgreements = [],
    completedAgreements = [],
    loaded: agreementsLoaded,
  },
  myChecklistItems: {
    completedItems = [],
    incompleteItems = [],
    loaded: checklistLoaded,
  },
}) => {
  const loaded = agreementsLoaded && checklistLoaded;

  return {
    activeAgreements,
    completedAgreements,
    completedItems,
    incompleteItems,
    loaded,
  };
};

const mapDispatchToProps = dispatch => {
  return {
    fetchData: () => {
      dispatch(fetchAgreements());
      dispatch(fetchChecklistItems());
    },
  };
};

const ConnnectedTasksCard = connect(
  mapStateToProps,
  mapDispatchToProps
)(TasksCard);

const TasksCardContainer = () => (
  <ReduxProvider>
    <ConnnectedTasksCard />
  </ReduxProvider>
);

angular
  .module('calcentral.react')
  .component('tasksCard', react2angular(TasksCardContainer));
