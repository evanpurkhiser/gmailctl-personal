local lib = import 'gmailctl.libsonnet';

local labels = [{ name: l } for l in [
  '+ Important',
  '+ Needs Filters',
  'Brand / COS',
  'Brand / Club Monaco',
  'Brand / Sheec Socks',
  'Brand / Theory',
  'CCSF',
  'Discounts',
  'Mailbox',
  'Flight Confirmations',
  'Money / Receipts',
  'Money / Statements',
  'Music / Bandcamp',
  'Music / Promos',
  'Music / SF Events',
  'Newsletter / Reading',
  'Newsletter / SF',
  'Newsletter / NYC',
  'Newsletter / Shopping',
  'Recruiters',
  'Rent Payments',
  'Rideshare / Lyft',
  'Rideshare / Uber',
  'Sentry Options',
  'Shipping Notification',
  'Venmo / Cashout',
  'Venmo / Paid',
  'Fwd / Lunch Money',
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
      { has: 'recruiting' },
      { has: 'sourcer' },
      { has: 'technical sourcer' },
      { has: 'talent manager' },
      { has: 'talent advisor' },
      { has: 'talent associate' },
      { has: 'talent scout' },
      { has: 'talent acquisition' },
      { has: 'talent partner' },
      { has: 'talent specialist' },
      { has: 'talent search specialist' },
      { has: 'talent director' },
      { has: 'talent team' },
      { has: 'talent & growth' },
      { has: 'head of talent' },
      // Things not recruiters call themselves but still try to recruit
      { has: 'VP of Engineering' },
      { has: 'I’m the CTO' },
      { has: 'I’m the Co-Founder' },
      // Phrases they like to use
      { has: 'your experience at sentry' },
      { has: 'the hiring manager' },
      { has: 'job description' },
      { has: 'early-stage startup' },
      { has: 'pre-seed' },
      { has: 'Series A' },
      { has: 'Series B' },
      { has: 'Series C' },
      { has: 'We have raised' },
      { has: 'founding engineer' },
      { has: 'founding engineering' },
      { has: 'founding team' },
      { has: 'connect with me on LinkedIn' },
      { has: 'connect on LinkedIn' },
      { has: 'cash flow positive' },
      { has: 'product-market fit' },
      { has: 'vc-funded' },
      { has: 'vc-backed' },
      { has: 'I lead recruiting' },
      { has: 'you would be a great fit' },
      { has: 'your availability is' },
      { has: 'your next move' },
      { has: 'open to new opportunities' },
      { has: 'open to connecting' },
      { has: 'reached out to you' },
      { has: 'sequoia' },
      { has: 'open to a quick' },
      { has: 'intro chat' },
      { has: 'fast-growing' },
      { has: 'in this role' },
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
      {
        or: [
          { subject: 'Your Ride with' },
          { subject: 'Your Lyft Bike ride' },
        ],
      },
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


// Spectrum
local spectrum = {
  filter: {
    and: [
      { or: [

        { subject: 'Your Payment Is Scheduled Soon' },
        { subject: 'Spectrum Alert: Service Outage' },
        { subject: 'Spectrum Alert: Service Restored' },
        { subject: 'Your Service is Restored' },
        { subject: 'Service Alert' },
      ] },
      { from: 'MyAccount@spectrumemails.com' },
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

local brandSheecSocks = {
  filter: {
    from: 'sheecsocks.com',
  },
  actions: {
    archive: true,
    labels: ['Brand / Sheec Socks'],
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
      { from: 'mcinfo@ups.com' },
      { has: 'has shipped' },
      { subject: 'Delivered: Your Amazon.com order' },
      { subject: 'Your Amazon.com order' },
      { subject: 'Your Amazon package will be delivered today' },
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
      { from: 'info@tympanus.net' },
      { from: 'thecollectivenewsletter@mail.beehiiv.com' },
      { from: 'hello@gilhuybrecht.com' },
      { from: 'me@arun.is' },
      { from: 'theindex@piccalil.li' },
      { from: 'info@email.1password.com' },
      { from: 'makingsoftware.co' },
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
      { from: 'asianart.org' },
      { from: 'sfballet.org' },
      { from: 'exploratorium.edu' },
      { from: 'escape@palace-games.com' },
    ],
  },
  actions: {
    archive: true,
    labels: ['Newsletter / SF'],
  },
};

local newsletterNYC = {
  filter: {
    or: [
      { from: 'metmuseum.org' },
      { from: 'moma.org' },
    ],
  },
  actions: {
    archive: true,
    labels: ['Newsletter / NYC'],
  },
};

// Various bank / investment statements, I don't need to see this but like to
// keep them for record
local statements = {
  filter: {
    or: [
      // Wealthfront
      { from: 'no-reply@em.wealthfront.com' },
      { subject: 'Your Wealthfront Account: Funds Have Been Added' },
      // Schwab
      { subject: 'Your account eStatement is available' },
      { subject: 'Your account statement is available' },
      { subject: 'Schwab eConfirms' },
      // Chase
      { subject: 'Your statement is ready for account' },
      { subject: 'Your statement is ready for credit card ending' },
      { subject: 'Your latest statement is now available' },
      { subject: 'Your Chase Sapphire Reserve Visa automatic payment is scheduled' },
      // United Healthcare
      { subject: "Here's your new Health Statement from UnitedHealthcare" },
      // Human interest
      { from: 'support@humaninterest.com' },
      // Google
      { subject: 'Google Workspace: Your invoice is available for evanpurkhiser.com' },
      { subject: 'View your monthly statement from Google Pay' },
      // Venmo statements
      { and: [{ from: 'venmo@venmo.com' }, { subject: 'Transaction History' }] },
      // Spectrum
      { subject: 'Your Spectrum Statement is Ready' },
      // Dads ATT (He has me as a recovery email)
      { from: 'att-mail.com' },
      // Cloudflare invoices
      { subject: 'Your Cloudflare Invoice is Available' },
      // Paypal
      { and: [{ from: 'paypal.com' }, { subject: 'account statement is available.' }] },
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
      // Apple
      { subject: 'Your receipt from Apple.' },
      // Any service that uses square
      { has: 'Square automatically sends receipts to the email address you used at any Square seller' },
      // Amara Financial invoices
      {
        and: [
          { subject: 'Payment Receipt for Invoice' },
          { from: 'mailer@waveapps.com' },
        ],
      },
      // Toast
      { from: 'no-reply@toasttab.com' },
      // Spectrum internet
      {
        and: [
          { subject: 'Thanks for Your Payment' },
          { from: 'myaccount@spectrumemails.com' },
        ],
      },
      // ConEdison
      { subject: 'Your Con Edison bill is ready' },
      { subject: 'Your Con Edison Bill Is Due' },
      // Apartment rent
      { subject: 'Clear Sky Initiatives - Online Payment Confirmation' },
      // Lunch Money
      { from: 'invoice+statements@lunchmoney.app' },
    ],
  },
  actions: {
    archive: true,
    labels: ['Money / Receipts'],
  },
};

// Flight confirmation emails
local flights = {
  filter: {
    or: [
      { and: [
        { from: 'alaskaair.com' },
        { subject: 'your confirmation receipt' },
      ] },
      { and: [
        { from: 'united.com' },
        { subject: 'eTicket Itinerary and Receipt for Confirmation' },
      ] },
      { and: [
        { from: 'delta.com' },
        { subject: 'your flight receipt - EVAN PURKHISER' },
      ] },
      { and: [
        { from: 'aa.com' },
        { or: [
          { subject: 'Your trip confirmation' }
          { subject: 'E-Ticket Confirmation' },
        ] },
      ] },
      { and: [
        { from: 'spirit-airlines.com' },
        { subject: 'Spirit Airlines Flight Confirmation' },
      ] },
      { and: [
        { from: 'jetblue.com' },
        { subject: 'JetBlue booking confirmation' },
      ] },
      { and: [
        { from: 'flyfrontier.com' },
        { or: [
          { subject: 'Reservation Confirmation' },
          { subject: 'Your Flight Confirmation' },
        ] },
      ] },
      { and: [
        { from: 'aircanada.ca' },
        { subject: 'Booking Reference' },
        { has: 'Booking Confirmation' },
      ] },
      { and: [
        { from: 'easyjet.com' },
        { subject: 'easyJet booking reference' },
      ] },
      { and: [
        { from: 'virginamerica.com' },
        { subject: 'Virgin America Reservation' },
      ] },
      { and: [
        { from: 'southwest.com' },
        { or: [
          { subject: "You're going to" },
          { subject: 'Flight reservation' },
        ] },
      ] },
      { and: [
        { from: 'austrian.com' },
        { subject: 'Your booking to' },
      ] },
      { and: [
        { from: 'lot.com' },
        { subject: 'Booking confirmation for reservation' },
      ] },
      { and: [
        { or: [
          { from: 'chasetravel.com' },
          { from: 'chase.com' },
        ] },
        { subject: 'Travel Reservation Center Trip ID' },
        { has: 'Flight' },
        { not: { has: 'Hotel Reservation' } },
      ] },
      { and: [
        { from: 'EVA AIRWAYS' },
        { subject: 'EVA AIR ELECTRONIC TICKET-EMD RECEIPT' },
        { has: 'ELECTRONIC TICKET RECEIPT' },
      ] },
      { and: [
        { from: 'flyscoot.com' },
        { subject: 'Your Scoot booking confirmation' },
      ] },
      { and: [
        { from: 'gotogate.com' },
        { subject: 'Your trip is confirmed' },
      ] },
      { and: [
        { from: 'trip.com' },
        { subject: 'Flight Booking Confirmed' },
      ] },
    ],
  },
  actions: {
    labels: ['Flight Confirmations'],
  },
};


// Immediately delete mailbox mail that does not have an image
local mailboxDelete = {
  filter: {
    and: [
      { from: 'email.informeddelivery.usps.com' },
      { has: 'There is one or more mailpieces for which we do not currently have an image' },
      { not: { query: 'has:attachment' } },
      { not: { has: 'from' } },
    ],
  },
  actions: {
    delete: true,
  },
};

local mailbox = {
  filter: {
    or: [
      { from: 'email.informeddelivery.usps.com' },
      { subject: 'Package Delivery Virtual Doorman' },
    ],
  },
  actions: {
    archive: true,
    labels: ['Mailbox'],
  },
};

// Emails from CCSF I just don't care about
local ccsf = {
  filter: {
    or: [
      { from: 'citynotes@ccsf.edu' },
      { from: 'district_police_dept@ccsf.edu' },
      { from: 'facilities@ccsf.edu' },
      { from: 'finaid@ccsf.edu ' },
      { from: 'handshake@mail.joinhandshake.com' },
      { from: 'itsAnnouncement@ccsf.edu' },
      { from: 'research@ccsf.edu' },
      { from: 'studentactivities@ccsf.edu' },
      { from: 'studentaffairsdiv@ccsf.edu' },
      { from: 'studenthealth@ccsf.edu' },
      { from: 'ccsfdist@ccsf.edu' },
    ],
  },
  actions: {
    archive: true,
    labels: ['CCSF'],
  },
};

// Emails that should be automatically forwarded to my Lunch Money email detail
// parsing service. These are typically receipt emails that will have some
// associated Lunch Money transaction that will be either split or have notes
// added to it.
//
// See: https://github.com/evanpurkhiser/email-to-lunchmoney
local lunchmoneyForwarding = {
  filter: {
    or: [
      // Amazon order details
      {
        and: [
          { from: 'amazon.com' },
          { subject: 'Ordered:' },
        ],
      },
      // Lyft bike rides
      {
        and: [
          { from: 'lyftmail.com' },
          { subject: 'Your Lyft Bike ride' },
        ],
      },
      // Lyft car rides
      {
        and: [
          { from: 'lyftmail.com' },
          { subject: 'Your Ride with' },
        ],
      },
      // Apple receipts
      { subject: 'Your receipt from Apple.' },
    ],
  },
  actions: {
    labels: ['Fwd / Lunch Money'],
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
  // find my iphone notificatin
  { subject: 'A sound was played on Evan’s iPhone' },
  // Mint mobile notices
  {
    and: [
      { from: 'mintmobile.com' },
      { subject: 'Your Plan Is All Renewed' },
    ],
  },
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
  spectrum,
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
  brandSheecSocks,
  brandClubMonaco,
  shippedNotification,
  newsletterReading,
  newsletterShopping,
  newsletterSF,
  newsletterNYC,
  statements,
  receipts,
  flights,
  mailboxDelete,
  mailbox,
  ccsf,
  lunchmoneyForwarding,
  ignored,
];

{
  version: 'v1alpha3',
  labels: labels,
  rules: rules,
}
