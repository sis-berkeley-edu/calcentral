import React from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';
import VisuallyHidden from '../../VisuallyHidden';
import format from 'date-fns/format';
import { googleAnalytics } from 'functions/googleAnalytics';
import './UpNextItem.scss';
import '../../../stylesheets/useful.scss';
import '../../../stylesheets/buttons.scss';

const propTypes = {
  applicationLayer: PropTypes.string,
  expandedItemIndex: PropTypes.number,
  item: PropTypes.object.isRequired,
  index: PropTypes.number.isRequired,
  setExpandedItemIndex: PropTypes.func,
};

const UpNextItem = ({
  applicationLayer,
  expandedItemIndex,
  index,
  item,
  setExpandedItemIndex,
}) => {
  const ga = new googleAnalytics(applicationLayer);

  const toggleItem = () => {
    setExpandedItemIndex((index == expandedItemIndex) ? null : index)
    ga.sendEvent('Detailed view', showItem ? 'Open' : 'Close', 'Up Next');
  };

  const onEnterExpandItem = event => {
    if (event.keyCode === 13) {
      toggleItem(index, expandedItemIndex, setExpandedItemIndex);
    }
  };

  const trackHangoutLink = event => {
    event.stopPropagation();
    ga.trackExternalLink('Up Next', 'Hangout', item.hangoutLink);
  };

  const trackBcalLink = event => {
    event.stopPropagation();
    ga.trackExternalLink('Up Next', 'bCal', item.htmlLink);
  };

  const showItem = index == expandedItemIndex;

  if (item) {
    return (
      <li className="UpNextItem ellipsis">
        <VisuallyHidden>
          Show {showItem ? 'less' : 'more'} information about {item.summary}
        </VisuallyHidden>
        <div
          className={
            'list-hover ' + (showItem ? 'list-hover-opened list-selected' : '')
          }
          tabIndex="0"
          onClick={() => toggleItem(index, expandedItemIndex, setExpandedItemIndex)}
          onKeyDown={e => onEnterExpandItem(e)}
        >
          <div className="date-list-time list-column-left">
            {item.isAllDay && (
              <div className="date-list-time-all-day text-light">
                all
                <br />
                day
              </div>
            )}
            {!item.isAllDay && (
              <div className="date-list-time left">
                <strong>{format(item.start.epoch * 1000, 'h:mm')}</strong>
                <br />
                <span className="text-light">
                  {format(item.start.epoch * 1000, 'a').toUpperCase()}
                </span>
              </div>
            )}
          </div>
          <div className="date-list-summary">
            <strong className="ellipsis">{item.summary}</strong>
            {item.location && (
              <div className="ellipsis datelist-location text-light">
                {item.location}
              </div>
            )}
          </div>
          {showItem && (
            <div className="date-item-more">
              <div className="clearfix-container">
                {item.isAllDay && (
                  <p>{format(item.start.epoch * 1000, 'EEE, MMMM d')}</p>
                )}
                {!item.isAllDay && (
                  <div className="date-list-time-range">
                    <div className="header">Start:</div>
                    <div>
                      {format(
                        item.start.epoch * 1000,
                        'M/d/yy h:mm a'
                      ).toLowerCase()}
                    </div>
                    <div className="header">End:</div>
                    <div>
                      {format(
                        item.end.epoch * 1000,
                        'M/d/yy h:mm a'
                      ).toLowerCase()}
                    </div>
                  </div>
                )}
              </div>
              {item.hangoutLink && (
                <div className="hangout">
                  <i className="fa fa-video-camera"></i>{' '}
                  <a
                    href={item.hangoutLink}
                    onClick={e => trackHangoutLink(e)}
                    target="_blank"
                    rel="noopener noreferrer"
                  >
                    Join Hangout
                  </a>
                </div>
              )}
              {item.organizer && (
                <div>
                  <span className="header">Organizer:</span>
                  <p className="indent">{item.organizer}</p>
                </div>
              )}
              {item.attendees && item.attendees.length > 0 && (
                <div>
                  <span className="header">Invitees:</span>
                  <ul className="list-attendees indent">
                    {item.attendees.map((attendee, index) => (
                      <li className="ellipsis" key={index}>
                        {attendee}
                      </li>
                    ))}
                  </ul>
                </div>
              )}
              {item.htmlLink && (
                <div>
                  <a
                    className="cc-react-button button"
                    target="_blank"
                    rel="noopener noreferrer"
                    href={item.htmlLink}
                    onClick={e => trackBcalLink(e)}
                  >
                    View in bCal
                  </a>
                </div>
              )}
            </div>
          )}
        </div>
      </li>
    );
  } else {
    return null;
  }
};

UpNextItem.propTypes = propTypes;

const mapStateToProps = ({ config }) => {
  const { applicationLayer = 'development' } = config;

  return {
    applicationLayer,
  };
};

export default connect(mapStateToProps)(UpNextItem);
