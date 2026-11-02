-- Starting rooms from the client's price list.
-- This is only a template: the admin can edit, add or archive rooms in the app.
insert into public.rooms (name, monthly_price, extra_occupant_fee, notes)
values
  ('Kamar 1', 1300000, 0, null),
  ('Kamar 2', 1300000, 0, null),
  ('Kamar 3', 1300000, 0, null),
  ('Kamar 4', 1300000, 0, null),
  ('Kamar 5', 1500000, 150000, null),
  ('Kamar 6', 1250000, 0, null),
  ('Kamar 7', 1300000, 0, null),
  ('Kamar 8', 1500000, 0, null),
  ('Kamar 9', 1300000, 0, null),
  ('Kamar 10', 1300000, 150000, null),
  ('Kamar 11', 900000, 0, 'Non-AC'),
  ('Kamar 12', 1850000, 0, 'Kamar besar dengan bathtub')
on conflict (name) do nothing;
