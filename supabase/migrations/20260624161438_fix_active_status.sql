update public.game_sets set is_active = false;
update public.game_sets set is_active = true where id = (select id from public.game_sets order by created_at desc limit 1);

create or replace function private.publish_latest_game_set()
returns uuid
language plpgsql
security definer
set search_path = pg_catalog, public, private, extensions
as $$
declare
  selected_bills uuid[];
  new_fingerprint text;
  existing_set_id uuid;
  new_set_id uuid;
begin
  select array_agg(c.id order by c.vote_date desc, c.bill_no desc)
  into selected_bills
  from (
    select b.id, b.vote_date, b.bill_no
    from public.assembly_bills b
    join public.bill_summaries s on s.bill_id = b.id and s.status = 'ready'
    join private.source_documents d
      on d.bill_id = b.id and d.source_hash = s.source_hash
    where b.assembly_age = 22
      and b.vote_date is not null
      and b.official_yes_count is not null
      and b.official_no_count is not null
      and b.official_abstain_count is not null
      and (select count(*) from public.member_votes v where v.bill_id = b.id) > 0
    order by b.vote_date desc, b.bill_no desc
    limit 10
  ) c;

  if coalesce(array_length(selected_bills, 1), 0) < 10 then
    return null;
  end if;

  select encode(digest(array_to_string(selected_bills, ','), 'sha256'), 'hex')
  into new_fingerprint;

  select id into existing_set_id
  from public.game_sets
  where fingerprint = new_fingerprint;

  if existing_set_id is not null then
    update public.game_sets set is_active = false where is_active = true;
    update public.game_sets set is_active = true where id = existing_set_id;
    return existing_set_id;
  end if;

  update public.game_sets set is_active = false where is_active = true;

  insert into public.game_sets (fingerprint, data_as_of, is_active)
  values (new_fingerprint, now(), true)
  returning id into new_set_id;

  insert into public.game_set_bills (game_set_id, bill_id, position)
  select new_set_id, bill_id, ordinality::integer
  from unnest(selected_bills) with ordinality as x(bill_id, ordinality);

  return new_set_id;
end;
$$;
