---
description: Build and Deploy Zanoo Web to Vercel
---

This workflow automates the process of building the release version of the Flutter web application and deploying it to Vercel production.

// turbo-all

1. Build the Flutter Web Application
   We need to build the project in release mode to ensure it's optimized for production.
   
   Command: `flutter build web --release --no-tree-shake-icons`
   Cwd: `c:\proyectos_apps\zanoo\app_roffo`

2. Deploy to Vercel (Production)
   Deploy the `build/web` folder to Vercel.
   
   Command: `vercel deploy --prod`
   Cwd: `c:\proyectos_apps\zanoo\app_roffo`
