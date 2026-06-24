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
      and (select count(*) from public.member_votes v where v.bill_id = b.id and v.status = 'yes') = b.official_yes_count
      and (select count(*) from public.member_votes v where v.bill_id = b.id and v.status = 'no') = b.official_no_count
      and (select count(*) from public.member_votes v where v.bill_id = b.id and v.status = 'abstain') = b.official_abstain_count
    order by b.vote_date desc, b.bill_no desc
    limit 5
  ) c;

  if coalesce(array_length(selected_bills, 1), 0) < 5 then
    return null;
  end if;

  select encode(digest(array_to_string(selected_bills, ','), 'sha256'), 'hex')
  into new_fingerprint;

  select id into existing_set_id
  from public.game_sets
  where fingerprint = new_fingerprint;

  if existing_set_id is not null then
    return existing_set_id;
  end if;

  insert into public.game_sets (fingerprint)
  values (new_fingerprint)
  returning id into new_set_id;

  insert into public.game_set_bills (game_set_id, bill_id, display_order)
  select new_set_id, selected_bills[i], i
  from generate_subscripts(selected_bills, 1) as i;

  return new_set_id;
end;
$$;
