-- 1. Redefine private.publish_latest_game_set without the private.source_documents join
CREATE OR REPLACE FUNCTION private.publish_latest_game_set()
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, private, extensions
AS $$
DECLARE
  selected_bills uuid[];
  new_fingerprint text;
  existing_set_id uuid;
  new_set_id uuid;
BEGIN
  SELECT array_agg(c.id ORDER BY c.vote_date DESC, c.bill_no DESC)
  INTO selected_bills
  FROM (
    SELECT b.id, b.vote_date, b.bill_no
    FROM public.assembly_bills b
    JOIN public.bill_summaries s ON s.bill_id = b.id AND s.status = 'ready'
    -- Removed private.source_documents join to be more robust
    WHERE b.assembly_age = 22
      AND b.vote_date IS NOT NULL
      AND b.official_yes_count IS NOT NULL
      AND b.official_no_count IS NOT NULL
      AND b.official_abstain_count IS NOT NULL
      AND (SELECT count(*) FROM public.member_votes v WHERE v.bill_id = b.id) > 0
    ORDER BY b.vote_date DESC, b.bill_no DESC
    LIMIT 50
  ) c;

  IF coalesce(array_length(selected_bills, 1), 0) < 5 THEN
    RETURN null;
  END IF;

  SELECT encode(digest(array_to_string(selected_bills, ','), 'sha256'), 'hex')
  INTO new_fingerprint;

  SELECT id INTO existing_set_id
  FROM public.game_sets
  WHERE fingerprint = new_fingerprint;

  IF existing_set_id IS NOT NULL THEN
    UPDATE public.game_sets SET is_active = false WHERE is_active = true;
    UPDATE public.game_sets SET is_active = true WHERE id = existing_set_id;
    RETURN existing_set_id;
  END IF;

  UPDATE public.game_sets SET is_active = false WHERE is_active = true;

  INSERT INTO public.game_sets (fingerprint, data_as_of, is_active)
  VALUES (new_fingerprint, now(), true)
  RETURNING id INTO new_set_id;

  INSERT INTO public.game_set_bills (game_set_id, bill_id, position)
  SELECT new_set_id, bill_id, ordinality::integer
  FROM unnest(selected_bills) WITH ordinality AS x(bill_id, ordinality);

  RETURN new_set_id;
END;
$$;

-- 2. Run the function to publish the new game set
SELECT private.publish_latest_game_set();
