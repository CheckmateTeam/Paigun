import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import * as OneSignal from "https://esm.sh/@onesignal/node-onesignal@1.0.0-beta7";

const _OnesignalAppId_ = Deno.env.get("ONESIGNAL_APP_ID")!;
const _OnesignalUserAuthKey_ = Deno.env.get("USER_AUTH_KEY")!;
const _OnesignalRestApiKey_ = Deno.env.get("ONESIGNAL_REST_API_KEY")!;
const configuration = OneSignal.createConfiguration({
  userKey: _OnesignalUserAuthKey_,
  appKey: _OnesignalRestApiKey_,
});

const onesignal = new OneSignal.DefaultApi(configuration);

serve(async (req) => {
  try {
    const { record } = await req.json();
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
    }
  } catch (err) {
    console.error("Failed to create OneSignal notification", err);
    return new Response("Server error.", {
      headers: { "Content-Type": "application/json" },
      status: 400,
    });
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
