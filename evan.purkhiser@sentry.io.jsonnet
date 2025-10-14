local lib = import 'gmailctl.libsonnet';

local labels = [{ name: l } for l in [
  'Airbase',
  'GitHub',
  'Interview: Reminder',
  'Interview: Scorecards',
  'JIRA: Generic Notifications',
  'Meeting Recordings',
  'Namely',
  'New Hire Mondays',
  'POPS Newsletter',
  'PagerDuty',
  'Product Updates',
  'Sentry Alerts',
  'Shipped',
  'Show and Tell Thursday',
  'TSCs',
  'Weekly Reports',
  'Weekly SLO',
]];

local airbase = {
  filter: {
    from: 'hello@airbase.io',
  },
  actions: {
    labels: ['Airbase'],
  },
};

local sentryWeeklyReport = {
  filter: {
    and: [
      {
        subject: 'Weekly Report for',
      },
      {
        or: [
          { from: 'noreply@md.getsentry.com' },
          { from: 'sentry@my.sentry.io' },
        ],
      },
    ],
  },
  actions: {
    archive: true,
    markRead: true,
    labels: ['Weekly Reports'],
  },
};

local sentryAlerts = {
  filter: {
    and: [
      {
        or: [
          { list: 'sentry.sentry.getsentry.com' }
          { list: 'javascript.sentry.getsentry.com' },
        ],
      },
      {
        not: { subject: 'Deployed' },
      },
    ],
  },
  actions: {
    archive: true,
    markRead: true,
    labels: ['Sentry Alerts'],
  },
};

local githubNotifications = {
  filter: {
    list: 'getsentry.github.com',
  },
  actions: {
    labels: ['GitHub'],
  },
};


local greenhouseScoreCards = {
  filter: {
    subject: 'Action Required ASAP: Fill out your scorecard',
  },
  actions: {
    archive: true,
    markRead: true,
    labels: ['Interview: Scorecards'],
  },
};

local greenhouseReminders = {
  filter: {
    and: [
      { from: 'no-reply@greenhouse.io' },
      { subject: 'REMINDER: You have' },
    ],
  },
  actions: {
    archive: true,
    markRead: true,
    labels: ['Interview: Reminder'],
  },
};

local meetRecordings = {
  filter: {
    or: [
      { from: 'meet-transcriptions-noreply@google.com' },
      { from: 'meet-recordings-noreply@google.com' },
      { from: 'meetings-noreply@google.com' },
    ],
  },
  actions: {
    archive: true,
    labels: ['Meeting Recordings'],
  },
};

local namely = {
  filter: {
    and: [
      { from: 'no-reply@namely.com' },
      {
        or: [
          { subject: 'Time off request approved' },
        ],
      },
    ],
  },
  actions: {
    archive: true,
    markRead: true,
    labels: ['Namely'],
  },
};

local jiraNotifications = {
  filter: {
    and: [
      { from: 'jira@getsentry.atlassian.net' },
      { subject: 'Subscription: Open Customer Issues assigned to you' },
    ],
  },
  actions: {
    archive: true,
    markRead: true,
    markSpam: false,
    labels: ['JIRA: Generic Notifications'],
  },
};

local newSignIns = {
  filter: {
    or: [
      { subject: 'new sign-in' },
      { subject: 'new sign-on' },
    ],
  },
  actions: {
    archive: true,
    markRead: true,
  },
};

// Internal sentry emails

local newHireMondays = {
  filter: {
    subject: 'New Hire Monday',
  },
  actions: {
    archive: true,
    labels: ['New Hire Mondays'],
  },
};

local shipped = {
  filter: {
    to: 'shipped@sentry.io',
  },
  actions: {
    archive: true,
    labels: ['Shipped'],
  },
};

local showAndTell = {
  filter: {
    subject: 'Show & Tell Thursday',
  },
  actions: {
    archive: true,
    markRead: true,
    labels: ['Show and Tell Thursday'],
  },
};

local productUpdates = {
  filter: {
    to: 'product-updates@sentry.io',
  },
  actions: {
    archive: true,
    labels: ['Product Updates'],
  },
};

local popsNewsletter = {
  filter: {
    subject: 'Read The Sentaur Scoop',
  },
  actions: {
    archive: true,
    labels: ['POPS Newsletter'],
  },
};

local weeklySLOs = {
  filter: {
    subject: 'Weekly SLO Report',
  },
  actions: {
    archive: true,
    labels: ['Weekly SLO'],
  },
};

local technicalSteeringCommittees = {
  filter: {
    or: [
      { subject: 'TSC notes' },
      { subject: 'Backend TSC' },
    ],
  },
  actions: {
    archive: true,
    labels: ['TSCs'],
  },
};

local pagerduty = {
  filter: {
    subject: '[PagerDuty] Evan Purkhiser',
  },
  actions: {
    archive: true,
    labels: ['PagerDuty'],
  },
};

local desana = {
  filter: {
    from: 'bookings@desana.io',
  },
  actions: {
    delete: true,
  },
};

local rules = [
  airbase,
  sentryWeeklyReport,
  sentryAlerts,
  githubNotifications,
  greenhouseScoreCards,
  greenhouseReminders,
  meetRecordings,
  namely,
  jiraNotifications,
  newSignIns,

  newHireMondays,
  shipped,
  showAndTell,
  productUpdates,
  popsNewsletter,
  weeklySLOs,
  technicalSteeringCommittees,
  pagerduty,
  desana,
];

{
  version: 'v1alpha3',
  labels: labels,
  rules: rules,
}
