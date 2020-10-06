import React from 'react';
import PropTypes from 'prop-types';
import { BrowserRouter as Router, Route, Switch } from 'react-router-dom';
import Helmet from 'react-helmet';

import CalCentralUpdateCard from './CalCentralUpdateCard';

import ServiceAlerts from './ServiceAlerts/ServiceAlerts';
import NewServiceAlert from './ServiceAlerts/NewServiceAlert';
import EditServiceAlert from './ServiceAlerts/EditServiceAlert';

import UserAuths from './UserAuths/UserAuths';
import NewUserAuth from './UserAuths/NewUserAuth';
import EditUserAuth from './UserAuths/EditUserAuth';

import RequireSuperuser from './RequireSuperuser';
import RequireAuthor from './RequireAuthor';

const PageTitle = ({ title }) => (
  <Helmet>
    <title>{title} | CalCentral</title>
  </Helmet>
);

PageTitle.propTypes = { title: PropTypes.string };

// MainContent is a react component that contains the React router, for pages
// whose content does not depend on Angular at all.
//
// To add a new page:
// 1) add a Route, with appropriate matching path under the Switch in MainContent
// 2) add the path to the 'reactPaths' list in Angular's routeConfiguration
export default function MainContent() {
  return (
    <Router>
      <Switch>
        <Route path="/calcentral_update">
          <PageTitle title="CalCentral Update" />
          <CalCentralUpdateCard />
        </Route>

        <Route path="/service_alerts/new">
          <RequireAuthor>
            <PageTitle title="New Service Alert" />
            <NewServiceAlert />
          </RequireAuthor>
        </Route>

        <Route path="/service_alerts/:id/edit">
          <RequireAuthor>
            <PageTitle title="Edit Service Alert" />
            <EditServiceAlert />
          </RequireAuthor>
        </Route>

        <Route path="/service_alerts">
          <RequireAuthor>
            <PageTitle title="Service Alerts" />
            <ServiceAlerts showAll={true} />
          </RequireAuthor>
        </Route>

        <Route path="/user_auths/new">
          <RequireSuperuser>
            <PageTitle title="New User Auth" />
            <NewUserAuth />
          </RequireSuperuser>
        </Route>

        <Route path="/user_auths/:id/edit">
          <RequireSuperuser>
            <PageTitle title="Edit User Auth" />
            <EditUserAuth />
          </RequireSuperuser>
        </Route>

        <Route path="/user_auths">
          <RequireSuperuser>
            <PageTitle title="User Auths" />
            <UserAuths />
          </RequireSuperuser>
        </Route>
      </Switch>
    </Router>
  );
}
