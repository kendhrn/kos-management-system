-- Initial schema for the kos management system.
-- Money is stored as whole Rupiah in bigint columns (Rupiah has no cents).

-- Kos-wide settings. Exactly one row, edited in the Pengaturan tab.
create table public.settings (
  id smallint primary key default 1 check (id = 1),
  kos_name text not null default 'Kos Saya',
  address text,
  phone text,
  deposit_amount bigint not null default 500000 check (deposit_amount >= 0),
  late_fee_per_day bigint not null default 20000 check (late_fee_per_day >= 0),
  late_fee_grace_days smallint not null default 3 check (late_fee_grace_days >= 0),
  reminder_days_before smallint not null default 2 check (reminder_days_before >= 0),
  biweekly_surcharge bigint not null default 150000 check (biweekly_surcharge >= 0),
  bill_message_template text not null default
    'Halo {nama}, tagihan sewa {kamar} sebesar {jumlah} jatuh tempo pada {jatuh_tempo}. Terima kasih.',
  updated_at timestamptz not null default now()
);

insert into public.settings default values;

-- Rooms. Each room has its own rate; the list is fully editable by the admin.
create table public.rooms (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  monthly_price bigint not null check (monthly_price > 0),
  extra_occupant_fee bigint not null default 0 check (extra_occupant_fee >= 0),
  notes text,
  is_archived boolean not null default false,
  created_at timestamptz not null default now()
);

-- Tenants (penghuni). A person can come back later, so their data is kept separate from each stay.
create table public.tenants (
  id uuid primary key default gen_random_uuid(),
  full_name text not null,
  phone text not null,
  ktp_number text,
  ktp_photo_path text,
  notes text,
  created_at timestamptz not null default now()
);

-- Stays: which tenant lives in which room, and from when to when.
-- check_out_date is null while the tenant still lives there.
create table public.stays (
  id uuid primary key default gen_random_uuid(),
  room_id uuid not null references public.rooms (id) on delete restrict,
  tenant_id uuid not null references public.tenants (id) on delete restrict,
  occupants smallint not null default 1 check (occupants between 1 and 2),
  rent_period text not null default 'monthly'
    check (rent_period in ('monthly', 'biweekly')),
  rent_amount bigint not null check (rent_amount > 0),
  deposit_amount bigint not null default 0 check (deposit_amount >= 0),
  check_in_date date not null,
  check_out_date date,
  created_at timestamptz not null default now(),
  check (check_out_date is null or check_out_date >= check_in_date)
);

-- A room can only have one active stay at a time (no double-booking).
create unique index stays_one_active_per_room
  on public.stays (room_id)
  where check_out_date is null;

create index stays_tenant_id_idx on public.stays (tenant_id); 

-- Bills (tagihan): one per stay per rent period.
-- A bill is paid when the payments linked to it add up to amount + late_fee.
create table public.bills (
  id uuid primary key default gen_random_uuid(),
  stay_id uuid not null references public.stays (id) on delete restrict,
  period_start date not null,
  period_end date not null,
  due_date date not null,
  amount bigint not null check (amount > 0),
  late_fee bigint not null default 0 check (late_fee >= 0),
  status text not null default 'unpaid'
    check (status in ('unpaid', 'partial', 'paid')),
  paid_at timestamptz,
  created_at timestamptz not null default now(),
  check (period_end >= period_start),
  unique (stay_id, period_start)
);

-- Transactions: every money movement, income or expense.
-- Rent, deposit and late-fee payments link to a bill; expenses do not.
create table public.transactions (
  id uuid primary key default gen_random_uuid(),
  type text not null check (type in ('income', 'expense')),
  category text not null,
  amount bigint not null check (amount > 0),
  transaction_date date not null default current_date,
  description text,
  bill_id uuid references public.bills (id) on delete restrict,
  stay_id uuid references public.stays (id) on delete restrict,
  created_at timestamptz not null default now(),
  check (
    (type = 'income' and category in ('sewa', 'deposit', 'denda', 'lainnya'))
    or (type = 'expense' and category in ('listrik', 'air', 'wifi', 'gaji', 'maintenance', 'lainnya'))
  )
);

create index transactions_bill_id_idx on public.transactions (bill_id);
create index transactions_date_idx on public.transactions (transaction_date);

-- Maintenance complaints (keluhan). room_id is empty for shared areas.
-- When a repair costs money, it is linked to its expense transaction.
create table public.maintenance_requests (
  id uuid primary key default gen_random_uuid(),
  room_id uuid references public.rooms (id) on delete restrict,
  description text not null,
  status text not null default 'open'
    check (status in ('open', 'in_progress', 'done')),
  reported_at date not null default current_date,
  resolved_at date,
  transaction_id uuid references public.transactions (id) on delete set null,
  created_at timestamptz not null default now(),
  check (resolved_at is null or resolved_at >= reported_at)
);

-- Row Level Security: lock every table by default.
-- Policies that let the logged-in admin in come in a later migration (#13).
alter table public.settings enable row level security;
alter table public.rooms enable row level security;
alter table public.tenants enable row level security;
alter table public.stays enable row level security;
alter table public.bills enable row level security;
alter table public.transactions enable row level security;
alter table public.maintenance_requests enable row level security;
