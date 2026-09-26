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
 - `src/utils/srsService.js`: FSRS scheduling and Supabase persistence.
 - `migration/28_srs_fsrs_tables.sql`: SRS database tables and policies.

## React Compiler

The React Compiler is not enabled on this template because of its impact on dev & build performances. To add it, see [this documentation](https://react.dev/learn/react-compiler/installation).

## Expanding the ESLint configuration

If you are developing a production application, we recommend using TypeScript with type-aware lint rules enabled. Check out the [TS template](https://github.com/vitejs/vite/tree/main/packages/create-vite/template-react-ts) for information on how to integrate TypeScript and [`typescript-eslint`](https://typescript-eslint.io) in your project.
