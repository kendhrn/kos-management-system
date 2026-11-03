-- Owner and admin have identical access, and public sign-ups are disabled,
-- so every logged-in user gets full access. Visitors (anon) get nothing.

create policy "Authenticated users have full access"
  on public.settings for all to authenticated
  using (true) with check (true);

create policy "Authenticated users have full access"
  on public.rooms for all to authenticated
  using (true) with check (true);

create policy "Authenticated users have full access"
  on public.tenants for all to authenticated
  using (true) with check (true);

create policy "Authenticated users have full access"
  on public.stays for all to authenticated
  using (true) with check (true);

create policy "Authenticated users have full access"
  on public.bills for all to authenticated
  using (true) with check (true);

create policy "Authenticated users have full access"
  on public.transactions for all to authenticated
  using (true) with check (true);

create policy "Authenticated users have full access"
  on public.maintenance_requests for all to authenticated
  using (true) with check (true);
