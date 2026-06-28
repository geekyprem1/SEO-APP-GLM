# ShortSEO AI - MVP PRD (Flutter)

You are a senior Flutter engineer and product architect.

Build a production-ready Flutter application called **ShortSEO AI**.

This is the **MVP (Version 1.0)**.

**Important:** Do NOT build any Premium, Pro, Subscription, Payment, or RevenueCat functionality. The app must be designed so Premium can be added later without changing the architecture.

## Goal

Help YouTube Shorts creators generate SEO content using AI.

The app should be fast, simple, modern, and production-ready.

---

# Tech Stack

* Flutter (Latest Stable)
* Riverpod
* GoRouter
* Dio
* Hive
* Material 3
* Firebase Authentication (Anonymous + Google Sign-In)
* Firestore
* Firebase Analytics
* Firebase Crashlytics
* OpenRouter API

---

# Features (MVP Only)

## Home Dashboard

Display cards for:

* Title Generator
* Hashtag Generator
* Description Generator
* Content Generator
* Viral Shorts Ideas
* Trending Topics
* Thumbnail Generator
* SEO Analysis
* History
* Settings

---

## Title Generator

Input:

* Topic
* Language

Output:

* 10 SEO-friendly titles

Actions:

* Copy
* Regenerate
* Save

---

## Hashtag Generator

Input:

* Topic

Output:

* 20 relevant hashtags

Actions:

* Copy
* Save

---

## Description Generator

Input:

* Topic

Output:

* SEO-friendly YouTube Shorts description

Actions:

* Copy
* Save

---

## Content Generator

Input:

* Topic

Output:

* Hook
* Main Content
* CTA

Actions:

* Copy
* Save

---

## Viral Shorts Ideas

Input:

* Category
* Language

Output:

* 20 viral content ideas

---

## Trending Topics

Input:

* Category
* Country
* Language

Output:

* Trending topic list generated using AI

---

## Thumbnail Generator

Input:

* Topic
* Category
* Style

Generate:

* AI thumbnail image

Actions:

* Download
* Regenerate

Use image generation through an API abstraction so providers can be changed later without affecting the UI.

---

## SEO Analysis

Input:

* YouTube Shorts URL

Analyze:

* Title
* Description
* Hashtags
* Basic SEO Score

Provide actionable improvement suggestions.

---

## History

Store locally using Hive.

Allow:

* Open
* Copy
* Delete

---

## Settings

* Dark Mode
* Light Mode
* Clear History
* App Version
* Privacy Policy
* Terms
* Contact Us

---

# Architecture

Use Feature-first Clean Architecture.

Each feature must contain:

* models
* repository
* services
* providers
* screens
* widgets

Business logic must never be inside UI widgets.

---

# Folder Structure

lib/

core/
config/
models/
services/
widgets/
utils/

features/
home/
title/
hashtags/
description/
content/
viral_ideas/
trending/
thumbnail/
seo/
history/
settings/

---

# AI Layer

Create one reusable AI service.

All generators must call this service.

Changing the AI provider should require changing only one file.

---

# UI Requirements

* Modern
* Fast
* Material 3
* Smooth animations
* Responsive
* Clean spacing
* Premium-looking design
* No unnecessary popups

---

# Future Ready

The architecture must already support adding these later without refactoring:

* Premium Plans
* AdMob
* Rewarded Ads
* RevenueCat
* Team Accounts
* Cloud History
* Multi-language
* Advanced Analytics
* Competitor Analysis
* Keyword Explorer
* Best Upload Time

Do NOT implement these features now. Only prepare the architecture.

---

# Development Process

Before writing any Flutter code:

1. Design complete architecture.
2. Create folder structure.
3. Create navigation flow.
4. Create data models.
5. Create repository interfaces.
6. Create API abstraction layer.
7. Explain the implementation plan.

Only after architecture approval should implementation begin.

All code must be production-ready, modular, scalable, and suitable for Play Store release.
