# Global Sound Universe setup

## Supabase
1. Open the Supabase project connected to this app.
2. Run `supabase/schema.sql` in the SQL Editor.
3. Copy the project URL and publishable (or legacy anon) key from Project Settings → API.
4. Add the publishable key to `SUPABASE_PUBLISHABLE_KEY` in `index.html`.
5. Configure email confirmation and authentication redirect URLs.
6. Never expose a service_role key, AI secret, or payment secret in browser code.

## GitHub Pages
1. Open repository Settings → Pages.
2. Choose Deploy from a branch.
3. Select `main` and `/(root)`, then Save.
4. Wait for GitHub's deployment status before opening the published URL.

## Production requirements
- A trusted backend for AI, moderation, admin operations, uploads, and coin transactions.
- Private storage buckets and signed URLs for protected audio.
- Payment-provider webhooks; never credit G.S Coins from frontend JavaScript.
- Music recording and composition licences for every streamable track.
- Backups, rate limits, monitoring, account recovery, privacy policy, terms, and security testing.
- A dedicated real-time audio/video provider and moderation workflow for live rooms.

## Android
After HTTPS hosting is stable, package the site with a trusted Android WebView wrapper or PWA/TWA. Test file upload, audio focus, background playback, navigation, and small-screen layouts on a real Android device.

## Current demo limitations
The HTML includes local audio import and prepared AI guidance. The catalogue cards are demo content. Real cloud streaming, live broadcasts, payments, and generative AI are not active until their services and credentials are configured.
