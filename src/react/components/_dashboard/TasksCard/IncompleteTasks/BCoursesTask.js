import React from 'react';
import PropTypes from 'prop-types';

import { shortDateIfCurrentYear, parseDate } from 'functions/formatDate';
import { format, parseISO } from 'date-fns';

import Task from '../Task';
import TaskHeader from '../TaskHeader';
import TaskTitle from '../TaskTitle';

import CanvasIcon from '../Icons/CanvasIcon';

const CourseCode = ({ courseCode }) => {
  return (
    <span
      style={{ color: `#999`, fontSize: `11px`, textTransform: `uppercase` }}
    >
      {courseCode}
    </span>
  );
};

CourseCode.propTypes = {
  courseCode: PropTypes.string,
};

const BCoursesTask = ({ task, index }) => {
  return (
    <Task task={task} index={index} type="bCourses">
      <TaskHeader task={task}>
        <CanvasIcon />
        <TaskTitle
          task={task}
          title={task.name}
          subtitle={<CourseCode courseCode={task.courseCode} />}
        />
        {task.dueTime && (
          <div style={{ textAlign: `right` }}>
            <div>Due {shortDateIfCurrentYear(parseDate(task.dueDate))}</div>
            <div
              style={{ fontSize: `12px`, fontWeight: `700`, marginTop: `-2px` }}
            >
              {format(parseISO(task.dueTime), 'h a')}
            </div>
          </div>
        )}
      </TaskHeader>
    </Task>
  );
};

BCoursesTask.propTypes = {
  index: PropTypes.number,
  task: PropTypes.shape({
    name: PropTypes.string,
    type: PropTypes.type,
    dueDate: PropTypes.string,
    dueTime: PropTypes.string,
    courseCode: PropTypes.string,
  }).isRequired,
};

export default BCoursesTask;
