# React + Vite

This template provides a minimal setup to get React working in Vite with HMR and some ESLint rules.

 # JLPT Reviewer
 
 React + Vite + Supabase app for JLPT vocabulary, grammar, reading, and Anki-style SRS review.
 
 ## Setup in VS Code
 
 1. Extract this ZIP to a normal project folder, for example `C:\Projects\jlpt-reviewer`.
 2. Open that extracted folder in VS Code. Open the folder itself, not the ZIP file.
 3. Install Node.js LTS if it is not installed yet.
 4. Open the VS Code terminal and run:
 
	 ```powershell
	 npm install
	 npm run dev
	 ```
 
 5. Open the local URL printed by Vite, usually `http://localhost:5173`.
 
 ## Environment variables
 
 Copy `.env.example` to `.env` and replace the placeholders with the existing project values:
 
 ```env
 VITE_SUPABASE_URL=your_supabase_project_url
 VITE_SUPABASE_ANON_KEY=your_supabase_anon_key
 VITE_GEMINI_API_KEY=your_gemini_api_key
 ```
 
 Do not upload `.env` to GitHub or send it in a ZIP. Vite exposes `VITE_*` values to the browser, so use only the Supabase anon key here, never a Supabase service-role key.
 
 ## Supabase database
 
 Run the SQL files in `migration/` in their numbered order when setting up a new database. For the SRS feature, make sure `migration/28_srs_fsrs_tables.sql` has been run. Vocabulary upload migrations can be run afterward.
 
 ## Verify before deployment
 
 ```powershell
 npm run lint
 npm run build
 ```

## First SRS session at home: Mimikara L1-L15

The goal of the first session is to **triage** the 300 Mimikara words from L1-L15. You are not expected to memorize all 300 tonight. You are telling the app which words are already known and which words need spaced repetition.

1. Open the app and go to `Review`.
2. Select `SRS (Anki)`.
3. Under `New cards source`, choose:
	- Book: `耳から覚える`
	- From: `L1`
	- To: `L15`
	- New / day: `40`
	- Target retention: `90%`
4. Click `Start Today's Review`.
5. For every card, reveal the answer and choose honestly:
	- `Known - don't show again`: you know the reading and meaning confidently. This is the button that marks the word as Known.
	- `Easy`: you know it, but want the app to review it occasionally.
	- `Good`: you recalled it correctly with normal effort.
	- `Hard`: you recalled it, but with hesitation.
	- `Again`: you could not recall it. This is the equivalent of “I don't know.”

### What does 40 mean?

`40` is the maximum number of cards that are genuinely unfamiliar that can enter active learning today. `Known` and `Easy` do not consume that quota.

For example, if you scan 300 cards and mark 290 as `Known` or `Easy`, while only 10 need `Again`, `Hard`, or `Good`, then only those 10 become active SRS cards. The app can still scan the rest of the selected L1-L15 cards; it does not force you to find 30 more difficult words.

If more than 40 cards are unfamiliar, stop when the session reaches the quota. The remaining unseen cards will be available on a later day. Do not change the source to L16-L20 until you have studied those lessons in the book.

### After the first triage

- Do not repeat all of L1-L15 in the old `Flashcard` mode. That mode remains optional practice and does not control the SRS schedule.
- On the next study day, finish the red `Learning` and green `Review` cards first.
- Then study the next Mimikara lesson in the book, for example L16-L17.
- Change the SRS source to `From: L16`, `To: L17`, keep `New / day: 40`, and grade those cards normally.
- Read and listen to the lesson before adding it to SRS. Use `Known` only for words you can confidently recognize, not words that merely look familiar after repeated cramming.

The long-term routine is: **due reviews first, then the next lesson, then reading/listening practice**. The app remembers the intervals, so you no longer need to manually revisit every earlier lesson.

### Stats: Overview and Words

Open **Stats** for two tabs: **Overview** and **Words**. Review stays focused on
the daily queue, settings, and starting a session.
The Overview leads with coverage, cards due through today, and tomorrow's workload.
Select those counts, a forecast day, unseen uploaded words, leeches, or Review Debt
to open the corresponding Words filter. The overview's book filter and word lists
use the same collection and 4 AM boundaries; Review Debt is explicitly all-books.

The Words tab supports book, lesson, status, word/reading/meaning search, sorting,
and pagination. Select a word for a read-only panel with reading, meaning,
pronunciation, examples, book/lesson memberships, current schedule, repetitions,
lapses, and paginated SRS rating history. Browsing never rates or schedules a card.
Words not uploaded yet are reported separately, never fabricated in the list.
Known/suspended words have no active due date and marking Known does not log a rating.

Completion ETA, effective acquisition, and exam projection live under
**Estimates and exam plan**, not the primary metrics. Practice activity and recent
sessions are a separate expandable section: legacy mastery/accuracy scores are
not FSRS states, and that section has its own level filter.

No additional database migration is needed beyond the existing SRS migration.
Book targets and exam date are saved per account in `profiles.srs_settings`.
Mimikara defaults to a full-book target of **880 words** and the exam date defaults
to **2026-12-06**. Both are editable; other books default to uploaded-word coverage.
Plan edits require **Save exam plan**. Stats book selection is independent of
the Review source and is never saved over it. Refresh reloads the snapshot.

- Coverage and introduction pace include Easy and Known words and ignore the source lesson filter.
- ETA uses actual introductions over the last seven study days, including today and zero-activity days, not the daily learning quota.
- Effective acquisition uses today's unfamiliar new cards (Again/Hard/Good first ratings) times observed book retention.
- Retention uses review-state ratings over seven rolling days and requires 30 ratings; Again is a failure.
- Observed retention **below 75%** caps new learning at **15/day**, or the configured quota if lower. At 75% or higher, retention alone does not throttle new cards. This safety threshold is separate from the FSRS target-retention setting.
- Forecast follows the selected Stats book, including learning/relearning cards. Review Debt always covers all books. Debt is cards due through today's study-day end plus the next three days' scheduled cards. Over **250** debt automatically caps new learning at **15/day**, or the configured quota if lower. Existing backlog/retention throttles still apply.
- Exam coverage assumes the same introduction pace and availability of all target words. Retention is an explicitly labeled unchanged-observed-retention assumption, not a prediction. Scheduled cards through the exam include backlog but exclude future repeat reviews and future introductions; they are not an estimated total review count.
- Leeches have at least six review lapses; repeated learning-step failures are not the same as lapses.
- All daily buckets use the existing **4 AM local-time** study-day boundary.

Validate the dashboard calculations with `node --test src\utils\srsMetrics.test.js`.
 
## Deploy to Vercel

If GitHub contains only this ZIP file, download and extract it first. Vercel cannot deploy a ZIP file as the app source directly.

From the extracted project folder, run:

```powershell
npm install
npx vercel login
npx vercel
```

Answer the prompts, then use `npx vercel --prod` for the production deployment. Vercel detects Vite automatically. If you later upload the extracted project files to a GitHub repository, you can import that repository in the Vercel dashboard instead.

Add these Environment Variables in Vercel:
	 - `VITE_SUPABASE_URL`
	 - `VITE_SUPABASE_ANON_KEY`
	 - `VITE_GEMINI_API_KEY`

Redeploy after changing environment variables.
 
 ## Important files
 
 - `src/components/FlashCardMode.jsx`: original lesson practice mode.
 - `src/components/SrsPanel.jsx`: Today review setup and daily new-card settings.
 - `src/components/SrsReview.jsx`: Anki-style review session.
 - `src/components/StatsDashboard.jsx`: Stats tabs, snapshot loading, filters, and exam-plan saving.
 - `src/components/SrsWords.jsx`: searchable SRS word collection.
 - `src/components/SrsWordDetails.jsx`: read-only word details and rating history.
 - `src/utils/srsService.js`: FSRS scheduling and Supabase persistence.
 - `migration/28_srs_fsrs_tables.sql`: SRS database tables and policies.

## React Compiler

The React Compiler is not enabled on this template because of its impact on dev & build performances. To add it, see [this documentation](https://react.dev/learn/react-compiler/installation).

## Expanding the ESLint configuration

If you are developing a production application, we recommend using TypeScript with type-aware lint rules enabled. Check out the [TS template](https://github.com/vitejs/vite/tree/main/packages/create-vite/template-react-ts) for information on how to integrate TypeScript and [`typescript-eslint`](https://typescript-eslint.io) in your project.
