const labels = {
  assignment: 'New Assignments',
  discussion: 'New Discussions',
  announcement: 'New Announcements',
  webconference: 'New Conferences',
  webcast: 'New Course Captures',
  gradeposting: 'Graded Assignments',
};

const Notification = {
  linkText: notification => {
    if (notification.type === 'webcast') {
      return 'View Course Capture';
    } else {
      return 'View in bCourses';
    }
  },

  labelForType: type => {
    return labels[type] || 'unknown';
  },
};

export default Notification;
