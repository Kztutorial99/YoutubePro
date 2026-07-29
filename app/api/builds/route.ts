import { NextRequest, NextResponse } from "next/server";

const OWNER = "Kztutorial99";
const REPO  = "YoutubePro";
const WORKFLOW = "build-apk.yml";
const TOKEN = process.env.GITHUB_TOKEN || "";

const GH = (path: string) =>
  fetch(`https://api.github.com${path}`, {
    headers: {
      Authorization: `Bearer ${TOKEN}`,
      Accept: "application/vnd.github+json",
      "X-GitHub-Api-Version": "2022-11-28",
    },
  });

// GET /api/builds — list recent workflow runs
export async function GET(req: NextRequest) {
  const { searchParams } = new URL(req.url);
  const download = searchParams.get("download");

  // If ?download=<run_id> — redirect to APK artifact
  if (download) {
    const artRes = await GH(`/repos/${OWNER}/${REPO}/actions/runs/${download}/artifacts`);
    const artData = await artRes.json();
    const apk = (artData.artifacts || []).find((a: { name: string }) =>
      a.name.startsWith("YouTubePro-mod")
    );
    if (!apk) return NextResponse.json({ error: "artifact not found" }, { status: 404 });

    // Return download URL (requires auth — proxy through)
    const dlRes = await GH(`/repos/${OWNER}/${REPO}/actions/artifacts/${apk.id}/zip`);
    return NextResponse.json({ download_url: dlRes.url });
  }

  const res = await GH(
    `/repos/${OWNER}/${REPO}/actions/workflows/${WORKFLOW}/runs?per_page=10`
  );
  const data = await res.json();
  return NextResponse.json(data);
}

// POST /api/builds — trigger workflow_dispatch
export async function POST(_req: NextRequest) {
  const res = await fetch(
    `https://api.github.com/repos/${OWNER}/${REPO}/actions/workflows/${WORKFLOW}/dispatches`,
    {
      method: "POST",
      headers: {
        Authorization: `Bearer ${TOKEN}`,
        Accept: "application/vnd.github+json",
        "Content-Type": "application/json",
        "X-GitHub-Api-Version": "2022-11-28",
      },
      body: JSON.stringify({ ref: "main" }),
    }
  );
  return NextResponse.json({ ok: res.status === 204, status: res.status });
}
