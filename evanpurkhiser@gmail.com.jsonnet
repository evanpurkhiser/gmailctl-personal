local lib = import 'gmailctl.libsonnet';

local labels = [{ name: l } for l in [
  'Brand / COS',
  'Brand / Club Monaco',
  'Brand / Theory',
  'Mailbox',
  'Money / Receipts',
  'Money / Statements',
  'Music / Bandcamp',
  'Music / Promos',
  'Music / SF Events',
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
      { has: 'talent & growth' },
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
      { has: 'We have raised' },
      { has: 'founding engineer' },
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
      {
        or: [
          { subject: 'Your Venmo bank transfer has been initiated' },
          { subject: 'Your Venmo Standard transfer has been initiated' },
        ],
      },
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
    subject: 'Pine/Polk, LLC - Online Payment Confirmation',
  },
  actions: {
    archive: true,
    labels: ['Rent Payments'],
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
    subject: 'You have newly vested Functional Software, Inc, DBA Sentry options',
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
    or: [
      { from: 'promobox-reply@label-worx.com' },
      { from: 'justicehardcore2013@gmail.com' },
      { from: 'alstormuk@gmail.com' },
      { from: 'info@oneseventy.net' },
    ],
  },
  actions: {
    archive: true,
    labels: ['Music / Promos'],
  },
};

// Emails for raves + other shows in SF
local musicSFEvents = {
  filter: {
    or: [
      { from: 'info@pluralliance.org' },
      { from: 'info@trancefamilysf.com' },
    ],
  },
  actions: {
    archive: true,
    labels: ['Music / SF Events'],
  },
};

// Companies appear to be required to send privacy policy change notices. I
// have absolutely never once read these and never will. Just archive
local privacyPolicyUpdates = {
  filter: {
    or: [
      { subject: 'privacy' },
      { subject: 'policies' },
      { subject: 'terms' },
    ],
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
    from: 'theory.com',
  },
  actions: {
    archive: true,
    labels: ['Brand / Theory'],
  },
};

local brandCos = {
  filter: {
    from: 'cos.com',
  },
  actions: {
    archive: true,
    labels: ['Brand / COS'],
  },
};

local brandClubMonaco = {
  filter: {
    from: 'clubmonaco.com',
  },
  actions: {
    archive: true,
    labels: ['Brand / Club Monaco'],
  },
};

local shippedNotification = {
  filter: {
    or: [
      { has: 'has shipped' },
      { subject: 'Delivered: Your Amazon.com order' },
      { subject: 'Your Amazon.com order' },
    ],
  },
  actions: {
    archive: true,
    labels: ['Shipping Notification'],
    category: 'personal',
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
      { from: 'hello@hem.com' },
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
      { from: 'sfmoma.org' },
      { from: 'sfballet.org' },
      { from: 'exploratorium.edu' },
    ],
  },
  actions: {
    archive: true,
    labels: ['Newsletter / SF'],
  },
};

// Various bank / investment statments, I don't need to see this but like to
// keep them for record
local statments = {
  filter: {
    or: [
      // Wealthfront
      { from: 'no-reply@em.wealthfront.com' },
      { subject: 'Your Wealthfront Account: Funds Have Been Added' },
      // Schwab
      { subject: 'Your account eStatement is available' },
      { subject: 'Your account statement is available' },
      { subject: 'Schwab eConfirms for account ending' },
      // Chase
      { subject: 'Your statement is ready for account' },
      { subject: 'Your statement is ready for credit card ending' },
      { subject: 'Your Chase Sapphire Reserve automatic payment is scheduled' },
      // Human interest
      { from: 'support@humaninterest.com' },
      // Google
      { subject: 'Google Workspace: Your invoice is available for evanpurkhiser.com' },
      { subject: 'View your monthly statement from Google Pay' },
      // Venmo statements
      { and: [{ from: 'venmo@venmo.com' }, { subject: 'Transaction History' }] },
    ],
  },
  actions: {
    archive: true,
    labels: ['Money / Statements'],
  },
};

// Various email receipts
local receipts = {
  filter: {
    or: [
      // Uber Eats
      { subject: 'order with Uber Eats' },
      // Digital Ocean
      { subject: 'DigitalOcean - Payment Receipt' },
      { has: 'Thanks for using DigitalOcean' },
      // Any service that uses square
      { has: 'Square automatically sends receipts to the email address you used at any Square seller' },
      // Amara Financial invocies
      {
        and: [
          { subject: 'Payment Receipt for Invoice' },
          { from: 'mailer@waveapps.com' },
        ],
      },
      // Toast
      { from: 'no-reply@toasttab.com' },
    ],
  },
  actions: {
    archive: true,
    labels: ['Money / Receipts'],
  },
};

// USPS Informed delivery
local mailbox = {
  filter: {
    from: 'email.informeddelivery.usps.com',
  },
  actions: {
    archive: true,
    labels: ['Mailbox'],
  },
};

// Things I just straight don't care about
local ignoredList = [
  // Google cloud subprocess update emails
  {
    and: [
      { from: 'Google Cloud Platform' },
      { subject: 'Third-Party Subprocessors list' },
    ],
  },
  // Trublue point emails
  { subject: 'Your TrueBlue statement has landed' },
];
local ignored = {
  filter: { or: ignoredList },
  actions: {
    archive: true,
    markRead: true,
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
  schwabProxy,
  sentryOptionGrants,
  musicBandcamp,
  musicPromos,
  musicSFEvents,
  privacyPolicyUpdates,
  iptorrentsNotice,
  brandTheory,
  brandCos,
  brandClubMonaco,
  shippedNotification,
  newsletterReading,
  newsletterShopping,
  newsletterSF,
  statments,
  receipts,
  mailbox,
  ignored,
];

{
  version: 'v1alpha3',
  labels: labels,
  rules: rules,
}
