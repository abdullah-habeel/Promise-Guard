const {onRequest} = require("firebase-functions/v2/https");
const {defineSecret} = require("firebase-functions/params");
const logger = require("firebase-functions/logger");

const ASSEMBLYAI_KEY = defineSecret("ASSEMBLYAI_KEY");
const GEMINI_KEY = defineSecret("GEMINI_KEY");

const ASSEMBLYAI_BASE = "https://api.assemblyai.com/v2";
const GEMINI_BASE = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent";

// ── #2 Validate Gemini response structure ──────────────────────────────────
function validateGeminiResponse(parsed, validLineIds) {
  const errors = [];

  // 1. Required top-level fields
  if (typeof parsed.driftDetected !== "boolean") {
    errors.push("driftDetected must be boolean");
  }
  if (typeof parsed.commercialTerm !== "string") {
    errors.push("commercialTerm must be string");
  }
  if (typeof parsed.explanation !== "string") {
    errors.push("explanation must be string");
  }
  if (typeof parsed.clarifyingQuestion !== "string") {
    errors.push("clarifyingQuestion must be string");
  }
  if (!Array.isArray(parsed.evidence)) {
    errors.push("evidence must be array");
  }
  if (!Array.isArray(parsed.agreementItems)) {
    errors.push("agreementItems must be array");
  }

  // 2. If drift detected, extra fields are required
  if (parsed.driftDetected) {
    if (!parsed.earlierEvidence) errors.push("earlierEvidence missing");
    if (!parsed.laterEvidence) errors.push("laterEvidence missing");
    if (!parsed.stateChange) errors.push("stateChange missing");
    if (!parsed.missingEvidence) errors.push("missingEvidence missing");

    // 3. Validate evidence line IDs exist in actual transcript
    if (Array.isArray(parsed.evidence)) {
      parsed.evidence.forEach((e, i) => {
        if (!e.lineId) {
          errors.push(`evidence[${i}] missing lineId`);
        } else if (!validLineIds.has(e.lineId)) {
          errors.push(`evidence[${i}] lineId "${e.lineId}" not found in transcript`);
        }
        if (!e.quote) errors.push(`evidence[${i}] missing quote`);
        if (!e.stateLabel) errors.push(`evidence[${i}] missing stateLabel`);
        if (!e.timestamp) errors.push(`evidence[${i}] missing timestamp`);
        if (!e.speaker) errors.push(`evidence[${i}] missing speaker`);
      });
    }

    // 4. Validate earlierEvidence and laterEvidence line IDs
    if (parsed.earlierEvidence && !validLineIds.has(parsed.earlierEvidence)) {
      errors.push(`earlierEvidence "${parsed.earlierEvidence}" not found in transcript`);
    }
    if (parsed.laterEvidence && !validLineIds.has(parsed.laterEvidence)) {
      errors.push(`laterEvidence "${parsed.laterEvidence}" not found in transcript`);
    }
  }

  return errors;
}

// ── #2 Safe defaults for missing/null fields ───────────────────────────────
function applyDefaults(parsed) {
  return {
    driftDetected: parsed.driftDetected ?? false,
    commercialTerm: parsed.commercialTerm ?? "",
    explanation: parsed.explanation ?? "",
    clarifyingQuestion: parsed.clarifyingQuestion ?? "",
    earlierEvidence: parsed.earlierEvidence ?? "",
    laterEvidence: parsed.laterEvidence ?? "",
    stateChange: parsed.stateChange ?? "",
    missingEvidence: parsed.missingEvidence ?? "",
    commitmentTimeline: Array.isArray(parsed.commitmentTimeline) ? parsed.commitmentTimeline : [],
    evidence: Array.isArray(parsed.evidence) ? parsed.evidence : [],
    agreementItems: Array.isArray(parsed.agreementItems) ? parsed.agreementItems : [],
  };
}
// ── #4 Validate same-term state-change detection ───────────────────────────
const STATE_RANK = {
  "POSSIBILITY": 1,
  "TENTATIVE": 2,
  "CONDITIONAL": 3,
  "APPARENT_COMMITMENT": 4,
  "CONFIRMED": 5,
};

function validateStateChange(safe) {
  if (!safe.driftDetected) return null;

  // Find earlier and later entries in commitmentTimeline
  const earlier = safe.commitmentTimeline.find(
      (e) => e.lineId === safe.earlierEvidence,
  );
  const later = safe.commitmentTimeline.find(
      (e) => e.lineId === safe.laterEvidence,
  );

  if (!earlier || !later) {
    return "earlierEvidence or laterEvidence not found in commitmentTimeline";
  }

  const earlierRank = STATE_RANK[earlier.state] ?? 0;
  const laterRank = STATE_RANK[later.state] ?? 0;

  if (earlierRank === 0 || laterRank === 0) {
    return `Invalid state: earlier=${earlier.state}, later=${later.state}`;
  }

  if (laterRank <= earlierRank) {
    return `No forward drift: earlier=${earlier.state}(${earlierRank}), later=${later.state}(${laterRank})`;
  }

  return null; // valid
}

exports.transcribeAudio = onRequest(
    {secrets: [ASSEMBLYAI_KEY], cors: true, timeoutSeconds: 300},
    async (req, res) => {
      try {
        const apiKey = ASSEMBLYAI_KEY.value();

        const uploadResponse = await fetch(`${ASSEMBLYAI_BASE}/upload`, {
          method: "POST",
          headers: {authorization: apiKey},
          body: req.rawBody,
        });
        const uploadData = await uploadResponse.json();

        if (!uploadData.upload_url) {
          logger.error("Upload failed", uploadData);
          return res.status(500).json({error: "Upload failed", details: uploadData});
        }

        const transcriptResponse = await fetch(`${ASSEMBLYAI_BASE}/transcript`, {
          method: "POST",
          headers: {
            authorization: apiKey,
            "content-type": "application/json",
          },
          body: JSON.stringify({
            audio_url: uploadData.upload_url,
            speaker_labels: true,
            speech_models: ["universal-3-5-pro"],
            sentiment_analysis: true,
            entity_detection: true,
          }),
        });
        const transcriptData = await transcriptResponse.json();

        logger.info("AssemblyAI transcript response", transcriptData);

        return res.status(200).json({transcript_id: transcriptData.id});
      } catch (err) {
        logger.error("transcribeAudio error", err);
        return res.status(500).json({error: err.message});
      }
    },
);

exports.getTranscript = onRequest(
    {secrets: [ASSEMBLYAI_KEY], cors: true},
    async (req, res) => {
      try {
        const apiKey = ASSEMBLYAI_KEY.value();
        const transcriptId = req.query.id;

        if (!transcriptId) {
          return res.status(400).json({error: "Missing transcript id"});
        }

        const response = await fetch(`${ASSEMBLYAI_BASE}/transcript/${transcriptId}`, {
          headers: {authorization: apiKey},
        });
        const data = await response.json();

        return res.status(200).json(data);
      } catch (err) {
        logger.error("getTranscript error", err);
        return res.status(500).json({error: err.message});
      }
    },
);

exports.analyzeDrift = onRequest(
    {secrets: [GEMINI_KEY], cors: true, timeoutSeconds: 120},
    async (req, res) => {
      try {
        const apiKey = GEMINI_KEY.value();
        const {transcript} = req.body;

        if (!transcript || !Array.isArray(transcript)) {
          return res.status(400).json({error: "Missing transcript array"});
        }

        // Build line IDs and transcript text
        const lineIdMap = new Map();
        const transcriptText = transcript
            .map((line, index) => {
              const lineId = `L${String(index + 1).padStart(3, "0")}`;
              lineIdMap.set(lineId, true);
              return `${lineId} | ${line.time} | ${line.speaker}: ${line.text}`;
            })
            .join("\n");

        const validLineIds = new Set(lineIdMap.keys());

        const prompt = `
You are PromiseGuard, a commitment tracking system for B2B sales calls.

COMMITMENT STATE MODEL:
Every commercial commitment passes through these states in order:
1. POSSIBILITY        — vague interest, "we could", "maybe", "what if"
2. TENTATIVE          — "I think", "probably", "roughly", "I could probably get approval"
3. CONDITIONAL        — "if finance approves", "subject to sign-off", depends on condition
4. APPARENT_COMMITMENT — treated as agreed without explicit confirmation, "yeah that should work"
5. CONFIRMED          — explicit mutual confirmation on record, "yes that is approved"

DRIFT RULE:
Drift occurs when the SAME commercial term moves from state 1-3 to state 4-5
WITHOUT an explicit reconfirmation between those two points.

MISSING CONFIRMATION RULE:
After identifying drift, scan ALL lines between earlierEvidence and laterEvidence.
If no line contains explicit mutual confirmation of the term, set missingEvidence
to describe exactly what is absent.
If a confirmation exists, set missingEvidence to empty string and driftDetected to false.

TRANSCRIPT:
${transcriptText}

Each line is formatted as: LINE_ID | TIMESTAMP | SPEAKER: TEXT

STRICT RULES:
- Only use LINE_IDs that exist in the transcript above
- Only quote text that appears verbatim in the transcript
- Never invent data, timestamps, speakers, or line IDs
- Every evidence item MUST have a lineId from the transcript
- stateLabel MUST be one of: POSSIBILITY, TENTATIVE, CONDITIONAL, APPARENT_COMMITMENT, CONFIRMED
- state MUST be one of: POSSIBILITY, TENTATIVE, CONDITIONAL, APPARENT_COMMITMENT, CONFIRMED
- If no drift detected, return driftDetected false and empty arrays

Respond ONLY with valid JSON. No markdown, no backticks, no text outside JSON.

{
  "driftDetected": <true or false>,
  "commercialTerm": "<the commercial term that drifted, empty string if none>",
  "explanation": "<why flagged based on actual transcript, empty string if none>",
  "clarifyingQuestion": "<question to resolve ambiguity, empty string if none>",
  "earlierEvidence": "<lineId of first tentative mention, empty string if none>",
  "laterEvidence": "<lineId of assumption or apparent commitment, empty string if none>",
  "stateChange": "<e.g. TENTATIVE → APPARENT_COMMITMENT, empty string if none>",
  "missingEvidence": "<what explicit confirmation is missing, empty string if none>",
  "commitmentTimeline": [
    {
      "lineId": "<exact LINE_ID>",
      "timestamp": "<mm:ss>",
      "speaker": "<speaker>",
      "state": "<one of: POSSIBILITY, TENTATIVE, CONDITIONAL, APPARENT_COMMITMENT, CONFIRMED>",
      "quote": "<exact quote>"
    }
  ],
  "evidence": [
    {
      "lineId": "<exact LINE_ID>",
      "timestamp": "<mm:ss>",
      "speaker": "<speaker>",
      "quote": "<exact quote>",
      "stateLabel": "<one of: POSSIBILITY, TENTATIVE, CONDITIONAL, APPARENT_COMMITMENT, CONFIRMED>",
      "commercialTerm": "<actual term>"
    }
  ],
  "agreementItems": [
    {
      "item": "<actual item>",
      "value": "<actual value>",
      "lineId": "<lineId>",
      "evidence": "<mm:ss>",
      "participants": "<speakers>"
    }
  ]
}
`;

        const geminiResponse = await fetch(`${GEMINI_BASE}?key=${apiKey}`, {
          method: "POST",
          headers: {"content-type": "application/json"},
          body: JSON.stringify({
            contents: [{parts: [{text: prompt}]}],
            generationConfig: {
              temperature: 0.1,
              responseMimeType: "application/json",
            },
          }),
        });

        const geminiData = await geminiResponse.json();

        if (!geminiData.candidates || geminiData.candidates.length === 0) {
          logger.error("Gemini returned no candidates", geminiData);
          return res.status(500).json({error: "Gemini returned no response"});
        }

        const rawText = geminiData.candidates[0].content.parts[0].text;
        const cleaned = rawText.replace(/```json|```/g, "").trim();

        let parsed;
        try {
          parsed = JSON.parse(cleaned);
        } catch (parseErr) {
          logger.error("Gemini JSON parse failed", rawText);
          return res.status(500).json({error: "Gemini returned invalid JSON"});
        }

        // Apply safe defaults
        const safe = applyDefaults(parsed);

        // Validate structure and line IDs
        const validationErrors = validateGeminiResponse(safe, validLineIds);
        if (validationErrors.length > 0) {
          logger.warn("Gemini response validation warnings", validationErrors);
          // We still return the response but log the issues
          // Filter out evidence with invalid line IDs
          safe.evidence = safe.evidence.filter((e) => {
            if (!e.lineId || !validLineIds.has(e.lineId)) {
              logger.warn(`Removing evidence with invalid lineId: ${e.lineId}`);
              return false;
            }
            return true;
          });
        }
                // Validate state-change direction
        const stateChangeError = validateStateChange(safe);
        if (stateChangeError) {
          logger.warn("State-change validation failed", stateChangeError);
          // Reset drift if state change is invalid
          safe.driftDetected = false;
          safe.stateChange = "";
          safe.earlierEvidence = "";
          safe.laterEvidence = "";
          safe.missingEvidence = "";
        }

        logger.info("analyzeDrift success", {
          driftDetected: safe.driftDetected,
          evidenceCount: safe.evidence.length,
          validationErrors,
        });

        return res.status(200).json(safe);
      } catch (err) {
        logger.error("analyzeDrift error", err);
        return res.status(500).json({error: err.message});
      }
    },
);
exports.getStreamingToken = onRequest(
    {secrets: [ASSEMBLYAI_KEY], cors: true},
    async (req, res) => {
      try {
        const apiKey = ASSEMBLYAI_KEY.value();
        const response = await fetch(
            "https://streaming.assemblyai.com/v3/token?expires_in_seconds=60",
            {
              method: "GET",  // ← was POST
              headers: {Authorization: apiKey},
            },
        );
        const data = await response.json();
        return res.status(200).json({token: data.token});
      } catch (err) {
        return res.status(500).json({error: err.message});
      }
    },
);