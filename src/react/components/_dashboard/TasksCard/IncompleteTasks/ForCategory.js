import React, { useState } from 'react';
import PropTypes from 'prop-types';

import { shortDateIfCurrentYear, parseDate } from 'functions/formatDate';

import Category from '../Category';
import CategoryHeader from './CategoryHeader';
import CategorySection from './CategorySection';

import Task from '../Task';
import TaskHeader from '../TaskHeader';
import TaskTitle from '../TaskTitle';
import CampusSolutionsIcon from '../Icons/CampusSolutionsIcon';
import DueDate from './DueDate';

const CategoryItem = ({ task, index }) => {
  return (
    <Task index={index} task={task} type="">
      <TaskHeader task={task}>
        <CampusSolutionsIcon />
        <TaskTitle
          title={task.title}
          subtitle={`${task.status} ${shortDateIfCurrentYear(
            parseDate(task.statusDate)
          )}`}
        />

        {task.dueDate && <DueDate date={task.dueDate} />}
      </TaskHeader>
    </Task>
  );
};
CategoryItem.propTypes = {
  task: PropTypes.shape({
    dueDate: PropTypes.string,
    status: PropTypes.string,
    statusDate: PropTypes.string,
    title: PropTypes.string,
  }),
  index: PropTypes.number,
};

const ForCategory = ({ category }) => {
  const [expanded, setExpanded] = useState(false);
  const tasks = category.tasks;

  const itemsIncomplete = tasks.filter(item => item.isIncomplete);
  const itemsBeingProcessed = tasks.filter(item => item.isBeingProcessed);
  const incompleteCount = itemsIncomplete.length;
  const inProcessCount = itemsBeingProcessed.length;

  return (
    <Category withBottomBorder={true}>
      <CategoryHeader
        tasks={category.tasks}
        title={category.title}
        expanded={expanded}
        setExpanded={setExpanded}
        incompleteCount={incompleteCount}
        inProcessCount={inProcessCount}
      />

      {expanded && (
        <>
          {itemsIncomplete > 0 && (
            <CategorySection items={tasks}>
              {tasks.map((task, index) => (
                <CategoryItem key={index} task={task} index={index} />
              ))}
            </CategorySection>
          )}

          {inProcessCount > 0 && (
            <CategorySection
              items={itemsBeingProcessed}
              categorySection="beingProcessed"
              columns={['Title']}
            >
              {tasks.map((task, index) => (
                <CategoryItem key={index} task={task} index={index} />
              ))}
            </CategorySection>
          )}
        </>
      )}
    </Category>
  );
};

ForCategory.propTypes = {
  category: PropTypes.object,
};

export default ForCategory;
