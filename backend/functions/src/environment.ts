export const adminPassword = process.env.ADMIN_PASSWORD;
export const firebase_dynamic_links_key = process.env.FB_DYNAMIC_LINKS_KEY!;
export const projectId =
  process.env.GCP_PROJECT ||
  process.env.GCLOUD_PROJECT ||
  "meetinghelper-shamamsaschool";
export const packageName =
  process.env.PACKAGE_NAME ?? "com.AndroidQuartz.meetinghelper.shamamsa_school";
export const firebase_dynamic_links_prefix =
  process.env.FB_DYNAMIC_LINKS_PREFIX!;
