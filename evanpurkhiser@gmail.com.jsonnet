local lib = import 'gmailctl.libsonnet';

local labels = [{ name: l } for l in [
  'Brand / Theory',
  'Music / Bandcamp',
  'Music / Promos',
  'Newsletter / Reading',
  'Newsletter / SF',
  'Newsletter / Shopping',
  'Recruiters',
  'Rent Payments',
  'Rideshare / Lyft',
  'Rideshare / Uber',
  'Sentry Options',
  'Shipping Notification',
  'Venmo / Cashout',
  'Venmo / Paid',
]];

// Attempt to filter out recruiter emails
local recruiters = {
  filter: {
    or: [
      // On Linkedin Sentry is stylized as `Sentry (sentry.io)`, this makes
      // it very easy to filter out recruiters using templates
      { has: 'Sentry (sentry.io)' },
      // Things recruiters call themselves
      { has: 'recruiter' },
      { has: 'sourcer' },
      { has: 'technical sourcer' },
      { has: 'talent manager' },
      { has: 'talent associate' },
      { has: 'talent scout' },
      { has: 'talent acquisition' },
      // Things not recruiters call themselves but still try to recruit
      { has: 'VP of Engineering' },
      { has: 'I’m the CTO' },
      { has: 'I’m the Co-Founder' },
      // Phrases they like to use
      { has: 'your experience at sentry' },
      { has: 'the hiring manager' },
      { has: 'job description' },
      { has: 'Series A startup' },
      { has: 'Series B startup' },
      { has: 'Series C startup' },
    ],
  },
  actions: {
    archive: true,
    markRead: true,
    labels: ['Recruiters'],
  },
};

// Archive lyft ride notifications
local lyftRides = {
  filter: {
    and: [
      { from: 'no-reply@lyftmail.com' },
      { subject: 'Your Ride with' },
    ],
  },
  actions: {
    archive: true,
    markRead: true,
    labels: ['Rideshare / Lyft'],
  },
};

// Archive uber ride notifications
local uberRides = {
  filter: {
    and: [
      {
        or: [
          { from: 'uber.us@uber.com' },
          { from: 'noreply@uber.com' },
        ],
      },
      { subject: 'trip with uber' },
    ],
  },
  actions: {
    archive: true,
    markRead: true,
    labels: ['Rideshare / Uber'],
  },
};

// Doordash confirmation type emails
local doordash = {
  filter: {
    and: [
      { from: 'no-reply@doordash.com' },
      {
        or: [
          { subject: 'Order Confirmation' },
          { subject: 'Details of your no-contact delivery' },
          { subject: 'Your Group Order from' },
          { subject: 'New login to your DoorDash account' },
        ],
      },
    ],
  },
  actions: {
    archive: true,
    markRead: true,
  },
};

// Archive venmo notifications
local venmoPaid = {
  filter: {
    and: [
      { from: 'venmo@venmo.com' },
      {
        or: [
          { subject: 'You paid' },
          { subject: 'You completed' },
        ],
      },
    ],
  },
  actions: {
    archive: true,
    markRead: true,
    labels: ['Venmo / Paid'],
  },
};

// Every time [venmo-auto-cashout][0] runs I get an email like this. Ignore it.
//
// [0]: https://github.com/evanpurkhiser/venmo-auto-cashout
local venmoCashout = {
  filter: {
    and: [
      { from: 'venmo@venmo.com' },
      { subject: 'Your Venmo bank transfer has been initiated' },
    ],
  },
  actions: {
    archive: true,
    markRead: true,
    labels: ['Venmo / Cashout'],
  },
};

local rentPayments = {
  filter: {
    subject: "Pine/Polk, LLC - Online Payment Confirmation"
  },
  actions: {
    archive: true,
    labels: ['Rent Payments'],
  },
};

// Archive wealthfront notifications
local wealthfrontNotifications = {
  filter: {
    and: [
      { from: 'support@wealthfront.com' },
      {
        or: [
          { subject: 'Investment prospectus' },
          { subject: 'Your Wealthfront Account: Funds Have Been Added' },
          { subject: 'Your Monthly Wealthfront Brokerage Statement' },
        ],
      },
    ],
  },
  actions: {
    archive: true,
    markRead: true,
  },
};

// Chase account statement, These notifications cannot be turned off afacit
local chaseStatements = {
  filter: {
    and: [
      { from: 'no-reply@alertsp.chase.com' },
      { subject: 'Your statement is ready' },
    ],
  },
  actions: {
    archive: true,
    markRead: true,
  },
};

// Ignore Charles Schwab "Vote now!" emails
local schwabProxy = {
  filter: {
    from: 'id@proxyvote.com',
  },
  actions: {
    archive: true,
    markRead: true,
  },
};

// New sentry option grants, useful to keep for historic reasons
local sentryOptionGrants = {
  filter: {
    subject: 'You have vested new Functional Software, Inc, DBA Sentry options',
  },
  actions: {
    archive: true,
    markRead: true,
    markImportant: false,
    labels: ['Sentry Options'],
  },
};

// Sometimse I like to go back through and see what new bandcamp stuff has come
// out, but generally I don't want this in my inbox
local musicBandcamp = {
  filter: {
    and: [
      { from: 'noreply@bandcamp.com' },
      { subject: 'New' },
    ],
  },
  actions: {
    archive: true,
    markRead: true,
    labels: ['Music / Bandcamp'],
  },
};

// Emails for tracks sent as promos. These can be a bit higher priority than
// things like bandcamp.
local musicPromos = {
  filter: {
    from: 'promobox-reply@label-worx.com',
  },
  actions: {
    archive: true,
    labels: ['Music / Promos'],
  },
};

// Companies appear to be required to send privacy policy change notices. I
// have absolutely never once read these and never will. Just archive
local privacyPolicyUpdates = {
  filter: {
    subject: 'privacy',
  },
  actions: {
    archive: true,
  },
};

// These emails are literally just "please login"
local iptorrentsNotice = {
  filter: {
    from: 'noreply@iptorrents.com',
  },
  actions: {
    archive: true,
    markRead: true,
  },
};

local brandTheory = {
  filter: {
    from: 'theory@e.theory.com',
  },
  actions: {
    archive: true,
    labels: ['Brand / Theory']
  },
};

local shippedNotification = {
  filter: {
    has: 'has shipped',
  },
  actions: {
    archive: true,
    labels: ['Shipping Notification'],
    category: "personal",
  },
};

local newsletterReading = {
  filter: {
    or: [
      { from: 'setstudio@buttondown.email' },
    ],
  },
  actions: {
    archive: true,
    labels: ['Newsletter / Reading'],
  },
};

local newsletterShopping = {
  filter: {
    or: [
      { from: 'info@designbythem.com' },
    ],
  },
  actions: {
    archive: true,
    labels: ['Newsletter / Shopping'],
  },
};

local newsletterSF = {
  filter: {
    or: [
      { from: 'news@sfmoma.org' },
      { from: 'enews@sfballet.org' },
      { from: 'newsletter@contact.exploratorium.edu' },
    ],
  },
  actions: {
    archive: true,
    labels: ['Newsletter / SF'],
  },
};

local rules = [
  recruiters,
  lyftRides,
  uberRides,
  doordash,
  venmoPaid,
  venmoCashout,
  rentPayments,
  wealthfrontNotifications,
  chaseStatements,
  schwabProxy,
  sentryOptionGrants,
  musicBandcamp,
  musicPromos,
  privacyPolicyUpdates,
  iptorrentsNotice,
  brandTheory,
  shippedNotification,
  newsletterReading,
  newsletterShopping,
  newsletterSF,
];

{
  version: 'v1alpha3',
  labels: labels,
  rules: rules,
}
