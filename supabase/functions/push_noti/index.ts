import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import * as OneSignal from "https://esm.sh/@onesignal/node-onesignal@1.0.0-beta7";
import * as postgres from "https://deno.land/x/postgres@v0.14.2/mod.ts";

const databaseUrl = Deno.env.get("SUPABASE_DB_URL")!;
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
  const { record, table, type } = await req.json();
  const connection = await pool.connect();
  try {
    if (table == "user_journey") {
      const notification = new OneSignal.Notification();
      if (type == "INSERT") {
        const result =
          await connection.queryObject`SELECT full_name, journey.owner FROM user_journey, journey, profile WHERE journey.journey_id = ${record.journey_id} and profile.id = ${record.user_id}`;
        const selected = result.rows[0];
        notification.app_id = _OnesignalAppId_;
        notification.include_external_user_ids = [selected.owner];
        notification.contents = {
          en: `${selected.full_name} request to join your journey.`,
        };
        notification.headings = {
          en: `New join request!`,
        };
      } else if (type == "UPDATE") {
        const result =
          await connection.queryObject`SELECT full_name FROM user_journey, journey, profile WHERE user_journey.journey_id = ${record.journey_id} and journey.journey_id = ${record.journey_id} and profile.id = journey.owner`;
        const selected = result.rows[0];
        notification.app_id = _OnesignalAppId_;
        notification.include_external_user_ids = [record.user_id];
        if (record.status == "accepted") {
          notification.contents = {
            en: `The journey from ${selected.full_name} is accepted, please paid to be confirmed.`,
          };
          notification.headings = {
            en: `Request accepted!`,
          };
        } else if (record.status == "paid") {
          notification.contents = {
            en: `You have paid for the journey from ${selected.full_name}, your journey request is confirmed`,
          };
          notification.headings = {
            en: `Payment succeed!`,
          };
        } else if (record.status == "finished") {
          notification.contents = {
            en: `The journey from ${selected.full_name} is arrived, please review to complete the journey.`,
          };
          notification.headings = {
            en: `Journey arrived!`,
          };
        }
      }
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
