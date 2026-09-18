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
    evidence: Array.isArray(parsed.evidence) ? parsed.evidence : [],
    agreementItems: Array.isArray(parsed.agreementItems) ? parsed.agreementItems : [],
  };
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

Analyze this sales call transcript and detect promise drift — when a commitment moves from tentative to treated-as-confirmed without explicit reconfirmation.

TRANSCRIPT:
${transcriptText}

Each line is formatted as: LINE_ID | TIMESTAMP | SPEAKER: TEXT

INSTRUCTIONS:
- Look for commitment-relevant statements about: Price, Delivery, Scope, Support
- Classify each statement as: TENTATIVE, ESTIMATE, or COMMITTED
- Flag drift when the same commercial term escalates in state without explicit reconfirmation
- Do NOT accuse intent — only report language and evidence state changes
- Base ALL values, quotes, timestamps, and line IDs on the ACTUAL transcript — never invent data
- Every evidence item MUST reference the exact LINE_ID from the transcript
- LINE_IDs must exist in the transcript above — never invent a line ID

Respond ONLY with a valid JSON object. No markdown, no backticks, no explanation outside the JSON.

JSON shape:
{
  "driftDetected": <true or false>,
  "commercialTerm": "<the commercial term that drifted, empty string if none>",
  "explanation": "<why this was flagged, based on actual transcript content, empty string if none>",
  "clarifyingQuestion": "<a question to resolve the ambiguity, empty string if none>",
  "earlierEvidence": "<lineId of first mention e.g. L014, empty string if driftDetected is false>",
  "laterEvidence": "<lineId of last mention e.g. L042, empty string if driftDetected is false>",
  "stateChange": "<e.g. TENTATIVE → APPARENT_COMMITMENT, empty string if driftDetected is false>",
  "missingEvidence": "<what confirmation is missing, empty string if driftDetected is false>",
  "evidence": [
    {
      "lineId": "<exact LINE_ID from transcript>",
      "timestamp": "<mm:ss from actual transcript>",
      "speaker": "<speaker name>",
      "quote": "<exact quote from actual transcript>",
      "stateLabel": "<TENTATIVE | ESTIMATE | COMMITTED | APPARENT_COMMITMENT | CUSTOMER_ASSUMPTION_OF_COMMITMENT>",
      "commercialTerm": "<actual term>"
    }
  ],
  "agreementItems": [
    {
      "item": "<actual item name>",
      "value": "<actual value from transcript>",
      "lineId": "<lineId where this was stated>",
      "evidence": "<mm:ss timestamp>",
      "participants": "<speakers involved>"
    }
  ]
}

If no drift is detected, return driftDetected as false and empty arrays for evidence and agreementItems.
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