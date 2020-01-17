import React from 'react';
import PropTypes from 'prop-types';

import { shortDateIfCurrentYear, parseDate } from 'functions/formatDate';

import CampusSolutionsIcon from '../Icons/CampusSolutionsIcon';

import Task from '../Task';
import TaskHeader from '../TaskHeader';
import TaskTitle from '../TaskTitle';
import TasksContext from '../TasksContext';

function CompletedTask({ task, index }) {
  return (
    <TasksContext.Consumer>
      {() => {
        const { title } = task;
        const subtitle = `Completed ${shortDateIfCurrentYear(
          parseDate(task.completedDate)
        )}`;

        return (
          <Task index={index} task={task} type="completed">
            <TaskHeader task={task}>
              <CampusSolutionsIcon />
              <TaskTitle title={title} subtitle={subtitle} />
            </TaskHeader>
          </Task>
        );
      }}
    </TasksContext.Consumer>
  );
}

CompletedTask.propTypes = {
  task: PropTypes.object.isRequired,
  index: PropTypes.number,
};

export default CompletedTask;
