import React from 'react';

class Spinner extends React.Component {
  render() {
    return (
      <div aria-live="polite" className="cc-spinner"></div>
    );
  }
}

export default Spinner;
