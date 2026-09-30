# PromiseGuard 🛡️

> AI-powered commitment drift detection for B2B sales calls.

**Live Demo:** https://promiseguard.vercel.app

---

## The Problem

In B2B sales, verbal commitments are made before any contract is signed.

A buyer says *"yeah that should work."*
The salesperson hears a confirmed deal.
The buyer meant *"maybe, pending finance approval."*

By the time this gap surfaces it is a legal dispute, a lost client, or a failed delivery — not a simple correction.

There is no record of how the commitment formed, what was tentative, what was conditional, and what was never explicitly confirmed.

**67% of professionals have had a dispute about what was actually said or agreed in a meeting.**
**77% of lost B2B deals come down to misalignment between what the seller and buyer believed was agreed.**

This is commitment drift. And it happens on every sales call.

---

## What PromiseGuard Does

PromiseGuard listens to sales calls — recorded or live — and tracks how commitment language evolves through a structured 5-state model. When a commercial term drifts from tentative to assumed-agreed without explicit confirmation, PromiseGuard flags it instantly with full evidence, a state change trail, and a suggested clarifying question.

---

## The 5-State Commitment Model

Every commercial term in a sales call passes through these states in order:

POSSIBILITY → TENTATIVE → CONDITIONAL → APPARENT_COMMITMENT → CONFIRMED


| State | Description | Example |
|---|---|---|
| POSSIBILITY | Vague interest | "we could maybe do that" |
| TENTATIVE | Soft commitment | "I think we can probably manage Friday" |
| CONDITIONAL | Depends on something | "if finance approves, we're on" |
| APPARENT_COMMITMENT | Assumed without confirmation | "so we'll consider Friday the delivery date" |
| CONFIRMED | Explicit mutual agreement | "yes, Friday is confirmed by both sides" |

**Drift is flagged when the same commercial term jumps from states 1-3 to states 4-5 without explicit mutual confirmation between those two points.**

No other tool in this hackathon tracks commitment language this way.

---

## How It Works

### Two Input Paths

Audio file (.mp3, .wav, .m4a)
↓
AssemblyAI transcription
(speaker labels + entity detection)
↓
Transcript review
↓
Gemini 2.5 Flash full analysis
↓
Drift alert + agreement record

Live browser call
↓
AssemblyAI Streaming STT v3 (WebSocket)
↓
Real-time transcript
↓
Hybrid drift check every 5 lines
(keywords first → Gemini if keywords miss)
↓
Live warning banner on screen
↓
Full Gemini analysis on call end
↓
Drift alert + agreement record


### The Analysis Pipeline

1. Every transcript line gets a unique ID — L001, L002, L003 and so on
2. The labeled transcript is sent to Gemini 2.5 Flash
3. Gemini classifies every commercial term through the 5-state model
4. Gemini identifies drift, earlier and later evidence lines, missing confirmation, agreement items, and a clarifying question
5. Every line ID returned by Gemini is validated against the real transcript — hallucinated IDs are rejected
6. The state change direction is validated — backwards transitions are rejected
7. A clean structured result reaches the user

### What The User Sees

**Processing Screen** — progress bar through upload, transcription, extraction

**Transcript Screen** — full call as a chat conversation with entity detection chips at the top showing money amounts, dates, people, and organizations automatically detected by AssemblyAI

**Drift Alert Screen** — when drift is detected:
- Orange warning card naming the commercial term
- Commitment timeline — numbered visual trail of every mention with state label, quote, speaker, timestamp, and line ID
- Evidence cards — the exact lines that prove the drift
- State change trail — L004 TENTATIVE → APPARENT_COMMITMENT L012
- Missing evidence block — what confirmation was absent
- Why flagged — Gemini's plain language explanation
- Suggested clarifying question — exact question to ask before closing

**Agreement Record Screen** — final summary with commercial term, status, commitment path, evidence, agreement items table, PDF export, and shareable link

**Call History Screen** — all past calls saved to Firestore with name, date, and drift status

**Live Call Screen** — real-time transcript with animated drift warning banner that slides in when patterns are detected during the call

---

## What Makes PromiseGuard Unique

### 1. The 5-State Commitment Model
No competitor tracks how commitment language evolves. ClauseCatcher gives binary yes/no per sentence. MeaningLock compares what both parties said. PromiseGuard tracks the full journey from vague interest to confirmed agreement.

### 2. Line ID Traceability
Every piece of evidence is pinned to an exact line in the real transcript. The salesperson can verify every claim themselves. Evidence is not a summary — it is a citation.

### 3. Backend Validation — We Don't Trust The AI Blindly

If Gemini returns a line ID that does not exist in the transcript → rejected
If Gemini produces a state change that goes backwards → rejected

No hallucinated evidence ever reaches the salesperson. This is production-grade reliability engineering that no other project in this hackathon implements.

### 4. Hybrid Real-Time Detection
During live calls, PromiseGuard runs a two-layer checker every 5 committed lines:
- **Layer 1:** Local keyword patterns — instant, zero API cost
- **Layer 2:** Gemini live checker on the last 15 lines — catches nuanced drift keywords miss

The salesperson sees the alert while the call is still running. There is still time to ask for confirmation before the deal closes with an unresolved assumption.

### 5. Both Input Paths
File upload for recorded calls and live browser streaming for active calls. 

### 6. Full Audit Trail
PDF export, shareable link, and Firestore call history mean the record of what was agreed lives permanently outside the app.

---

## Architecture

Flutter Web (GetX)
↓
Firebase Cloud Functions (Node.js) — secure API proxy
├── transcribeAudio → AssemblyAI async transcription
├── getTranscript → polls AssemblyAI until complete
├── analyzeDrift → full Gemini analysis with validation
├── analyzeDriftLive → lightweight Gemini check (last 15 lines)
└── getStreamingToken → short-lived AssemblyAI streaming token
↓
Firebase Firestore — call record persistence
Firebase Auth — signed-in users + anonymous guests


---

## Tech Stack

| Layer | Technology |
|---|---|
| Frontend | Flutter Web |
| State Management | GetX |
| Backend | Firebase Cloud Functions (Node.js) |
| Transcription | AssemblyAI (async + streaming STT v3) |
| AI Analysis | Gemini 2.5 Flash |
| Database | Firebase Firestore |
| Auth | Firebase Authentication |
| Deployment | Vercel |

---

## Running Locally

### Prerequisites
- Flutter SDK
- Firebase CLI
- Node.js 18+
- AssemblyAI API key
- Gemini API key



## Built With

- [AssemblyAI](https://www.assemblyai.com) — transcription and streaming STT
- [Gemini 2.5 Flash](https://deepmind.google/technologies/gemini/) — commitment analysis
- [Firebase](https://firebase.google.com) — functions, Firestore, auth
- [Flutter](https://flutter.dev) — cross-platform web frontend

---

## Team

Solo developer who Built for the AssemblyAI Voice Agent Hackathon on lablab.ai
