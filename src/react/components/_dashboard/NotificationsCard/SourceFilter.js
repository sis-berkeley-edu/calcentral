import React from 'react';
import PropTypes from 'prop-types';

const SourceFilter = ({ sources, selectedSource, setSelectedSource }) => {
  if (sources.length === 0) {
    return null;
  }

  return (
    <select
      value={selectedSource}
      onChange={e => setSelectedSource(e.target.value)}
      className="cc-inline-select"
    >
      <option value="">All Notifications</option>
      {sources.map(source => (
        <option key={source} value={source}>
          {source}
        </option>
      ))}
    </select>
  );
};

SourceFilter.propTypes = {
  sources: PropTypes.array,
  selectedSource: PropTypes.string,
  setSelectedSource: PropTypes.func,
};

SourceFilter.defaultProps = {
  sources: [],
};

export default SourceFilter;
