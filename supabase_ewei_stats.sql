-- ============================================================
-- E版 首屏計數器 所需函式 + 點閱表
-- 專案：hjewpxgnxilezpbcjnzr (TAEBDC 報名系統同一個 Supabase)
-- 貼法見妹妹說明。本檔與 supabase_counter_setup.sql 擇一即可，
-- 本版函式名稱與 index.html 的 JS 完全對應。
-- ============================================================

-- 1) 網站點閱計數表（同一天只算一次，避免狂刷新灌水）
CREATE TABLE IF NOT EXISTS page_views (
    view_date DATE PRIMARY KEY DEFAULT CURRENT_DATE,
    count INTEGER NOT NULL DEFAULT 0
);

-- 2) RPC：報名數 + 已分享電子書數（從 event_signups 即時統計）
--    電子書：books JSONB 陣列長度 + 若有 book4_title 再 +1
CREATE OR REPLACE FUNCTION get_event_stats()
RETURNS JSONB
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
    SELECT jsonb_build_object(
        'signups',
        (SELECT COUNT(*) FROM event_signups WHERE status != 'draft'),
        'books',
        (SELECT COALESCE(SUM(
            COALESCE(jsonb_array_length(books), 0)
            + CASE WHEN book4_title IS NOT NULL AND book4_title <> '' THEN 1 ELSE 0 END
        ), 0) FROM event_signups)
    );
$$;

-- 3) RPC：+1 當日點閱並回傳新總數（UPSERT 同日累加）
CREATE OR REPLACE FUNCTION bump_page_view()
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v INTEGER;
BEGIN
    INSERT INTO page_views (view_date, count)
    VALUES (CURRENT_DATE, 1)
    ON CONFLICT (view_date) DO UPDATE SET count = page_views.count + 1
    RETURNING count INTO v;
    RETURN v;
END;
$$;

-- 4) RPC：讀取當前點閱總數（同一瀏覽器同日已計過時用這支顯示）
CREATE OR REPLACE FUNCTION get_page_views()
RETURNS INTEGER
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
    SELECT COALESCE((SELECT count FROM page_views WHERE view_date = CURRENT_DATE), 0);
$$;

-- 5) 授權給匿名（網頁公開呼叫）
GRANT EXECUTE ON FUNCTION get_event_stats() TO anon, authenticated;
GRANT EXECUTE ON FUNCTION bump_page_view() TO anon, authenticated;
GRANT EXECUTE ON FUNCTION get_page_views() TO anon, authenticated;

-- 6) RLS：page_views 禁止匿名直接讀寫，只能走 RPC
ALTER TABLE page_views ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "no direct access page_views" ON page_views;
CREATE POLICY "no direct access page_views" ON page_views FOR ALL USING (false) WITH CHECK (false);

-- ============================================================
-- 貼完執行這三行驗證（可一起貼，看結果）：
--   SELECT get_event_stats();   -- 應回 {"books":N,"signups":N}
--   SELECT bump_page_view();    -- 應回 1（再跑一次變 2）
--   SELECT get_page_views();    -- 應回當日總數
-- ============================================================
