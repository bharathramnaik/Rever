"""Rever AI Layer - FastAPI service for AI tutoring, content generation, quiz, visual specs, and embeddings.

Endpoints:
  GET  /health                          -> service liveness
  POST /ai/chat                         -> AI Tutor chat (LLM when OPENAI_API_KEY set, else deterministic fallback)
  POST /ai/generate/card                -> Generate learning card from source text
  POST /ai/generate/quiz                -> Generate quiz from concept
  POST /ai/generate/visual              -> Generate visual specification for Flutter renderer
  POST /ai/embed                        -> Create embeddings (OpenAI or deterministic hash fallback)

Design: works fully keyless (deterministic fallbacks) so the app runs in dev; upgrades to real
LLM answers automatically when OPENAI_API_KEY is present.
"""

import os
import re
from typing import List, Optional

from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field

load_dotenv()

app = FastAPI(title="Rever AI", version="0.1.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

OPENAI_API_KEY = os.getenv("OPENAI_API_KEY", "").strip()
OPENAI_MODEL = os.getenv("OPENAI_MODEL", "gpt-4o-mini")

# ---------------------------------------------------------------------------
# Models
# ---------------------------------------------------------------------------


class ChatMessage(BaseModel):
    role: str  # 'user' | 'assistant'
    content: str


class ChatRequest(BaseModel):
    message: str
    mode: str = "explain"  # one of TutorMode values (lowercase)
    concept_id: Optional[str] = None
    conversation_history: List[ChatMessage] = Field(default_factory=list)


class GroundingSource(BaseModel):
    title: str
    url: str = ""
    snippet: str = ""


class ChatResponse(BaseModel):
    reply: str
    mode: str
    grounding_sources: List[GroundingSource] = Field(default_factory=list)


class CardRequest(BaseModel):
    title: str
    source_text: str


class CardResponse(BaseModel):
    cards: List[dict]


class QuizRequest(BaseModel):
    concept: str
    difficulty: str = "medium"  # easy | medium | hard
    count: int = 3


class QuizResponse(BaseModel):
    questions: List[dict]


class VisualRequest(BaseModel):
    concept: str
    concept_type: str = "process"  # process | hierarchy | relationship | list


class VisualResponse(BaseModel):
    visual_spec: dict


class EmbedRequest(BaseModel):
    text: str


class EmbedResponse(BaseModel):
    embedding: List[float]
    model: str


# ---------------------------------------------------------------------------
# LLM helper (no-op when no key)
# ---------------------------------------------------------------------------


def _llm_available() -> bool:
    return bool(OPENAI_API_KEY)


def _llm_chat(system: str, user: str, max_tokens: int = 600) -> Optional[str]:
    """Return LLM completion, or None if unavailable/failed."""
    if not _llm_available():
        return None
    try:
        from openai import OpenAI

        client = OpenAI(api_key=OPENAI_API_KEY)
        resp = client.chat.completions.create(
            model=OPENAI_MODEL,
            messages=[
                {"role": "system", "content": system},
                {"role": "user", "content": user},
            ],
            max_tokens=max_tokens,
            temperature=0.7,
        )
        return resp.choices[0].message.content
    except Exception:
        return None


def _sentence_split(text: str) -> List[str]:
    return [s.strip() for s in re.split(r"(?<=[.!?])\s+", text) if s.strip()]


def _chunk_text(text: str, max_len: int = 180) -> List[str]:
    sentences = _sentence_split(text)
    chunks: List[str] = []
    current = ""
    for s in sentences:
        if len(current) + len(s) + 1 > max_len and current:
            chunks.append(current.strip())
            current = s
        else:
            current = f"{current} {s}".strip()
    if current:
        chunks.append(current.strip())
    return chunks


# ---------------------------------------------------------------------------
# Deterministic fallbacks (keyless mode)
# ---------------------------------------------------------------------------

_MODE_PROMPTS = {
    "explain": "Explain the core idea clearly with structure, key definitions, and an intuitive summary.",
    "simplify": "Explain like I'm 10: short sentences, familiar analogies, no jargon.",
    "godeeper": "Go deeper: mechanisms, nuance, edge cases, and how it connects to related fields.",
    "example": "Give a vivid real-world example that makes the idea concrete and memorable.",
    "showvisually": "Describe a simple visual/mental model that captures the idea at a glance.",
    "compare": "Compare and contrast this idea with closely related concepts, in a small table.",
    "challenge": "Challenge this idea: limitations, critiques, and conditions where it breaks down.",
    "quizme": "Ask a short-answer question to test understanding, then invite the user to answer.",
    "helpremember": "Give a memory hook: mnemonic, story, or spaced-repetition-friendly summary of the key point.",
    "apply": "Suggest 2-3 concrete actions to apply this idea today.",
    "analogy": "Create a strong analogy from everyday life that maps to the concept.",
    "followup": "Suggest one thoughtful follow-up question to deepen learning.",
}


def _fallback_chat(message: str, mode: str) -> str:
    prompt = _MODE_PROMPTS.get(mode.lower(), _MODE_PROMPTS["explain"])
    topic = message.strip() or "this topic"
    return (
        f"📚 **{mode.title()} mode**\n\n"
        f"{prompt}\n\n"
        f"About **{topic}**: here is a structured, reliable starting point. "
        "When an OpenAI API key is configured, the AI Tutor will provide richer, "
        "source-grounded answers. For now this deterministic mode keeps the app fully functional in dev.\n\n"
        f"_Backend online — {_llm_available() and 'LLM mode' or 'fallback mode'}_"
    )


# ---------------------------------------------------------------------------
# Routes
# ---------------------------------------------------------------------------


@app.get("/health")
async def health():
    return {"status": "ok", "service": "rever-ai", "llm": _llm_available()}


@app.post("/ai/chat", response_model=ChatResponse)
async def chat(req: ChatRequest):
    if not req.message.strip() and not req.mode:
        raise HTTPException(status_code=400, detail="message or mode is required")

    system = (
        "You are Rever's AI Tutor. You explain concepts at any depth, adapt to the learner's "
        "level, and keep answers punchy and structured (short paragraphs or bullets). "
        "The user may select a tutor mode: "
        + ", ".join(_MODE_PROMPTS.keys())
        + ". Follow the selected mode's intent strictly."
    )

    history = "\n".join(f"{m.role}: {m.content}" for m in req.conversation_history[-6:])
    user = f"[mode: {req.mode}]\n\n{history}\n\nuser: {req.message}"

    llm_reply = _llm_chat(system, user)
    if llm_reply:
        return ChatResponse(reply=llm_reply.strip(), mode=req.mode)

    return ChatResponse(reply=_fallback_chat(req.message, req.mode), mode=req.mode)


@app.post("/ai/generate/card", response_model=CardResponse)
async def generate_card(req: CardRequest):
    if not req.source_text.strip():
        raise HTTPException(status_code=400, detail="source_text is required")

    llm = _llm_chat(
        "You convert raw source text into 3-5 concise learning-idea cards. "
        "Return ONLY a JSON array of objects: [{\"takeaway\": str, \"body\": str, \"type\": \"overview\"|\"idea\"}].",
        f"Title: {req.title}\n\nSource:\n{req.source_text[:4000]}",
    )
    if llm:
        try:
            import json

            cards = json.loads(llm)
            if isinstance(cards, list) and cards:
                return CardResponse(cards=cards)
        except Exception:
            pass

    text = re.sub(r"\s+", " ", req.source_text).strip()
    if not text:
        return CardResponse(cards=[])
    chunks = _chunk_text(text)
    cards = []
    if chunks:
        cards.append({"takeaway": f"About {req.title}", "body": chunks[0], "type": "overview"})
    for i, chunk in enumerate(chunks[1:], start=1):
        cards.append({"takeaway": f"Idea {i}", "body": chunk, "type": "idea"})
    return CardResponse(cards=cards)


@app.post("/ai/generate/quiz", response_model=QuizResponse)
async def generate_quiz(req: QuizRequest):
    if not req.concept.strip():
        raise HTTPException(status_code=400, detail="concept is required")

    llm = _llm_chat(
        f"Create {req.count} {req.difficulty}-difficulty multiple-choice questions about '{req.concept}'. "
        "Return ONLY a JSON array: "
        '[{"question": str, "options": [4 strings], "answer_index": int, "explanation": str}].',
        f"Concept: {req.concept}",
    )
    if llm:
        try:
            import json

            qs = json.loads(llm)
            if isinstance(qs, list) and qs:
                return QuizResponse(questions=qs[: req.count])
        except Exception:
            pass

    questions = []
    for i in range(req.count):
        questions.append(
            {
                "question": f"What is a key idea about {req.concept}?",
                "options": [
                    f"Correct: a defining characteristic of {req.concept}",
                    f"Distractor about a related topic",
                    f"Distractor from common misconceptions",
                    f"Distractor: unrelated fact",
                ],
                "answer_index": 0,
                "explanation": f"This tests the foundational definition of {req.concept}. Add an OpenAI key for richer generated quizzes.",
            }
        )
    return QuizResponse(questions=questions)


@app.post("/ai/generate/visual", response_model=VisualResponse)
async def generate_visual_spec(req: VisualRequest):
    llm = _llm_chat(
        "Create a visual-spec JSON for a Flutter renderer describing how to visualize a concept. "
        "Schema: {\"title\": str, \"type\": \"process\"|\"hierarchy\"|\"relationship\"|\"list\", "
        "\"nodes\": [{\"id\": str, \"label\": str, \"children\": [ids], \"description\": str}], "
        "\"edges\": [{\"from\": str, \"to\": str, \"label\": str}], \"summary\": str}. "
        "Return ONLY the JSON.",
        f"Concept: {req.concept} (type: {req.concept_type})",
    )
    if llm:
        try:
            import json

            spec = json.loads(llm)
            if isinstance(spec, dict):
                return VisualResponse(visual_spec=spec)
        except Exception:
            pass

    return VisualResponse(
        visual_spec={
            "title": req.concept,
            "type": req.concept_type,
            "nodes": [
                {
                    "id": "root",
                    "label": req.concept,
                    "children": [],
                    "description": f"Key idea: {req.concept}",
                }
            ],
            "edges": [],
            "summary": f"A starting visual for '{req.concept}'. Add an OpenAI key for richer diagrams.",
        }
    )


@app.post("/ai/embed", response_model=EmbedResponse)
async def create_embedding(req: EmbedRequest):
    if not req.text.strip():
        raise HTTPException(status_code=400, detail="text is required")

    if _llm_available():
        try:
            from openai import OpenAI

            client = OpenAI(api_key=OPENAI_API_KEY)
            resp = client.embeddings.create(model="text-embedding-3-small", input=req.text)
            return EmbedResponse(embedding=resp.data[0].embedding, model="text-embedding-3-small")
        except Exception:
            pass

    # Deterministic bag-of-words fallback embedding (fixed 64 dims) for keyless dev.
    tokens = re.findall(r"[a-z0-9]+", req.text.lower())
    vec = [0.0] * 64
    for tok in tokens:
        h = int(hashlib_hex(tok), 16)
        idx = h % 64
        vec[idx] += 1.0 + (h % 7) / 7.0
    norm = sum(v * v for v in vec) ** 0.5 or 1.0
    return EmbedResponse(embedding=[v / norm for v in vec], model="fallback-bow-64")


def hashlib_hex(text: str) -> str:
    import hashlib

    return hashlib.sha256(text.encode()).hexdigest()


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8000)