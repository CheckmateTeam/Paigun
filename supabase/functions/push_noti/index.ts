import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import * as OneSignal from "https://esm.sh/@onesignal/node-onesignal@1.0.0-beta7";
import * as postgres from "https://deno.land/x/postgres@v0.14.2/mod.ts";

//const databaseUrl = Deno.env.get('postgresql://postgres:Paigun30062023@db.rnkpkbfkrscmxfhjxlcs.supabase.co:5432/postgres')!
const databaseUrl =
  "postgresql://postgres:Paigun30062023@db.rnkpkbfkrscmxfhjxlcs.supabase.co:5432/postgres";
const pool = new postgres.Pool(databaseUrl, 3, true);

const _OnesignalAppId_ = Deno.env.get("ONESIGNAL_APP_ID")!;
const _OnesignalUserAuthKey_ = Deno.env.get("USER_AUTH_KEY")!;
const _OnesignalRestApiKey_ = Deno.env.get("ONESIGNAL_REST_API_KEY")!;
const configuration = OneSignal.createConfiguration({
  userKey: _OnesignalUserAuthKey_,
  appKey: _OnesignalRestApiKey_,
});

const onesignal = new OneSignal.DefaultApi(configuration);
//console.log("HEELOO TESTTEST");

serve(async (req) => {
  const { record, table } = await req.json();
  const connection = await pool.connect();
  try {
    if (table == "board") {
      const notification = new OneSignal.Notification();
      notification.app_id = _OnesignalAppId_;
      notification.include_external_user_ids = [record.owner];
      notification.contents = {
        en: `Your journey is from ${record.origin}!`,
      };
      const onesignalApiRes = await onesignal.createNotification(notification);

      return new Response(
        JSON.stringify({ onesignalResponse: onesignalApiRes }),
        {
          headers: {
            "Content-Type": "application/json",
            Authorization:
              "Basic N2VkMmM1NjUtZTkyMy00ZTVkLTlhZTMtZDY2YTkzODI0YmMw",
          },
        }
      );
    } else if (table == "journey") {
      const notification = new OneSignal.Notification();
      notification.app_id = _OnesignalAppId_;
      notification.include_external_user_ids = [record.owner];
      notification.headings = {
        en: `Status changed`,
      };
      notification.contents = {
        en: `Your journey just change the status to ${record.status}!`,
      };
      const onesignalApiRes = await onesignal.createNotification(notification);

      return new Response(
        JSON.stringify({ onesignalResponse: onesignalApiRes }),
        {
          headers: {
            "Content-Type": "application/json",
            Authorization:
              "Basic N2VkMmM1NjUtZTkyMy00ZTVkLTlhZTMtZDY2YTkzODI0YmMw",
          },
        }
      );
    } else if (table == "user_journey") {
      const result =
        await connection.queryObject`SELECT full_name, journey.owner FROM user_journey, journey, profile WHERE journey.journey_id = ${record.journey_id} and profile.id = ${record.user_id}`;
      const selected = result.rows[0]; // [{ id: 1, name: "Lion" }, ...]
      //console.log(result);
      //console.log(selected);
      const notification = new OneSignal.Notification();
      notification.app_id = _OnesignalAppId_;
      notification.include_external_user_ids = [selected.owner];
      notification.contents = {
        en: `${selected.full_name} request to join your journey.`,
      };
      notification.headings = {
        en: `New join request!`,
      };
      const onesignalApiRes = await onesignal.createNotification(notification);

      return new Response(
        JSON.stringify({ onesignalResponse: onesignalApiRes }),
        {
          headers: {
            "Content-Type": "application/json",
            Authorization:
              "Basic N2VkMmM1NjUtZTkyMy00ZTVkLTlhZTMtZDY2YTkzODI0YmMw",
          },
        }
      );
    } else if (table == "document") {
      if (
        record.citizen_url != null &&
        record.driver_url != null &&
        record.tax_url != null
      ) {
        // Build OneSignal notification object
        const notification = new OneSignal.Notification();
        notification.app_id = _OnesignalAppId_;
        notification.include_external_user_ids = [record.owner];
        notification.headings = {
          en: `Driver mode verified!`,
        };
        notification.contents = {
          en: `Your driver mode has been verified.`,
        };
        const onesignalApiRes = await onesignal.createNotification(
          notification
        );

        return new Response(
          JSON.stringify({ onesignalResponse: onesignalApiRes }),
          {
            headers: {
              "Content-Type": "application/json",
              Authorization:
                "Basic N2VkMmM1NjUtZTkyMy00ZTVkLTlhZTMtZDY2YTkzODI0YmMw",
            },
          }
        );
      } else if (
        record.citizen_url != null &&
        record.driver_url == null &&
        record.tax_url == null
      ) {
        // Build OneSignal notification object
        const notification = new OneSignal.Notification();
        notification.app_id = _OnesignalAppId_;
        notification.include_external_user_ids = [record.owner];
        notification.headings = {
          en: `Account verified!`,
        };
        notification.contents = {
          en: `Your account has been verified.`,
        };
        const onesignalApiRes = await onesignal.createNotification(
          notification
        );

        return new Response(
          JSON.stringify({ onesignalResponse: onesignalApiRes }),
          {
            headers: {
              "Content-Type": "application/json",
              Authorization:
                "Basic N2VkMmM1NjUtZTkyMy00ZTVkLTlhZTMtZDY2YTkzODI0YmMw",
            },
          }
        );
      }
    }
  } catch (err) {
    console.error("Failed to create OneSignal notification", err);
    return new Response("Server error.", {
      headers: { "Content-Type": "application/json" },
      status: 400,
    });
  } finally {
    connection.release();
  }
});

// // Follow this setup guide to integrate the Deno language server with your editor:
// // https://deno.land/manual/getting_started/setup_your_environment
// // This enables autocomplete, go to definition, etc.
// import { createClient } from '@supabase/supabase-js'
// import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
// console.log("Hello from Functions!")
// const supabase = createClient('https://rnkpkbfkrscmxfhjxlcs.supabase.co/functions/v1/push_noti', 'public-anon-key')

// serve(async (req) => {
//   const { name } = await req.json()
//   const data = {
//     message: `Hello ${name}!`,
//   }

//   return new Response(
//     JSON.stringify(data),
//     { headers: { "Content-Type": "application/json" } },
//   )
// })

// // To invoke:
// curl -i --location --request POST 'https://rnkpkbfkrscmxfhjxlcs.supabase.co/functions/v1/push_noti'
//   --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0'
//   --header 'Content-Type: application/json'
//   --data '{"name":"Functions"}'
//   --body '{"app_id": "0566bb92-013b-4e29-aea9-af136bc546fd","included_segments": ["Subscribed Users"],"data": {"foo": "bar"},"contents": {"en": "Sample push Message"}}'

// // To invoke:
// curl -i --location --request POST 'http://localhost:54321/functions/v1/' \
//   --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0' \
//   --header 'Content-Type: application/json' \
//   --data '{"name":"Functions"}'
