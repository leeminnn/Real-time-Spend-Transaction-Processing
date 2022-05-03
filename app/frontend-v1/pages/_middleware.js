import { NextResponse } from "next/server";
import { getCookie } from "cookies-next";

export async function middleware(req, res) {
  const url = req.nextUrl.clone();

  const jwtCookie = getCookie("JWT", { req, res });

  if (url.pathname == "/login" && jwtCookie) {
    url.pathname = "/";
    return NextResponse.redirect(url);
  }

  if (!jwtCookie && url.pathname == "/") {
    url.pathname = "/login";
    return NextResponse.redirect(url);
  }
}
