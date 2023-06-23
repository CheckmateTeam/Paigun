import * as postgres from "https://deno.land/x/postgres@v0.14.2/mod.ts";
import { serve } from "https://deno.land/std@0.177.0/http/server.ts";

const databaseUrl = Deno.env.get("SUPABASE_DB_URL")!;
const pool = new postgres.Pool(databaseUrl, 3, true);
const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey",
};

serve(async (req) => {
  const { url, method } = req;
  const u = new URL(url);
  const params = u.searchParams;

  console.log(method);
  console.log(req);

  if (method == "GET") {
    if (params.get("type") == "getjourney") {
      try {
        const connection = await pool.connect();
        try {
          const result = await connection.queryObject(
            "select * from journey where status='available' and owner!= $1 and available_seat>0",
            params.get("userid")
          );
          return new Response(JSON.stringify(result.rows), {
            headers: { "content-type": "application/json" },
          });
        } finally {
          await connection.release();
        }
      } catch (err) {
        console.error(err);
        return new Response(String(err?.message ?? err), { status: 500 });
      }
    } else if (params.get("type") == "getjourneyownerid") {
      try {
        const connection = await pool.connect();
        try {
          const result = await connection.queryobject(
            "select * from journey where owner=$1 order by id desc",
            params.get("userid")
          );
          return new Response(JSON.stringify(result.rows), {
            headers: { "content-type": "application/json" },
          });
        } finally {
          await connection.release();
        }
      } catch (err) {
        console.error(err);
        return new Response(String(err?.message ?? err), { status: 500 });
      }
    } else if (params.get("type") == "getuserprofile") {
      try {
        const connection = await pool.connect();
        try {
          const result = await connection.queryobject(
            "select * from journey where owner=$1 limit 1",
            params.get("userid")
          );
          return new Response(JSON.stringify(result.rows), {
            headers: { "content-type": "application/json" },
          });
        } finally {
          await connection.release();
        }
      } catch (err) {
        console.error(err);
        return new Response(String(err?.message ?? err), { status: 500 });
      }
    } else if (params.get("type") == "getjourneystatus") {
      try {
        const connection = await pool.connect();
        try {
          const result = await connection.queryobject(
            "select status from user_journey where user_id=$1 and journey_id=$2 limit 1",
            params.get("userid"),
            params.get("journeyid")
          );
          return new Response(JSON.stringify(result.rows[0]), {
            headers: { "content-type": "application/json" },
          });
        } finally {
          await connection.release();
        }
      } catch (err) {
        console.error(err);
        return new Response(String(err?.message ?? err), { status: 500 });
      }
    }
  }
});
