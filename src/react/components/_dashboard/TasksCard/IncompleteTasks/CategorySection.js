import React from 'react';
import PropTypes from 'prop-types';

import { shortDateIfCurrentYear, parseDate } from 'functions/formatDate';

import CampusSolutionsIcon from '../Icons/CampusSolutionsIcon';
import SectionHeader from '../SectionHeader';

import Task from '../Task';
import TaskHeader from '../TaskHeader';
import TaskTitle from '../TaskTitle';

import styles from './CategorySection.module.scss';
import DueDate from './DueDate';

const CategorySection = ({ categorySection, items, columns, children }) => {
  return (
    <div className={styles.categorySection}>
      {categorySection === 'beingProcessed' && (
        <div className={styles.beingProcessedDivider}>
          <span>Being processed</span>{' '}
          <span className={styles.countBadge}>{items.length}</span>
        </div>
      )}

      <SectionHeader
        columns={columns}
        leftBorder={categorySection === 'beingProcessed'}
      />

      <div className={styles.tasks}>
        {children
          ? children
          : items.map((task, index) => (
              <Task
                key={index}
                index={index}
                task={task}
                type={categorySection}
              >
                <TaskHeader task={task}>
                  <CampusSolutionsIcon />
                  <TaskTitle
                    title={task.title}
                    subtitle={`Assigned ${shortDateIfCurrentYear(
                      parseDate(task.assignedDate)
                    )}`}
                  />
                  {task.dueDate && <DueDate date={task.dueDate} />}
                </TaskHeader>
              </Task>
            ))}
      </div>
    </div>
  );
};

CategorySection.propTypes = {
  items: PropTypes.array,
  children: PropTypes.node,
  columns: PropTypes.array,
  categorySection: PropTypes.string,
};

CategorySection.defaultProps = {
  columns: [],
};

export default CategorySection;
