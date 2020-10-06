import React, { useEffect, useState } from 'react';
import PropTypes from 'prop-types';

import { react2angular } from 'react2angular';
import { connect } from 'react-redux';

import { fetchAgreements } from 'redux/actions/agreementsActions';
import { fetchChecklistItems } from 'redux/actions/checklistItemsActions';
import { shortDateIfCurrentYear, parseDate } from 'functions/formatDate';

import ReduxProvider from 'components/ReduxProvider';

import useFocus from 'react/useFocus';
import TasksContext from 'react/components/_dashboard/TasksCard/TasksContext';
import Task from 'react/components/_dashboard/TasksCard/Task';
import TaskHeader from 'react/components/_dashboard/TasksCard/TaskHeader';
import TaskTitle from 'react/components/_dashboard/TasksCard/TaskTitle';
import CampusSolutionsIcon from 'react/components/_dashboard/TasksCard/Icons/CampusSolutionsIcon';
import Agreement from 'react/components/_dashboard/TasksCard/CompletedTasks/Agreement';

import {
  TAB_COMPLETE,
  TAB_INCOMPLETE,
} from 'react/components/_dashboard/TasksCard/Switcher';

const NoTasksForAidYear = ({ year }) => (
  <div style={{ padding: `15px` }}>
    You have no tasks for {parseInt(year) - 1}-{year}.
  </div>
);

NoTasksForAidYear.propTypes = {
  year: PropTypes.string,
};

const ToggleSwitch = ({ children, toggleComplete }) => {
  return (
    <button
      className="cc-button-link"
      onClick={toggleComplete}
      style={{ padding: `15px`, width: `100%` }}
    >
      {children}
    </button>
  );
};

ToggleSwitch.propTypes = {
  children: PropTypes.node,
  toggleComplete: PropTypes.func,
};

const isFinancialAidForYear = year => task =>
  task.isFinancialAid && task.aidYear === year;

const FinancialAidTasks = ({
  fetchData,
  loaded,
  year,
  tasks,
  completedTasks,
}) => {
  useEffect(() => fetchData(), []);

  const [node, hasFocus] = useFocus();
  const [selectedItem, setSelectedItem] = useState('');
  const [tab, setTab] = useState(TAB_INCOMPLETE);

  const aidYearTasks = tasks.filter(isFinancialAidForYear(year));

  const beingProcessed = aidYearTasks.filter(task => task.isBeingProcessed);
  const incompleteTasks = aidYearTasks.filter(task => task.isIncomplete);

  const completedForAidYear = completedTasks.filter(
    isFinancialAidForYear(year)
  );

  const incompleteCount = aidYearTasks.length;
  const completedCount = completedForAidYear.length;
  const allTasksCount = incompleteCount + completedCount;

  const toggleComplete = () => {
    setTab(tab === TAB_INCOMPLETE ? TAB_COMPLETE : TAB_INCOMPLETE);
  };

  if (loaded) {
    if (allTasksCount === 0) {
      return <NoTasksForAidYear year={year} />;
    }

    return (
      <div ref={node}>
        <TasksContext.Provider
          value={{ hasFocus, selectedItem, setSelectedItem }}
        >
          {tab === TAB_INCOMPLETE && (
            <>
              {incompleteTasks.map((task, index) => (
                <Task key={index} index={index} task={task} type="incomplete">
                  <TaskHeader task={task}>
                    <CampusSolutionsIcon />
                    <TaskTitle
                      title={task.title}
                      subtitle={`${task.status} ${shortDateIfCurrentYear(
                        parseDate(task.assignedDate)
                      )}`}
                    />
                  </TaskHeader>
                </Task>
              ))}

              {beingProcessed.map((task, index) => (
                <Task
                  key={index}
                  index={index}
                  task={task}
                  type="beingProcessed"
                >
                  <TaskHeader task={task}>
                    <CampusSolutionsIcon />
                    <TaskTitle
                      title={task.title}
                      subtitle={`${task.status} ${shortDateIfCurrentYear(
                        parseDate(task.statusDate)
                      )}`}
                    />
                  </TaskHeader>
                </Task>
              ))}

              <div>
                <ToggleSwitch toggleComplete={toggleComplete}>
                  Show Completed ({completedCount})
                </ToggleSwitch>
              </div>
            </>
          )}

          {tab === TAB_COMPLETE && (
            <>
              {completedForAidYear.map((task, index) => {
                if (task.type === 'CompletedAgreement') {
                  return (
                    <Agreement key={index} index={index} agreement={task} />
                  );
                }

                return (
                  <Task key={index} index={index} task={task} type="incomplete">
                    <TaskHeader task={task}>
                      <CampusSolutionsIcon />
                      <TaskTitle
                        title={task.title}
                        subtitle={`Completed ${shortDateIfCurrentYear(
                          parseDate(task.completedDate)
                        )}`}
                      />
                    </TaskHeader>
                  </Task>
                );
              })}

              <div>
                <ToggleSwitch toggleComplete={toggleComplete}>
                  Show Uncompleted ({incompleteCount})
                </ToggleSwitch>
              </div>
            </>
          )}
        </TasksContext.Provider>
      </div>
    );
  }

  return null;
};

FinancialAidTasks.propTypes = {
  fetchData: PropTypes.func,
  loaded: PropTypes.bool,
  tasks: PropTypes.array,
  completedTasks: PropTypes.array,
  year: PropTypes.string,
};

const mapStateToProps = ({ myAgreements, myChecklistItems }) => {
  const {
    incompleteAgreements = [],
    completedAgreements = [],
    loaded: agreementLoaded,
  } = myAgreements;
  const {
    incompleteItems = [],
    completedItems = [],
    loaded: checklistLoaded,
  } = myChecklistItems;

  return {
    loaded: agreementLoaded && checklistLoaded,
    tasks: [...incompleteAgreements, ...incompleteItems],
    completedTasks: [...completedAgreements, ...completedItems],
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

const ConnectedFinancialAidTasks = connect(
  mapStateToProps,
  mapDispatchToProps
)(FinancialAidTasks);

const FinancialAidTasksContainer = ({ year }) => (
  <ReduxProvider>
    <ConnectedFinancialAidTasks year={year} />
  </ReduxProvider>
);

FinancialAidTasksContainer.propTypes = {
  year: PropTypes.string,
};

angular
  .module('calcentral.react')
  .component('financialAidTasks', react2angular(FinancialAidTasksContainer));
