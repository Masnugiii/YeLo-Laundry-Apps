export function isDevToolsEnabled(): boolean {
  if (process.env.NEXT_PUBLIC_ENABLE_DEV_TOOLS === "false") {
    return false;
  }

  if (process.env.NEXT_PUBLIC_ENABLE_DEV_TOOLS === "true") {
    return true;
  }

  return process.env.NODE_ENV === "development";
}
