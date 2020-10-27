import React, { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import Card from 'react/components/Card';
import Pagination from 'components/Pagination';
import { LargeSpacer } from 'components/VerticalSpacers';
import UserAuthsTable from './UserAuthsTable';

export default function UserAuths() {
  const [userAuths, setUserAuths] = useState([]);
  const [currentPage, setCurrentPage] = useState(1);
  const [loadState, setLoadState] = useState('pending');
  const [totalPages, setTotalPages] = useState();

  useEffect(() => {
    fetch(`/api/user_auths?page=${currentPage}`)
      .then(response => response.json())
      .then(data => {
        setUserAuths(data.user_auths);
        setCurrentPage(data.current_page);
        setTotalPages(data.total_pages);
        setLoadState('success');
      });
  }, [currentPage]);

  return (
    <Card
      title="User Auths"
      loading={loadState === 'pending'}
      secondaryContent={<Link to="/user_auths/new">New User Auth</Link>}
    >
      <LargeSpacer />
      <UserAuthsTable userAuths={userAuths} />
      <LargeSpacer />
      <Pagination
        currentPage={currentPage}
        setCurrentPage={setCurrentPage}
        totalPages={totalPages}
        loadState={loadState}
        setLoadState={setLoadState}
      />
    </Card>
  );
}
