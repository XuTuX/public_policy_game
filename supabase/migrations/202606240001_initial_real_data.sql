create extension if not exists pgcrypto with schema extensions;

create schema if not exists private;
revoke all on schema private from public, anon, authenticated;

create type public.member_vote_status as enum (
  'yes',
  'no',
  'abstain',
  'not_voted'
);

create type public.summary_status as enum (
  'pending',
  'ready',
  'failed'
);

create type private.job_status as enum (
  'pending',
  'processing',
  'completed',
  'failed'
);

create table public.assembly_bills (
  id uuid primary key default gen_random_uuid(),
  assembly_bill_id text not null unique,
  bill_no text not null,
  bill_name text not null,
  assembly_age integer not null check (assembly_age > 0),
  proposer text not null default '',
  committee text not null default '',
  process_result text not null default '',
  proposed_date date,
  vote_date date,
  official_source_url text not null default '',
  official_yes_count integer check (official_yes_count is null or official_yes_count >= 0),
  official_no_count integer check (official_no_count is null or official_no_count >= 0),
  official_abstain_count integer check (official_abstain_count is null or official_abstain_count >= 0),
  collected_at timestamptz not null default now(),
  last_seen_at timestamptz not null default now(),
  raw_payload jsonb not null default '{}'::jsonb
);

create index assembly_bills_latest_vote_idx
  on public.assembly_bills (assembly_age, vote_date desc, bill_no desc);

create table public.assembly_members (
  member_code text primary key,
  name text not null,
  party text not null default '',
  district text not null default '',
  profile_image_url text,
  assembly_age integer not null check (assembly_age > 0),
  active boolean not null default true,
  collected_at timestamptz not null default now(),
  raw_payload jsonb not null default '{}'::jsonb
);

create table public.member_votes (
  bill_id uuid not null references public.assembly_bills(id) on delete cascade,
  member_code text not null references public.assembly_members(member_code) on delete cascade,
  status public.member_vote_status not null,
  raw_vote_result text not null,
  party_at_vote text not null default '',
  district_at_vote text not null default '',
  collected_at timestamptz not null default now(),
  raw_payload jsonb not null default '{}'::jsonb,
  primary key (bill_id, member_code)
);

create index member_votes_member_idx on public.member_votes (member_code, bill_id);

create table public.bill_summaries (
  bill_id uuid primary key references public.assembly_bills(id) on delete cascade,
  status public.summary_status not null default 'pending',
  category text not null default '기타',
  background text not null default '',
  pros text not null default '',
  cons text not null default '',
  background_dialogue text not null default '',
  positive_dialogue text not null default '',
  concern_dialogue text not null default '',
  positive_impact text not null default '',
  concern_impact text not null default '',
  model text not null default '',
  prompt_version text not null default '',
  source_hash text not null default '',
  generated_at timestamptz,
  last_error text,
  updated_at timestamptz not null default now(),
  constraint ready_summary_has_content check (
    status <> 'ready'
    or (
      length(trim(background)) > 0
      and length(trim(pros)) > 0
      and length(trim(cons)) > 0
      and length(trim(background_dialogue)) > 0
      and length(trim(positive_dialogue)) > 0
      and length(trim(concern_dialogue)) > 0
      and length(trim(positive_impact)) > 0
      and length(trim(concern_impact)) > 0
      and length(trim(source_hash)) > 0
    )
  )
);

create table public.game_sets (
  id uuid primary key default gen_random_uuid(),
  fingerprint text not null unique,
  data_as_of timestamptz not null,
  is_active boolean not null default false,
  created_at timestamptz not null default now()
);

create unique index one_active_game_set_idx
  on public.game_sets (is_active)
  where is_active;

create table public.game_set_bills (
  game_set_id uuid not null references public.game_sets(id) on delete cascade,
  bill_id uuid not null references public.assembly_bills(id) on delete restrict,
  position integer not null check (position between 1 and 10),
  primary key (game_set_id, bill_id),
  unique (game_set_id, position)
);

create table private.source_documents (
  bill_id uuid primary key references public.assembly_bills(id) on delete cascade,
  source_url text not null,
  source_text text not null,
  source_hash text not null,
  fetched_at timestamptz not null default now(),
  extraction_method text not null,
  constraint source_document_not_empty check (length(trim(source_text)) >= 100)
);

create table private.summary_jobs (
  id uuid primary key default gen_random_uuid(),
  bill_id uuid not null references public.assembly_bills(id) on delete cascade,
  source_hash text not null,
  status private.job_status not null default 'pending',
  attempts integer not null default 0 check (attempts between 0 and 3),
  next_attempt_at timestamptz not null default now(),
  locked_at timestamptz,
  last_error text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (bill_id, source_hash)
);

create index summary_jobs_claim_idx
  on private.summary_jobs (status, next_attempt_at, created_at);

create table private.sync_runs (
  id uuid primary key default gen_random_uuid(),
  job_name text not null,
  status text not null check (status in ('running', 'completed', 'failed')),
  started_at timestamptz not null default now(),
  finished_at timestamptz,
  bills_seen integer not null default 0,
  votes_seen integer not null default 0,
  details jsonb not null default '{}'::jsonb,
  error_message text
);

alter table public.assembly_bills enable row level security;
alter table public.assembly_members enable row level security;
alter table public.member_votes enable row level security;
alter table public.bill_summaries enable row level security;
alter table public.game_sets enable row level security;
alter table public.game_set_bills enable row level security;

revoke all on all tables in schema public from anon, authenticated;
revoke all on all sequences in schema public from anon, authenticated;

create or replace function private.claim_summary_jobs(p_limit integer default 3)
returns table (
  job_id uuid,
  bill_id uuid,
  bill_name text,
  source_text text,
  source_hash text
)
language plpgsql
security definer
set search_path = pg_catalog, public, private
as $$
begin
  return query
  with claimed as (
    select j.id
    from private.summary_jobs j
    where j.status = 'pending'
      and j.attempts < 3
      and j.next_attempt_at <= now()
    order by j.created_at
    for update skip locked
    limit greatest(1, least(p_limit, 5))
  ), updated as (
    update private.summary_jobs j
    set status = 'processing',
        attempts = attempts + 1,
        locked_at = now(),
        updated_at = now()
    from claimed c
    where j.id = c.id
    returning j.id, j.bill_id, j.source_hash
  )
  select u.id, u.bill_id, b.bill_name, d.source_text, u.source_hash
  from updated u
  join public.assembly_bills b on b.id = u.bill_id
  join private.source_documents d on d.bill_id = u.bill_id
  where d.source_hash = u.source_hash;
end;
$$;

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
    limit 10
  ) c;

  if coalesce(array_length(selected_bills, 1), 0) <> 10 then
    return null;
  end if;

  select encode(digest(array_to_string(selected_bills, ','), 'sha256'), 'hex')
  into new_fingerprint;

  select id into existing_set_id
  from public.game_sets
  where fingerprint = new_fingerprint;

  if existing_set_id is not null then
    update public.game_sets
    set is_active = false
    where is_active and id <> existing_set_id;
    update public.game_sets
    set is_active = true, data_as_of = now()
    where id = existing_set_id;
    return existing_set_id;
  end if;

  update public.game_sets set is_active = false where is_active;

  insert into public.game_sets (fingerprint, data_as_of, is_active)
  values (new_fingerprint, now(), true)
  returning id into new_set_id;

  insert into public.game_set_bills (game_set_id, bill_id, position)
  select new_set_id, bill_id, ordinality::integer
  from unnest(selected_bills) with ordinality as x(bill_id, ordinality);

  return new_set_id;
end;
$$;

create or replace function public.record_source_document(
  p_bill_id uuid,
  p_source_url text,
  p_source_text text,
  p_source_hash text,
  p_extraction_method text
)
returns boolean
language plpgsql
security definer
set search_path = pg_catalog, public, private
as $$
declare
  previous_hash text;
begin
  if length(trim(p_source_text)) < 100 or length(trim(p_source_hash)) = 0 then
    raise exception 'source document is empty';
  end if;

  select source_hash into previous_hash
  from private.source_documents
  where bill_id = p_bill_id;

  insert into private.source_documents (
    bill_id, source_url, source_text, source_hash, fetched_at, extraction_method
  ) values (
    p_bill_id, p_source_url, p_source_text, p_source_hash, now(), p_extraction_method
  )
  on conflict (bill_id) do update set
    source_url = excluded.source_url,
    source_text = excluded.source_text,
    source_hash = excluded.source_hash,
    fetched_at = excluded.fetched_at,
    extraction_method = excluded.extraction_method;

  if previous_hash is distinct from p_source_hash then
    insert into public.bill_summaries (bill_id, status, source_hash, updated_at)
    values (p_bill_id, 'pending', p_source_hash, now())
    on conflict (bill_id) do update set
      status = 'pending',
      source_hash = excluded.source_hash,
      last_error = null,
      updated_at = now();

    insert into private.summary_jobs (bill_id, source_hash)
    values (p_bill_id, p_source_hash)
    on conflict (bill_id, source_hash) do update set
      status = case
        when private.summary_jobs.status = 'completed' then private.summary_jobs.status
        else 'pending'::private.job_status
      end,
      next_attempt_at = now(),
      updated_at = now();
    return true;
  end if;

  return false;
end;
$$;

create or replace function public.claim_summary_jobs(p_limit integer default 3)
returns table (
  job_id uuid,
  bill_id uuid,
  bill_name text,
  source_text text,
  source_hash text
)
language sql
security definer
set search_path = pg_catalog, public, private
as $$
  select * from private.claim_summary_jobs(p_limit);
$$;

create or replace function public.complete_summary_job(
  p_job_id uuid,
  p_bill_id uuid,
  p_source_hash text,
  p_category text,
  p_background text,
  p_pros text,
  p_cons text,
  p_background_dialogue text,
  p_positive_dialogue text,
  p_concern_dialogue text,
  p_positive_impact text,
  p_concern_impact text,
  p_model text,
  p_prompt_version text
)
returns void
language plpgsql
security definer
set search_path = pg_catalog, public, private
as $$
begin
  if not exists (
    select 1 from private.source_documents
    where bill_id = p_bill_id and source_hash = p_source_hash
  ) then
    raise exception 'source changed while summary was running';
  end if;

  insert into public.bill_summaries (
    bill_id, status, category, background, pros, cons,
    background_dialogue, positive_dialogue, concern_dialogue,
    positive_impact, concern_impact, model, prompt_version,
    source_hash, generated_at, last_error, updated_at
  ) values (
    p_bill_id, 'ready', p_category, p_background, p_pros, p_cons,
    p_background_dialogue, p_positive_dialogue, p_concern_dialogue,
    p_positive_impact, p_concern_impact, p_model, p_prompt_version,
    p_source_hash, now(), null, now()
  )
  on conflict (bill_id) do update set
    status = 'ready',
    category = excluded.category,
    background = excluded.background,
    pros = excluded.pros,
    cons = excluded.cons,
    background_dialogue = excluded.background_dialogue,
    positive_dialogue = excluded.positive_dialogue,
    concern_dialogue = excluded.concern_dialogue,
    positive_impact = excluded.positive_impact,
    concern_impact = excluded.concern_impact,
    model = excluded.model,
    prompt_version = excluded.prompt_version,
    source_hash = excluded.source_hash,
    generated_at = now(),
    last_error = null,
    updated_at = now();

  update private.summary_jobs
  set status = 'completed', locked_at = null, last_error = null, updated_at = now()
  where id = p_job_id and bill_id = p_bill_id and source_hash = p_source_hash;
end;
$$;

create or replace function public.fail_summary_job(p_job_id uuid, p_error text)
returns void
language plpgsql
security definer
set search_path = pg_catalog, public, private
as $$
declare
  job private.summary_jobs%rowtype;
begin
  select * into job from private.summary_jobs where id = p_job_id for update;
  if not found then return; end if;

  update private.summary_jobs
  set status = case when attempts >= 3 then 'failed'::private.job_status else 'pending'::private.job_status end,
      next_attempt_at = now() + make_interval(mins => (power(2, greatest(attempts, 1))::integer * 5)),
      locked_at = null,
      last_error = left(p_error, 2000),
      updated_at = now()
  where id = p_job_id;

  update public.bill_summaries
  set status = case when job.attempts >= 3 then 'failed'::public.summary_status else 'pending'::public.summary_status end,
      last_error = left(p_error, 2000),
      updated_at = now()
  where bill_id = job.bill_id;
end;
$$;

create or replace function public.start_sync_run(p_job_name text)
returns uuid
language plpgsql
security definer
set search_path = pg_catalog, private
as $$
declare run_id uuid;
begin
  insert into private.sync_runs (job_name, status)
  values (p_job_name, 'running') returning id into run_id;
  return run_id;
end;
$$;

create or replace function public.finish_sync_run(
  p_run_id uuid,
  p_status text,
  p_bills_seen integer default 0,
  p_votes_seen integer default 0,
  p_details jsonb default '{}'::jsonb,
  p_error_message text default null
)
returns void
language sql
security definer
set search_path = pg_catalog, private
as $$
  update private.sync_runs
  set status = p_status,
      finished_at = now(),
      bills_seen = p_bills_seen,
      votes_seen = p_votes_seen,
      details = coalesce(p_details, '{}'::jsonb),
      error_message = left(p_error_message, 4000)
  where id = p_run_id;
$$;

create or replace function public.publish_latest_game_set()
returns uuid
language sql
security definer
set search_path = pg_catalog, public, private
as $$
  select private.publish_latest_game_set();
$$;

create or replace function public.get_active_game()
returns jsonb
language sql
stable
security definer
set search_path = pg_catalog, public
as $$
  select jsonb_build_object(
    'gameSetId', gs.id,
    'dataAsOf', gs.data_as_of,
    'bills', coalesce(jsonb_agg(
      jsonb_build_object(
        'id', b.id,
        'assemblyBillId', b.assembly_bill_id,
        'billNo', b.bill_no,
        'billName', b.bill_name,
        'category', s.category,
        'status', b.process_result,
        'proposer', b.proposer,
        'proposedDate', b.proposed_date,
        'voteDate', b.vote_date,
        'officialSourceUrl', b.official_source_url,
        'dataAsOf', gs.data_as_of,
        'aiModel', s.model,
        'summary', jsonb_build_object(
          'background', s.background,
          'pros', s.pros,
          'cons', s.cons
        ),
        'narrative', jsonb_build_object(
          'backgroundDialogue', s.background_dialogue,
          'positiveDialogue', s.positive_dialogue,
          'concernDialogue', s.concern_dialogue,
          'positiveImpact', s.positive_impact,
          'concernImpact', s.concern_impact
        ),
        'estimatedMinutes', 2
      ) order by gsb.position
    ), '[]'::jsonb)
  )
  from public.game_sets gs
  join public.game_set_bills gsb on gsb.game_set_id = gs.id
  join public.assembly_bills b on b.id = gsb.bill_id
  join public.bill_summaries s on s.bill_id = b.id
  where gs.is_active
  group by gs.id, gs.data_as_of;
$$;

create or replace function public.get_game_votes(p_game_set_id uuid)
returns jsonb
language plpgsql
stable
security definer
set search_path = pg_catalog, public
as $$
declare
  result jsonb;
begin
  if not exists (select 1 from public.game_sets where id = p_game_set_id) then
    raise exception 'unknown game set';
  end if;

  select jsonb_build_object(
    'members', coalesce((
      select jsonb_agg(jsonb_build_object(
        'id', m.member_code,
        'name', m.name,
        'party', m.party,
        'district', m.district,
        'profileImageUrl', m.profile_image_url
      ) order by m.name)
      from public.assembly_members m
      where exists (
        select 1
        from public.member_votes v
        join public.game_set_bills gsb on gsb.bill_id = v.bill_id
        where gsb.game_set_id = p_game_set_id
          and v.member_code = m.member_code
      )
    ), '[]'::jsonb),
    'votes', coalesce((
      select jsonb_agg(jsonb_build_object(
        'billId', v.bill_id,
        'memberId', v.member_code,
        'memberName', m.name,
        'party', v.party_at_vote,
        'district', v.district_at_vote,
        'status', v.status,
        'rawVoteResult', v.raw_vote_result
      ) order by v.bill_id, v.member_code)
      from public.member_votes v
      join public.game_set_bills gsb on gsb.bill_id = v.bill_id
      join public.assembly_members m on m.member_code = v.member_code
      where gsb.game_set_id = p_game_set_id
    ), '[]'::jsonb)
  ) into result;

  return result;
end;
$$;

revoke all on function public.get_active_game() from public;
revoke all on function public.get_game_votes(uuid) from public;
grant execute on function public.get_active_game() to anon, authenticated;
grant execute on function public.get_game_votes(uuid) to anon, authenticated;

revoke all on function public.record_source_document(uuid, text, text, text, text) from public;
revoke all on function public.claim_summary_jobs(integer) from public;
revoke all on function public.complete_summary_job(uuid, uuid, text, text, text, text, text, text, text, text, text, text, text, text) from public;
revoke all on function public.fail_summary_job(uuid, text) from public;
revoke all on function public.start_sync_run(text) from public;
revoke all on function public.finish_sync_run(uuid, text, integer, integer, jsonb, text) from public;
revoke all on function public.publish_latest_game_set() from public;

grant execute on function public.record_source_document(uuid, text, text, text, text) to service_role;
grant execute on function public.claim_summary_jobs(integer) to service_role;
grant execute on function public.complete_summary_job(uuid, uuid, text, text, text, text, text, text, text, text, text, text, text, text) to service_role;
grant execute on function public.fail_summary_job(uuid, text) to service_role;
grant execute on function public.start_sync_run(text) to service_role;
grant execute on function public.finish_sync_run(uuid, text, integer, integer, jsonb, text) to service_role;
grant execute on function public.publish_latest_game_set() to service_role;

revoke all on all functions in schema private from public, anon, authenticated;
