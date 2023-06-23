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
    if (params.get("type") == "getboard") {
      try {
        const connection = await pool.connect();
        try {
          const result = await connection.queryObject(
            "select * from board inner join profile on owner = id"
          );
          console.log(result);

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
    }
  } else if (method == "POST") {
    if (params.get("type") == "postboard") {
      try {
        const connection = await pool.connect();
        try {
          const result =
            await connection.queryArray`INSERT INTO board (owner, origin, destination, note, date) VALUES (${params.get(
              "owner"
            )}, ${params.get("origin")}, ${params.get(
              "destination"
            )}, ${params.get("note")}, ${params.get("date")})`;
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
