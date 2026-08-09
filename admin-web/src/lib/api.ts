import axios, { AxiosError } from "axios";
import type { ApiEnvelope } from "@/types/api";

const API_BASE_URL =
  process.env.NEXT_PUBLIC_API_BASE_URL ?? "http://localhost:3000/api/v1";

export const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    "Content-Type": "application/json",
    Accept: "application/json",
  },
});

export function setAuthToken(token: string | null) {
  if (token) {
    api.defaults.headers.common.Authorization = `Bearer ${token}`;
  } else {
    delete api.defaults.headers.common.Authorization;
  }
}

export function getStoredToken() {
  if (typeof window === "undefined") return null;
  return localStorage.getItem("yelo_admin_token");
}

export function storeToken(token: string) {
  localStorage.setItem("yelo_admin_token", token);
  setAuthToken(token);
}

export function clearToken() {
  localStorage.removeItem("yelo_admin_token");
  setAuthToken(null);
}

if (typeof window !== "undefined") {
  setAuthToken(getStoredToken());
}

api.interceptors.response.use(
  (response) => response,
  (error: AxiosError<ApiEnvelope<unknown>>) => {
    if (error.response?.status === 401 && typeof window !== "undefined") {
      clearToken();
      if (!window.location.pathname.startsWith("/login")) {
        window.location.href = "/login";
      }
    }
    return Promise.reject(error);
  },
);

export async function apiGet<T>(url: string, params?: Record<string, unknown>) {
  const response = await api.get<ApiEnvelope<T>>(url, { params });
  return response.data.data;
}

export async function apiPost<T>(url: string, body?: unknown) {
  const response = await api.post<ApiEnvelope<T>>(url, body);
  return response.data.data;
}

export async function apiPatch<T>(url: string, body?: unknown) {
  const response = await api.patch<ApiEnvelope<T>>(url, body);
  return response.data.data;
}

export async function apiDelete<T>(url: string, body?: unknown) {
  const response = await api.delete<ApiEnvelope<T>>(url, { data: body });
  return response.data.data;
}
