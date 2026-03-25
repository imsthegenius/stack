import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", {
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers":
          "authorization, x-client-info, apikey, content-type",
      },
    });
  }

  try {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(JSON.stringify({ error: "Missing auth token" }), {
        status: 401,
        headers: { "Content-Type": "application/json" },
      });
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY")!;
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

    // Verify the user's JWT
    const userClient = createClient(supabaseUrl, supabaseAnonKey, {
      global: { headers: { Authorization: authHeader } },
    });

    const {
      data: { user },
      error: userError,
    } = await userClient.auth.getUser();

    if (userError || !user) {
      return new Response(JSON.stringify({ error: "Invalid token" }), {
        status: 401,
        headers: { "Content-Type": "application/json" },
      });
    }

    // Revoke Apple Sign in with Apple token (required by Apple Guideline 5.1.1v)
    let body: { apple_auth_code?: string } = {};
    try {
      body = await req.json();
    } catch {
      // No body or invalid JSON — proceed without revocation
    }

    if (body.apple_auth_code) {
      try {
        await revokeAppleToken(body.apple_auth_code);
      } catch (e) {
        console.error("Apple token revocation failed (non-blocking):", e);
        // Don't block account deletion if revocation fails
      }
    }

    // Delete user (cascades to user_data via FK)
    const adminClient = createClient(supabaseUrl, supabaseServiceKey);
    const { error: deleteError } =
      await adminClient.auth.admin.deleteUser(user.id);

    if (deleteError) {
      return new Response(
        JSON.stringify({ error: "Failed to delete account" }),
        {
          status: 500,
          headers: { "Content-Type": "application/json" },
        }
      );
    }

    return new Response(JSON.stringify({ success: true }), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    });
  } catch {
    return new Response(JSON.stringify({ error: "Internal server error" }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
});

async function revokeAppleToken(authCode: string): Promise<void> {
  const clientId = Deno.env.get("APPLE_CLIENT_ID"); // com.twohundred.stack
  const teamId = Deno.env.get("APPLE_TEAM_ID");
  const keyId = Deno.env.get("APPLE_KEY_ID");
  const privateKey = Deno.env.get("APPLE_PRIVATE_KEY"); // PEM format, newlines as \n

  if (!clientId || !teamId || !keyId || !privateKey) {
    console.warn("Apple revocation env vars not set — skipping revocation");
    return;
  }

  // Generate client_secret JWT
  const clientSecret = await generateAppleClientSecret(
    clientId,
    teamId,
    keyId,
    privateKey
  );

  // Exchange authorization code for a refresh token
  const tokenResponse = await fetch("https://appleid.apple.com/auth/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      client_id: clientId,
      client_secret: clientSecret,
      code: authCode,
      grant_type: "authorization_code",
    }),
  });

  if (!tokenResponse.ok) {
    const err = await tokenResponse.text();
    console.error("Apple token exchange failed:", err);
    // Auth code may be expired (single-use, 5min TTL) — this is expected
    // if the user signed in a while ago. Not a blocking issue.
    return;
  }

  const tokenData = await tokenResponse.json();
  const refreshToken = tokenData.refresh_token;

  if (!refreshToken) {
    console.warn("No refresh_token from Apple — cannot revoke");
    return;
  }

  // Revoke the refresh token
  const revokeResponse = await fetch("https://appleid.apple.com/auth/revoke", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      client_id: clientId,
      client_secret: clientSecret,
      token: refreshToken,
      token_type_hint: "refresh_token",
    }),
  });

  if (!revokeResponse.ok) {
    const err = await revokeResponse.text();
    throw new Error(`Apple token revocation failed: ${err}`);
  }

  console.log("Apple token revoked successfully");
}

async function generateAppleClientSecret(
  clientId: string,
  teamId: string,
  keyId: string,
  privateKeyPem: string
): Promise<string> {
  const now = Math.floor(Date.now() / 1000);
  const header = { alg: "ES256", kid: keyId };
  const payload = {
    iss: teamId,
    iat: now,
    exp: now + 15777000, // 6 months
    aud: "https://appleid.apple.com",
    sub: clientId,
  };

  const encodedHeader = base64urlEncode(JSON.stringify(header));
  const encodedPayload = base64urlEncode(JSON.stringify(payload));
  const signingInput = `${encodedHeader}.${encodedPayload}`;

  // Import the private key
  const pemBody = privateKeyPem
    .replace(/-----BEGIN PRIVATE KEY-----/g, "")
    .replace(/-----END PRIVATE KEY-----/g, "")
    .replace(/\\n/g, "")
    .replace(/\s/g, "");

  const keyData = Uint8Array.from(atob(pemBody), (c) => c.charCodeAt(0));

  const key = await crypto.subtle.importKey(
    "pkcs8",
    keyData,
    { name: "ECDSA", namedCurve: "P-256" },
    false,
    ["sign"]
  );

  const signature = await crypto.subtle.sign(
    { name: "ECDSA", hash: "SHA-256" },
    key,
    new TextEncoder().encode(signingInput)
  );

  // Convert DER signature to raw r||s format for JWT
  const rawSig = derToRaw(new Uint8Array(signature));
  const encodedSignature = base64urlEncode(
    String.fromCharCode(...rawSig)
  );

  return `${signingInput}.${encodedSignature}`;
}

function base64urlEncode(str: string): string {
  return btoa(str).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
}

function derToRaw(der: Uint8Array): Uint8Array {
  // ECDSA DER signature: 0x30 <len> 0x02 <rlen> <r> 0x02 <slen> <s>
  const raw = new Uint8Array(64);
  let offset = 2; // skip 0x30 and length byte

  // Handle case where length byte itself takes 2 bytes
  if (der[1] > 128) offset = 3;

  offset += 1; // skip 0x02
  const rLen = der[offset];
  offset += 1;
  const rStart = rLen > 32 ? offset + (rLen - 32) : offset;
  const rTargetStart = rLen < 32 ? 32 - rLen : 0;
  raw.set(der.slice(rStart, offset + rLen), rTargetStart);
  offset += rLen;

  offset += 1; // skip 0x02
  const sLen = der[offset];
  offset += 1;
  const sStart = sLen > 32 ? offset + (sLen - 32) : offset;
  const sTargetStart = sLen < 32 ? 32 + (32 - sLen) : 32;
  raw.set(der.slice(sStart, offset + sLen), sTargetStart);

  return raw;
}
