import React from 'react';
import PropTypes from 'prop-types';

import TasksContext from './TasksContext';
import TaskDetail from './TaskDetail';

import taskStyles from './Task.module.scss';
import wrapperStyles from './TaskWrapper.module.scss';

const ignoredChecklistStatusCodes = new Set(['O', 'T', 'X']);

import { keyForTask } from './tasks.module';

const Task = ({ task, index, children, type, isOverdue, hasDetail }) => {
  if (ignoredChecklistStatusCodes.has(task.status_code)) {
    return null;
  }

  const taskKey = keyForTask(task, index, type);

  const taskClassNames = [
    taskStyles.task,
    task.isBeingProcessed ? taskStyles.noActionNecessary : null,
  ].join(' ');

  return (
    <TasksContext.Consumer>
      {({ hasFocus, selectedItem, setSelectedItem }) => {
        const isSelected = taskKey === selectedItem;

        const clickTask = _event => {
          if (isSelected) {
            setSelectedItem('');
          } else {
            setSelectedItem(keyForTask(task, index, type));
          }
        };

        const overdueClass = isOverdue ? wrapperStyles.overdue : null;

        const wrapperClassNames = [
          wrapperStyles.taskWrapper,
          hasDetail ? wrapperStyles.hasDetail : null,
          isSelected ? wrapperStyles.selected : wrapperStyles.notSelected,
          hasFocus ? wrapperStyles.isFocused : wrapperStyles.notFocused,
          overdueClass,
        ].join(' ');

        return (
          <div className={wrapperClassNames}>
            <div className={taskClassNames} onClick={clickTask}>
              {children}
              {hasDetail && isSelected && <TaskDetail task={task} />}
            </div>
          </div>
        );
      }}
    </TasksContext.Consumer>
  );
};

Task.propTypes = {
  task: PropTypes.object,
  index: PropTypes.number,
  children: PropTypes.node,
  type: PropTypes.string,
  isOverdue: PropTypes.bool,
  hasDetail: PropTypes.bool,
};

Task.defaultProps = {
  hasDetail: true,
};

export default Task;
