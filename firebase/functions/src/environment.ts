export const adminPassword = process.env.ADMIN_PASSWORD;

export const projectId =
  (process.env.GCP_PROJECT ||
    process.env.GCLOUD_PROJECT ||
    process.env["PROJECT_ID"]) ??
  "meetinghelper-shamamsaschool";

export const firebaseDynamicLinksAPIKey =
  process.env["FB_DYNAMIC_LINKS_API_KEY"];

export const firebaseDynamicLinksPrefix =
  process.env["FB_DYNAMIC_LINKS_PREFIX"];

export const packageName =
  process.env["PACKAGE_NAME"] ??
  "com.AndroidQuartz.meetinghelper.shamamsa_school";
