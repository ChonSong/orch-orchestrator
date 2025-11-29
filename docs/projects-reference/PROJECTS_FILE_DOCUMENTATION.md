# Projects File Documentation

## Individual Project File Analysis

This section documents all non-md files within each project directory to maintain clarity during cleanup operations.

---

## 1. ecommerce-dash/ (897MB)

### Configuration Files
- `package.json` - Project dependencies and scripts
- `next.config.js` - Next.js framework configuration
- `tailwind.config.js` - Tailwind CSS configuration
- `tsconfig.json` - TypeScript configuration
- `.eslintrc.json` - ESLint linting rules
- `.gitignore` - Git ignore patterns
- `README.md` - *excluded (documentation)*

### Source Code
- `src/app/layout.tsx` - Next.js layout component
- `src/app/page.tsx` - Main dashboard page
- `src/app/globals.css` - Global styles
- `src/app/api/` - API route handlers
- `src/components/` - React components directory
- `src/lib/` - Utility libraries
- `src/types/` - TypeScript type definitions

### Static Assets
- `public/` - Static files directory
  - `favicon.ico` - Site favicon
  - `logo.png` - Application logo
  - `icons/` - Icon assets

### Build Artifacts (Safe to Remove)
- `.next/cache/` - 182MB Next.js build cache
- `.swc/` - SWC compiler cache
- `next-env.d.ts` - Next.js TypeScript definitions

### Dependencies
- `node_modules/` - 711MB Node.js dependencies

**Critical Files**: package.json, src/, public/
**Removable**: .next/cache/, .swc/

---

## 2. global-news-ai/ (762MB)

### Configuration Files
- `package.json` - AI news application dependencies
- `next.config.js` - Next.js configuration with AI integrations
- `tailwind.config.js` - Styling configuration
- `tsconfig.json` - TypeScript setup
- `.env.local` - Environment variables (AI API keys)
- `.gitignore` - Git ignore patterns

### Source Code
- `src/app/layout.tsx` - Application layout
- `src/app/page.tsx` - News aggregation page
- `src/components/` - React components
- `src/lib/ai/` - AI integration modules
- `src/lib/news/` - News processing logic
- `src/types/` - TypeScript definitions

### Static Assets
- `public/` - Static assets
- `public/icons/` - Application icons
- `public/images/` - News-related images

### Build Artifacts (Safe to Remove)
- `.next/cache/` - Next.js build cache
- `.next/server/` - Server-side build artifacts

### Dependencies
- `node_modules/` - 732MB Node.js dependencies (includes AI libraries)

**Critical Files**: package.json, src/, .env.local, public/
**Removable**: .next/cache/, build artifacts

---

## 3. ecotracker-app/ (386MB)

### Configuration Files
- `package.json` - Eco-tracking application dependencies
- `vite.config.ts` - Vite build configuration
- `tsconfig.json` - TypeScript configuration
- `tailwind.config.js` - Tailwind CSS setup
- `.gitignore` - Git ignore rules

### Source Code
- `src/` - Vue/React application source
  - `main.tsx` - Application entry point
  - `App.tsx` - Main application component
  - `components/` - UI components
  - `views/` - Application views/pages
  - `utils/` - Utility functions
  - `api/` - API integration

### Build Output (Conditional)
- `dist/` - 712KB built application
  - `index.html` - Main HTML file
  - `assets/` - CSS/JS bundles
  - `favicon.ico` - Site icon

### Dependencies
- `node_modules/` - 385MB Node.js dependencies

**Critical Files**: package.json, src/, dist/ (if in production)
**Removable**: dist/ (can be rebuilt), cache files

---

## 4. nebula-ui/ (312MB)

### Configuration Files
- `package.json` - UI component library configuration
- `rollup.config.js` - Bundle configuration
- `tsconfig.json` - TypeScript setup
- `tailwind.config.js` - CSS framework configuration
- `.storybook/` - Storybook configuration directory

### Source Code
- `src/` - Component library source
  - `index.ts` - Library entry point
  - `components/` - UI components
  - `utils/` - Component utilities
  - `types/` - Component prop types
  - `styles/` - Component-specific styles

### Build Output (Conditional)
- `dist/` - 60KB built component library
  - Component bundles and type definitions

### Documentation
- `.storybook/` - Storybook setup
- `stories/` - Component stories

### Dependencies
- `node_modules/` - 299MB Node.js dependencies

**Critical Files**: package.json, src/, dist/ (published library)
**Removable**: .storybook/ (if not used), cache files

---

## 5. sean-s-landing-page/ (249MB)

### Configuration Files
- `package.json` - Landing page dependencies
- `next.config.js` - Next.js configuration
- `tailwind.config.js` - CSS configuration
- `tsconfig.json` - TypeScript setup

### Source Code
- `src/` - Landing page source
  - `app/` - Next.js app directory
  - `components/` - Page components
  - `styles/` - Custom styles
  - `lib/` - Utility functions

### Static Assets
- `public/` - Static assets
  - `images/` - Portfolio and personal images
  - `resume.pdf` - Resume document
  - `favicon.ico` - Site favicon

### Build Output (Conditional)
- `dist/` - 432KB built landing page
- `out/` - Static export directory

### Dependencies
- `node_modules/` - 247MB Node.js dependencies

**Critical Files**: package.json, src/, public/
**Removable**: dist/, out/, cache files

---

## 6. portfolio-hub/ (177MB)

### Configuration Files
- `package.json` - Portfolio management configuration
- `vite.config.ts` - Vite build setup
- `tsconfig.json` - TypeScript configuration

### Source Code
- `src/` - Portfolio application source
  - `main.tsx` - Application entry
  - `App.tsx` - Main app component
  - `components/` - Portfolio components
  - `pages/` - Portfolio pages
  - `api/` - API integration

### Build Output (Conditional)
- `dist/` - 432KB built portfolio application

### Dependencies
- `node_modules/` - 176MB Node.js dependencies

**Critical Files**: package.json, src/, dist/ (if deployed)
**Removable**: dist/ (can be rebuilt)

---

## 7. h2h/ (131MB)

### Configuration Files
- `package.json` - H2H application setup
- `webpack.config.js` - Webpack configuration
- `.babelrc` - Babel transpiler configuration

### Source Code
- `src/` - H2H application source
- `public/` - Static assets

### Build Output (Conditional)
- `dist/` - 524KB built H2H application

### Dependencies
- `node_modules/` - 131MB Node.js dependencies

**Critical Files**: package.json, src/, public/
**Removable**: dist/, cache files

---

## 8. hyperspeed/ (64MB)

### Configuration Files
- `package.json` - Performance optimization tool
- `rollup.config.js` - Build configuration

### Source Code
- `src/` - Hyperspeed utility source
- `bin/` - Executable scripts

### Build Output (Conditional)
- `dist/` - 636KB built hyperspeed tool

### Dependencies
- `node_modules/` - 64MB Node.js dependencies

**Critical Files**: package.json, src/, bin/
**Removable**: dist/, cache files

---

## 9. realtime-sync-server/ (67MB)

### Configuration Files
- `package.json` - Realtime sync server configuration
- `server.js` - Main server file
- `socket.config.js` - Socket.IO configuration

### Source Code
- `src/` - Server source code
  - `socket/` - Socket handlers
  - `api/` - API routes
  - `utils/` - Server utilities

### Dependencies
- `node_modules/` - 67MB Node.js dependencies

**Critical Files**: package.json, server.js, src/
**Removable**: logs/, cache files

---

## 10. codeserver-sync-client/ (39MB)

### Configuration Files
- `package.json` - Code-server sync client
- `vite.config.ts` - Vite configuration

### Source Code
- `src/` - Sync client source
  - `client.js` - Main sync client
  - `sync/` - Sync logic
  - `api/` - API integration

### Build Output (Conditional)
- `dist/` - 1.6MB built sync client

### Dependencies
- `node_modules/` - 39MB Node.js dependencies

**Critical Files**: package.json, src/
**Removable**: dist/, cache files

---

## Summary by File Type

### Configuration Files (KEEP ALL)
- All `package.json` files (10 projects)
- All `tsconfig.json` files
- All build configuration files (vite.config.*, webpack.config.*, next.config.js)
- All CSS framework configs (tailwind.config.js)

### Source Code (KEEP ALL)
- All `src/` directories and contents
- All main application files (main.tsx, App.tsx, server.js, etc.)
- All component directories

### Build Outputs (CONDITIONAL)
- All `dist/` directories (~4MB total)
- All `.next/cache/` directories (182MB)
- All `.swc/` directories
- All build cache directories

### Dependencies (KEEP FOR ACTIVE PROJECTS)
- All `node_modules/` directories (~3.6GB total)
- Consider dependency deduplication for future optimization

### Static Assets (KEEP ALL)
- All `public/` directories
- All images, icons, documents
- All asset directories

---

## Removal Priority

1. **Safe to Remove**: .next/cache/, .swc/, build artifacts
2. **Conditional**: dist/ directories (if not in production)
3. **Keep All**: Source code, configurations, dependencies
4. **Future Optimization**: node_modules/ deduplication