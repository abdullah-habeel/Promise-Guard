const {onRequest} = require("firebase-functions/v2/https");
const {defineSecret} = require("firebase-functions/params");
const logger = require("firebase-functions/logger");

const ASSEMBLYAI_KEY = defineSecret("ASSEMBLYAI_KEY");
const GEMINI_KEY = defineSecret("GEMINI_KEY");

const ASSEMBLYAI_BASE = "https://api.assemblyai.com/v2";
const GEMINI_BASE = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent";

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

        const transcriptText = transcript
    .map((line, index) => {
      const lineId = `L${String(index + 1).padStart(3, "0")}`;
      return `${lineId} | ${line.time} | ${line.speaker}: ${line.text}`;
    })
    .join("\n");

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

Respond ONLY with a valid JSON object. No markdown, no backticks, no explanation outside the JSON.

JSON shape:
{
  "driftDetected": <true or false>,
  "commercialTerm": "<the commercial term that drifted>",
  "explanation": "<why this was flagged, based on actual transcript content>",
  "clarifyingQuestion": "<a question to resolve the ambiguity>",
  "evidence": [
    {
      "lineId": "<e.g. L014>",
      "timestamp": "<mm:ss from actual transcript>",
      "speaker": "<speaker name>",
      "quote": "<exact quote from actual transcript>",
      "stateLabel": "TENTATIVE",
      "commercialTerm": "<actual term>"
    },
    {
      "lineId": "<e.g. L042>",
      "timestamp": "<mm:ss from actual transcript>",
      "speaker": "<speaker name>",
      "quote": "<exact quote from actual transcript>",
      "stateLabel": "COMMITTED",
      "commercialTerm": "<actual term>"
    }
  ],
  "earlierEvidence": "<lineId of first mention e.g. L014>",
  "laterEvidence": "<lineId of last mention e.g. L042>",
  "stateChange": "<e.g. TENTATIVE → APPARENT_COMMITMENT>",
  "missingEvidence": "<what confirmation is missing>",
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

If no drift is detected, return driftDetected as false with empty arrays.
`;

        const geminiResponse = await fetch(`${GEMINI_BASE}?key=${apiKey}`, {
          method: "POST",
          headers: {"content-type": "application/json"},
          body: JSON.stringify({
            contents: [{parts: [{text: prompt}]}],
            generationConfig: {temperature: 0.1},
          }),
        });

        const geminiData = await geminiResponse.json();

        if (!geminiData.candidates || geminiData.candidates.length === 0) {
          logger.error("Gemini returned no candidates", geminiData);
          return res.status(500).json({error: "Gemini returned no response"});
        }

        const rawText = geminiData.candidates[0].content.parts[0].text;
        const cleaned = rawText.replace(/```json|```/g, "").trim();
        const parsed = JSON.parse(cleaned);

        return res.status(200).json(parsed);
      } catch (err) {
        logger.error("analyzeDrift error", err);
        return res.status(500).json({error: err.message});
      }
    },
);