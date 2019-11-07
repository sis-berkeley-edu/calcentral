import React, { Fragment } from 'react';
import PropTypes from 'prop-types';

import { connect } from 'react-redux';

import {
  groupByAidYear,
  checklistCategoryTitles,
  groupByCategory,
} from '../tasks.module';

import Category from '../Category';
import Tasks from '../Tasks';
import Agreement from './Agreement';

import SectionHeader from '../SectionHeader';
import CompletedTask from './CompletedTask';
import CategoryTitle from './CategoryTitle';

// Completed tasks are organized by "Category"
// The financial aid category is broken up by Aid Year, further into groups of
// "incomplete" and "being processed".
const ByCategory = ({ categories }) => {
  return (
    <Fragment>
      {categories.map(category => {
        if (category.key === 'financialAid') {
          return (
            <Category key={category.key}>
              {category.aidYears.map(aidYear => {
                return (
                  <div key={aidYear.year}>
                    <CategoryTitle>
                      Financial Aid Tasks{' '}
                      <span>
                        {aidYear.year - 1}-{aidYear.year}
                      </span>
                    </CategoryTitle>

                    <SectionHeader columns={['Title']} />

                    <Tasks>
                      {aidYear.tasks.map((item, index) => {
                        return (
                          <CompletedTask
                            key={index}
                            index={index}
                            task={item}
                          />
                        );
                      })}
                    </Tasks>
                  </div>
                );
              })}
            </Category>
          );
        } else if (category.key === 'agreements' && category.tasks.length > 0) {
          return (
            <Category key={category.key}>
              <CategoryTitle>Agreements and Opt-ins</CategoryTitle>

              <Tasks>
                {category.tasks.map((task, index) => (
                  <Agreement key={index} index={index} agreement={task} />
                ))}
              </Tasks>
            </Category>
          );
        } else if (category.tasks.length > 0) {
          return (
            <Category key={category.key}>
              <CategoryTitle>{category.title}</CategoryTitle>

              <Tasks>
                {category.tasks.map((task, index) => (
                  <CompletedTask key={index} index={index} task={task} />
                ))}
              </Tasks>
            </Category>
          );
        } else {
          return null;
        }
      })}
    </Fragment>
  );
};

ByCategory.propTypes = {
  categories: PropTypes.array,
};

// The API returns a list of completed items. In the UI we want to sort them by
// their properties. By category, then by completion date. Financial aid tasks
// are broken up by aid year with an appropriate label present if there is more
// than one relevant aid year.
const mapStateToProps = ({
  myChecklistItems: { completedItems = [] },
  myAgreements: { completedAgreements = [] },
}) => {
  const groupedByCategory = completedItems.reduce(groupByCategory, {});
  const orderedCategories = checklistCategoryTitles.map(category => {
    const items = groupedByCategory[category.key] || [];
    const sortedItems = items.reverse().sort((a, b) => {
      return a.completedDate < b.completedDate ? 1 : -1;
    });

    if (category.key === 'financialAid') {
      const byAidYear = groupByAidYear(items);
      const aidYears = Object.keys(byAidYear)
        .sort((a, b) => b - a)
        .map(year => ({ year, tasks: byAidYear[year] }));

      return {
        ...category,
        aidYears,
      };
    } else if (category.key === 'agreements') {
      return {
        ...category,
        tasks: completedAgreements,
      };
    } else {
      return {
        ...category,
        tasks: sortedItems || [],
      };
    }
  });

  return {
    categories: orderedCategories,
  };
};

export default connect(mapStateToProps)(ByCategory);
