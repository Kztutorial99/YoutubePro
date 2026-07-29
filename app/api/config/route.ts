import { NextRequest, NextResponse } from "next/server";
import { promises as fs } from "fs";
import path from "path";

const CONFIG_FILE = path.join("/tmp", "ytpro_config.json");

async function readConfig(): Promise<{ url: string }> {
  try {
    const raw = await fs.readFile(CONFIG_FILE, "utf-8");
    return JSON.parse(raw);
  } catch {
    return { url: process.env.PAYLOAD_URL || "" };
  }
}

// GET /api/config — called by APK to get payload DEX URL
export async function GET() {
  const config = await readConfig();
  return NextResponse.json(config, {
    headers: {
      "Access-Control-Allow-Origin": "*",
      "Cache-Control": "no-store",
    },
  });
}

// POST /api/config — called by dashboard to update URL
export async function POST(req: NextRequest) {
  const body = await req.json();
  const url: string = (body.url || "").trim();
  await fs.writeFile(CONFIG_FILE, JSON.stringify({ url }), "utf-8");
  return NextResponse.json({ ok: true, url });
}
